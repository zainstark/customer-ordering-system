from typing import Any, Dict


class PaymentGatewayAdapter:
    """Adapter contract for external payment gateway integrations."""

    def create_payment_intent(
        self,
        amount_pennies: int,
        currency: str,
        payment_method: str,
        order_id: str,
    ) -> Dict[str, Any]:
        raise NotImplementedError()

    def retrieve_payment_status(self, gateway_reference: str) -> Dict[str, Any]:
        raise NotImplementedError()

    def verify_webhook_signature(self, payload: bytes, signature: str) -> bool:
        raise NotImplementedError()
