from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.payments.serializers import (
    CreatePaymentSessionSerializer,
)
from apps.payments.services import PaymentService


def _get_request_account_id(request):
    return getattr(request.user, 'account_id', None)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_payment_session(request):
    serializer = CreatePaymentSessionSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    account_id = _get_request_account_id(request)
    if not account_id:
        return Response(
            {'error': 'Authentication token is required'},
            status=status.HTTP_401_UNAUTHORIZED,
        )

    payment, error = PaymentService.create_payment_session(
        account_id=account_id,
        order_id=serializer.validated_data['order_id'],
        payment_method=serializer.validated_data['payment_method'],
    )

    if error:
        return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)

    response_data = {
        'payment_id': payment.payment_id,
        'payment_intent_id': payment.payment_intent_id,
        'client_secret': payment.client_secret,
        'checkout_url': payment.checkout_url,
        'status': payment.payment_status,
        # Backward-compatible aliases used by current frontend mock models.
        'paymentId': payment.payment_id,
        'checkoutUrl': payment.checkout_url,
    }
    return Response(response_data, status=status.HTTP_201_CREATED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_payment_status(request, payment_id):
    account_id = _get_request_account_id(request)
    if not account_id:
        return Response(
            {'error': 'Authentication token is required'},
            status=status.HTTP_401_UNAUTHORIZED,
        )

    status_data, error = PaymentService.get_payment_status(account_id, payment_id)
    if error:
        return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
    return Response(status_data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def retry_payment(request, payment_id):
    account_id = _get_request_account_id(request)
    if not account_id:
        return Response(
            {'error': 'Authentication token is required'},
            status=status.HTTP_401_UNAUTHORIZED,
        )

    new_payment_method = request.data.get('payment_method')

    result, error = PaymentService.retry_payment(
        account_id=account_id,
        payment_id=payment_id,
        new_payment_method=new_payment_method,
    )
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
