import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';
import 'package:frontend/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:frontend/features/notifications/domain/usecases/mark_all_as_read_usecase.dart';
import 'package:frontend/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetNotificationsUseCase extends Mock implements GetNotificationsUseCase {}

class _MockMarkNotificationAsReadUseCase extends Mock
    implements MarkNotificationAsReadUseCase {}

class _MockMarkAllAsReadUseCase extends Mock implements MarkAllAsReadUseCase {}

NotificationEntity _notification({
  required String id,
  required NotificationDeliveryStatus status,
}) {
  return NotificationEntity(
    messageId: id,
    subject: 'Subject $id',
    body: 'Body $id',
    deliveryChannel: NotificationDeliveryChannel.inApp,
    deliveryStatus: status,
    createdAt: DateTime(2025, 1, 1, 12, 0),
  );
}

void main() {
  late _MockGetNotificationsUseCase getNotificationsUseCase;
  late _MockMarkNotificationAsReadUseCase markAsReadUseCase;
  late _MockMarkAllAsReadUseCase markAllAsReadUseCase;

  setUp(() {
    getNotificationsUseCase = _MockGetNotificationsUseCase();
    markAsReadUseCase = _MockMarkNotificationAsReadUseCase();
    markAllAsReadUseCase = _MockMarkAllAsReadUseCase();
  });

  NotificationCubit buildCubit() => NotificationCubit(
        getNotificationsUseCase,
        markAsReadUseCase,
        markAllAsReadUseCase,
      );

  group('NotificationCubit', () {
    blocTest<NotificationCubit, NotificationState>(
      'loadNotifications emits loading then success and stores first page',
      build: () {
        when(
          () => getNotificationsUseCase(page: any(named: 'page'), limit: any(named: 'limit')),
        ).thenAnswer(
          (_) async => [
            _notification(id: '1', status: NotificationDeliveryStatus.pending),
            _notification(id: '2', status: NotificationDeliveryStatus.delivered),
          ],
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadNotifications(),
      expect: () => [
        isA<NotificationState>()
            .having((s) => s.status, 'status', NotificationRequestStatus.loading)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<NotificationState>()
            .having((s) => s.status, 'status', NotificationRequestStatus.success)
            .having((s) => s.notifications.length, 'notifications.length', 2)
            .having((s) => s.unreadCount, 'unreadCount', 1)
            .having((s) => s.hasMorePages, 'hasMorePages', false),
      ],
      verify: (_) {
        verify(() => getNotificationsUseCase(page: 1, limit: 10)).called(1);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'loadNotifications emits empty state when the first page is empty',
      build: () {
        when(
          () => getNotificationsUseCase(page: any(named: 'page'), limit: any(named: 'limit')),
        ).thenAnswer((_) async => []);
        return buildCubit();
      },
      act: (cubit) => cubit.loadNotifications(),
      expect: () => [
        isA<NotificationState>().having(
          (s) => s.status,
          'status',
          NotificationRequestStatus.loading,
        ),
        isA<NotificationState>()
            .having((s) => s.status, 'status', NotificationRequestStatus.empty)
            .having((s) => s.notifications, 'notifications', isEmpty),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'loadMoreNotifications appends the next page when more data exists',
      seed: () => NotificationState(
        notifications: [
          _notification(id: '1', status: NotificationDeliveryStatus.pending),
        ],
        status: NotificationRequestStatus.success,
        currentPage: 1,
        hasMorePages: true,
      ),
      build: () {
        when(
          () => getNotificationsUseCase(page: any(named: 'page'), limit: any(named: 'limit')),
        ).thenAnswer(
          (_) async => [
            _notification(id: '2', status: NotificationDeliveryStatus.delivered),
          ],
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadMoreNotifications(),
      expect: () => [
        isA<NotificationState>()
            .having((s) => s.status, 'status', NotificationRequestStatus.success)
            .having((s) => s.notifications.length, 'notifications.length', 2)
            .having((s) => s.currentPage, 'currentPage', 2),
      ],
      verify: (_) {
        verify(() => getNotificationsUseCase(page: 2, limit: 10)).called(1);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'markAsRead replaces the matching notification in state',
      seed: () => NotificationState(
        notifications: [
          _notification(id: '1', status: NotificationDeliveryStatus.pending),
          _notification(id: '2', status: NotificationDeliveryStatus.pending),
        ],
        status: NotificationRequestStatus.success,
      ),
      build: () {
        when(() => markAsReadUseCase('2')).thenAnswer(
          (_) async => _notification(
            id: '2',
            status: NotificationDeliveryStatus.delivered,
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.markAsRead('2'),
      expect: () => [
        isA<NotificationState>()
            .having((s) => s.notifications[1].deliveryStatus, 'updated status', NotificationDeliveryStatus.delivered)
            .having((s) => s.unreadCount, 'unreadCount', 1),
      ],
      verify: (_) {
        verify(() => markAsReadUseCase('2')).called(1);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'reset returns the initial state',
      seed: () => NotificationState(
        notifications: [
          _notification(id: '1', status: NotificationDeliveryStatus.pending),
        ],
        status: NotificationRequestStatus.error,
        errorMessage: 'boom',
      ),
      build: buildCubit,
      act: (cubit) => cubit.reset(),
      expect: () => [
        isA<NotificationState>()
            .having((s) => s.status, 'status', NotificationRequestStatus.initial)
            .having((s) => s.notifications, 'notifications', isEmpty),
      ],
    );
  });
}