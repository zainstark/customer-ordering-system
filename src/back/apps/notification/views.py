from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .services import NotificationService
from .serializers import NotificationMessageSerializer


def _account_id(request):
    return getattr(request.user, 'account_id', None)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_notifications(request):
    page = int(request.query_params.get('page', 1))
    limit = int(request.query_params.get('limit', 10))

    account_id = _account_id(request)
    if not account_id:
        return Response({'error': 'Unauthorized'}, status=status.HTTP_401_UNAUTHORIZED)

    items, total, has_next = NotificationService.get_notifications(
        account_id=account_id, page=page, limit=limit
    )

    serializer = NotificationMessageSerializer(items, many=True)
    total_pages = (total + limit - 1) // limit if limit > 0 else 1

    return Response(
        {
            'notifications': serializer.data,
            'pagination': {
                'page': page,
                'limit': limit,
                'total': total,
                'totalPages': total_pages,
                'hasNextPage': has_next,
            },
        },
        status=status.HTTP_200_OK,
    )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def unread_count(request):
    account_id = _account_id(request)
    if not account_id:
        return Response({'error': 'Unauthorized'}, status=status.HTTP_401_UNAUTHORIZED)

    count = NotificationService.get_unread_count(account_id=account_id)
    return Response({'unreadCount': count}, status=status.HTTP_200_OK)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def mark_as_read(request, message_id):
    account_id = _account_id(request)
    if not account_id:
        return Response({'error': 'Unauthorized'}, status=status.HTTP_401_UNAUTHORIZED)

    updated = NotificationService.mark_as_read(message_id=message_id, account_id=account_id)
    if updated is None:
        return Response({'error': 'NotFound', 'message': 'Notification not found'}, status=status.HTTP_404_NOT_FOUND)

    serializer = NotificationMessageSerializer(updated)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def mark_all_read(request):
    account_id = _account_id(request)
    if not account_id:
        return Response({'error': 'Unauthorized'}, status=status.HTTP_401_UNAUTHORIZED)

    marked = NotificationService.mark_all_as_read(account_id=account_id)
    return Response(
        {
            'success': True,
            'message': 'All notifications marked as read',
            'markedCount': marked,
        },
        status=status.HTTP_200_OK,
    )
