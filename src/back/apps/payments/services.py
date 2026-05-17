from typing import Any, Dict, Optional, Tuple

from django.db import transaction

from apps.order.models import Orders as Order
from apps.payments.adapters import PaymentGatewayAdapter
from apps.payments.models import Payment


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
        raise NotImplementedError("Payment gateway adapter has not been configured")

    @staticmethod
    def create_payment_session(
        account_id: str,
        order_id: str,
        payment_method: str,
    ) -> Tuple[Optional[Payment], Optional[str]]:
        raise NotImplementedError()

    @staticmethod
    def get_payment_status(
        account_id: str,
        payment_id: str,
    ) -> Tuple[Optional[Dict[str, Any]], Optional[str]]:
        raise NotImplementedError()

    @staticmethod
    def retry_payment(
        account_id: str,
        payment_id: str,
    ) -> Tuple[Optional[Dict[str, Any]], Optional[str]]:
        raise NotImplementedError()

    @staticmethod
    def process_webhook(
        payload: bytes,
        signature: str,
    ) -> Tuple[Optional[Dict[str, Any]], Optional[str]]:
        raise NotImplementedError()
