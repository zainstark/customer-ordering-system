import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetUnreadCountUseCase extends Mock implements GetUnreadCountUseCase {}

void main() {
  late _MockGetUnreadCountUseCase getUnreadCountUseCase;

  setUp(() {
    getUnreadCountUseCase = _MockGetUnreadCountUseCase();
  });

  NotificationBadgeCubit buildCubit() => NotificationBadgeCubit(getUnreadCountUseCase);

  group('NotificationBadgeCubit', () {
    blocTest<NotificationBadgeCubit, NotificationBadgeState>(
      'loadUnreadCount emits loading then success',
      build: () {
        when(() => getUnreadCountUseCase()).thenAnswer((_) async => 4);
        return buildCubit();
      },
      act: (cubit) => cubit.loadUnreadCount(),
      expect: () => [
        isA<NotificationBadgeState>().having(
          (s) => s.status,
          'status',
          NotificationBadgeStatus.loading,
        ),
        isA<NotificationBadgeState>()
            .having((s) => s.status, 'status', NotificationBadgeStatus.success)
            .having((s) => s.unreadCount, 'unreadCount', 4),
      ],
      verify: (_) {
        verify(() => getUnreadCountUseCase()).called(1);
      },
    );

    blocTest<NotificationBadgeCubit, NotificationBadgeState>(
      'decrementUnreadCount decreases the count only when above zero',
      seed: () => const NotificationBadgeState(
        unreadCount: 1,
        status: NotificationBadgeStatus.success,
      ),
      build: buildCubit,
      act: (cubit) => cubit.decrementUnreadCount(),
      expect: () => [
        isA<NotificationBadgeState>().having(
          (s) => s.unreadCount,
          'unreadCount',
          0,
        ),
      ],
    );

    test('reset returns the initial state', () {
      final cubit = buildCubit();

      cubit.reset();

      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.status, NotificationBadgeStatus.initial);
    });
  });
}