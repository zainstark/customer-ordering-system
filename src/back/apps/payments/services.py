from typing import Any, Dict, Optional, Tuple

from django.db import IntegrityError, transaction
from django.db.models import F, Sum
from django.utils import timezone

from apps.order.models import Orders as Order
from apps.payments.adapters import PaymentGatewayAdapter, StripePaymentGatewayAdapter
from apps.payments.models import Payment, PaymentTransaction


class PaymentService:
    """Service layer for payment orchestration and session management."""

    _gateway_adapter: Optional[PaymentGatewayAdapter] = None

    @classmethod
    def set_gateway_adapter(cls, adapter: Optional[PaymentGatewayAdapter]):
        cls._gateway_adapter = adapter

    @classmethod
    def _get_gateway_adapter(cls) -> PaymentGatewayAdapter:
        if cls._gateway_adapter is not None:
            return cls._gateway_adapter
        cls._gateway_adapter = StripePaymentGatewayAdapter()
        return cls._gateway_adapter

    @staticmethod
    def _normalize_method(payment_method: str) -> str:
        return (payment_method or "").upper().strip()

    @staticmethod
    def _status_from_gateway(status: str) -> str:
        normalized = (status or "").lower()
        if normalized in {"succeeded"}:
            return "COMPLETED"
        if normalized in {"processing", "requires_capture"}:
            return "AUTHORIZED"
        if normalized in {"canceled"}:
            return "CANCELLED"
        if normalized in {"requires_payment_method", "requires_action", "requires_confirmation"}:
            return "INITIATED"
        if normalized in {"failed"}:
            return "FAILED"
        return "PENDING"

    @staticmethod
    def create_payment_session(
        account_id: str,
        order_id: str,
        payment_method: str,
    ) -> Tuple[Optional[Payment], Optional[str]]:
        normalized_method = PaymentService._normalize_method(payment_method)
        if normalized_method != "CARD":
            return None, "Unsupported payment method."

        try:
            with transaction.atomic():
                order = (
                    Order.objects.select_for_update()
                    .filter(order_id=order_id, account_id=account_id)
                    .first()
                )
                if order is None:
                    return None, "Order not found for this account."

                if order.order_status in {"PAID", "DELIVERED", "REFUNDED"}:
                    return None, "Order is already paid."

                amount_total = order.items.aggregate(
                    total=Sum(F("unit_price_snapshot") * F("quantity"))
                )["total"] or 0
                if amount_total <= 0:
                    return None, "Order is empty or has invalid total."

                existing_payment = (
                    Payment.objects.select_for_update().filter(order=order).first()
                )
                if existing_payment is not None:
                    if existing_payment.payment_status == "COMPLETED":
                        return None, "Order is already paid."
                    return existing_payment, None

                idempotency_key = f"payment_intent:{order.order_id}:{amount_total}:{normalized_method}"
                adapter = PaymentService._get_gateway_adapter()
                intent = adapter.create_payment_intent(
                    amount_pennies=amount_total,
                    currency="usd",
                    payment_method=normalized_method,
                    order_id=order.order_id,
                    idempotency_key=idempotency_key,
                    metadata={"order_id": order.order_id, "account_id": account_id},
                )

                payment = Payment.objects.create(
                    order=order,
                    payment_method=normalized_method,
                    payment_status=PaymentService._status_from_gateway(intent.get("status", "")),
                    amount=amount_total,
                    currency="usd",
                    payment_intent_id=intent.get("id") or None,
                    client_secret=intent.get("client_secret") or None,
                    checkout_url=intent.get("url") or intent.get("client_secret") or "",
                    gateway_reference=intent.get("id") or "",
                    idempotency_key=idempotency_key,
                    attempt_count=0,
                )
                return payment, None
        except (ValueError, TimeoutError, IntegrityError) as exc:
            return None, str(exc)

    @staticmethod
    def get_payment_status(
        account_id: str,
        payment_id: str,
    ) -> Tuple[Optional[Dict[str, Any]], Optional[str]]:
        try:
            payment = Payment.objects.select_related("order").get(
                payment_id=payment_id,
                order__account_id=account_id,
            )
        except Payment.DoesNotExist:
            return None, "Payment not found for this account."

        gateway_sync_error = None
        if payment.payment_intent_id:
            try:
                adapter = PaymentService._get_gateway_adapter()
                gateway_state = adapter.retrieve_payment_status(payment.payment_intent_id)
                payment.payment_status = PaymentService._status_from_gateway(
                    gateway_state.get("status", "")
                )
                payment.save(update_fields=["payment_status"])
            except (ValueError, TimeoutError) as exc:
                gateway_sync_error = str(exc)

        return {
            "payment_id": payment.payment_id,
            "paymentId": payment.payment_id,
            "order_id": payment.order_id,
            "orderId": payment.order_id,
            "status": payment.payment_status,
            "amount": payment.amount / 100.0,
            "payment_method": payment.payment_method,
            "paymentMethod": payment.payment_method,
            "message": gateway_sync_error,
        }, None

    @staticmethod
    def retry_payment(
        account_id: str,
        payment_id: str,
    ) -> Tuple[Optional[Dict[str, Any]], Optional[str]]:
        try:
            with transaction.atomic():
                payment = (
                    Payment.objects.select_for_update()
                    .select_related("order")
                    .get(payment_id=payment_id, order__account_id=account_id)
                )
                if payment.payment_status == "COMPLETED":
                    return None, "Completed payments cannot be retried."

                payment.attempt_count += 1
                idempotency_key = f"payment_retry:{payment.order_id}:{payment.attempt_count}:{payment.amount}"
                adapter = PaymentService._get_gateway_adapter()
                intent = adapter.create_payment_intent(
                    amount_pennies=payment.amount,
                    currency=payment.currency or "usd",
                    payment_method=payment.payment_method,
                    order_id=payment.order_id,
                    idempotency_key=idempotency_key,
                    metadata={"order_id": payment.order_id, "account_id": account_id},
                )

                payment.payment_status = PaymentService._status_from_gateway(
                    intent.get("status", "")
                )
                payment.payment_intent_id = intent.get("id") or payment.payment_intent_id
                payment.client_secret = intent.get("client_secret") or payment.client_secret
                payment.checkout_url = intent.get("url") or intent.get("client_secret") or payment.checkout_url
                payment.gateway_reference = intent.get("id") or payment.gateway_reference
                payment.idempotency_key = idempotency_key
                payment.save()
        except Payment.DoesNotExist:
            return None, "Payment not found for this account."
        except (ValueError, TimeoutError, IntegrityError) as exc:
            return None, str(exc)

        return {
            "payment_id": payment.payment_id,
            "paymentId": payment.payment_id,
            "status": payment.payment_status,
            "message": "Retry initiated.",
            "retryCount": payment.attempt_count,
        }, None

    @staticmethod
    def process_webhook(
        payload: bytes,
        signature: str,
    ) -> Tuple[Optional[Dict[str, Any]], Optional[str]]:
        adapter = PaymentService._get_gateway_adapter()
        event = None
        if hasattr(adapter, "construct_event"):
            try:
                event = adapter.construct_event(payload, signature)
            except ValueError:
                return None, "Invalid webhook signature."
        else:
            verified = adapter.verify_webhook_signature(payload, signature)
            if verified is not True:
                return None, "Invalid webhook signature."

        if not event:
            return {"status": "accepted"}, None

        event_type = event.get("type", "")
        data_object = event.get("data", {}).get("object", {})
        payment_intent_id = data_object.get("id") or data_object.get("payment_intent")
        if not payment_intent_id:
            return {"status": "ignored", "event_type": event_type}, None

        try:
            with transaction.atomic():
                payment = Payment.objects.select_for_update().select_related("order").filter(
                    payment_intent_id=payment_intent_id
                ).first()
                if payment is None:
                    return {"status": "ignored", "event_type": event_type}, None

                if event_type == "payment_intent.succeeded":
                    payment.payment_status = "COMPLETED"
                    if payment.order.order_status == "PENDING":
                        payment.order.order_status = "CONFIRMED"
                        payment.order.confirmed_at = timezone.now()
                        payment.order.save(update_fields=["order_status", "confirmed_at"])
                elif event_type == "payment_intent.payment_failed":
                    payment.payment_status = "FAILED"
                    payment.order.order_status = "FAILED"
                    payment.order.save(update_fields=["order_status"])
                elif event_type == "payment_intent.canceled":
                    payment.payment_status = "CANCELLED"
                else:
                    payment.payment_status = PaymentService._status_from_gateway(data_object.get("status", ""))

                payment.gateway_reference = payment_intent_id
                payment.save(update_fields=["payment_status", "gateway_reference"])

                PaymentTransaction.objects.create(
                    payment=payment,
                    gateway_reference=payment_intent_id,
                    authorization_code=event_type or "webhook_received",
                )
                return {"status": "processed", "event_type": event_type}, None
        except IntegrityError as exc:
            return None, str(exc)
