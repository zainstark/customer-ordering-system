from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.payments.serializers import (
    CreatePaymentSessionSerializer,
    PaymentSessionSerializer,
    PaymentStatusSerializer,
    RetryPaymentSerializer,
    WebhookEventSerializer,
)
from apps.payments.services import PaymentService


def _account_id(request):
    return getattr(request.user, 'account_id', None)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_payment_session(request):
    serializer = CreatePaymentSessionSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    account_id = _account_id(request)
    payment, error = PaymentService.create_payment_session(
        account_id=account_id,
        order_id=serializer.validated_data['orderId'],
        payment_method=serializer.validated_data['paymentMethod'],
    )

    if error:
        return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)

    response_data = {
        'paymentId': payment.payment_id,
        'checkoutUrl': payment.checkout_url,
        'status': payment.payment_status,
    }
    return Response(response_data, status=status.HTTP_201_CREATED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_payment_status(request, payment_id):
    account_id = _account_id(request)
    status_data, error = PaymentService.get_payment_status(account_id, payment_id)
    if error:
        return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
    return Response(status_data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def retry_payment(request, payment_id):
    account_id = _account_id(request)
    result, error = PaymentService.retry_payment(account_id, payment_id)
    if error:
        return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
    return Response(result, status=status.HTTP_200_OK)


@api_view(['POST'])
def payment_webhook(request):
    signature = request.headers.get('Stripe-Signature', '')
    payload = request.body
    if not signature:
        return Response({'error': 'Missing webhook signature'}, status=status.HTTP_400_BAD_REQUEST)

    result, error = PaymentService.process_webhook(payload, signature)
    if error:
        return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
    return Response(result, status=status.HTTP_200_OK)
