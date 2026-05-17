from __future__ import annotations

from typing import Any, Dict, Optional

import stripe
from django.conf import settings

class PaymentGatewayAdapter:
    """Adapter contract for external payment gateway integrations."""

    def create_payment_intent(
        self,
        amount_pennies: int,
        currency: str,
        payment_method: str,
        order_id: str,
        idempotency_key: Optional[str] = None,
        metadata: Optional[Dict[str, str]] = None,
    ) -> Dict[str, Any]:
        raise NotImplementedError()

    def retrieve_payment_status(self, gateway_reference: str) -> Dict[str, Any]:
        raise NotImplementedError()

    def verify_webhook_signature(self, payload: bytes, signature: str) -> bool:
        raise NotImplementedError()


class StripePaymentGatewayAdapter(PaymentGatewayAdapter):
    def __init__(
        self,
        secret_key: Optional[str] = None,
        webhook_secret: Optional[str] = None,
    ):
        self.secret_key = secret_key if secret_key is not None else settings.STRIPE_SECRET_KEY
        self.webhook_secret = (
            webhook_secret if webhook_secret is not None else settings.STRIPE_WEBHOOK_SECRET
        )

        if self.secret_key:
            stripe.api_key = self.secret_key

    def create_payment_intent(
        self,
        amount_pennies: int,
        currency: str,
        payment_method: str,
        order_id: str,
        idempotency_key: Optional[str] = None,
        metadata: Optional[Dict[str, str]] = None,
    ) -> Dict[str, Any]:
        if not self.secret_key:
            raise ValueError("Stripe secret key is not configured.")

        intent = stripe.PaymentIntent.create(
            amount=amount_pennies,
            currency=currency,
            metadata=metadata or {"order_id": order_id, "payment_method": payment_method},
            automatic_payment_methods={"enabled": True},
            idempotency_key=idempotency_key,
        )
        return {
            "id": intent.get("id", ""),
            "client_secret": intent.get("client_secret", ""),
            "status": intent.get("status", ""),
            "url": "",
        }

    def retrieve_payment_status(self, gateway_reference: str) -> Dict[str, Any]:
        if not self.secret_key:
            raise ValueError("Stripe secret key is not configured.")
        intent = stripe.PaymentIntent.retrieve(gateway_reference)
        return {
            "id": intent.get("id", ""),
            "status": intent.get("status", ""),
            "client_secret": intent.get("client_secret", ""),
        }

    def construct_event(self, payload: bytes, signature: str) -> Dict[str, Any]:
        if not self.webhook_secret:
            raise ValueError("Stripe webhook secret is not configured.")
        try:
            return stripe.Webhook.construct_event(
                payload=payload,
                sig_header=signature,
                secret=self.webhook_secret,
            )
        except (ValueError, stripe.error.SignatureVerificationError) as exc:
            raise ValueError("Invalid webhook signature.") from exc

    def verify_webhook_signature(self, payload: bytes, signature: str) -> bool:
        try:
            self.construct_event(payload, signature)
            return True
        except ValueError:
            return False
