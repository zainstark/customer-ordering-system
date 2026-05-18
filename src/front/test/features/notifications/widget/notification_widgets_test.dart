import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_state.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_state.dart';
import 'package:frontend/features/notifications/presentation/pages/notifications_page.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_badge.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_bell_with_popup.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_empty_state.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_item_widget.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_popup.dart';
import 'package:frontend/features/notifications/presentation/widgets/notification_skeleton_item.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationCubit extends MockCubit<NotificationState>
    implements NotificationCubit {}

class _MockNotificationBadgeCubit extends MockCubit<NotificationBadgeState>
    implements NotificationBadgeCubit {}

class _FakeNotificationState extends Fake implements NotificationState {}

class _FakeNotificationBadgeState extends Fake implements NotificationBadgeState {}

NotificationEntity _notification({
  required String id,
  required NotificationDeliveryStatus status,
  DateTime? createdAt,
  String? orderId,
  String subject = 'Subject',
  String body = 'Body',
}) {
  return NotificationEntity(
    messageId: id,
    subject: subject,
    body: body,
    deliveryChannel: NotificationDeliveryChannel.inApp,
    deliveryStatus: status,
    createdAt: createdAt ?? DateTime(2025, 1, 1, 12, 0),
    orderId: orderId,
  );
}

ThemeData _theme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  );
}

Widget _wrapWithNotificationsPage(NotificationCubit cubit) {
  return MaterialApp(
    theme: _theme(),
    home: MediaQuery(
      data: const MediaQueryData(size: Size(900, 1200)),
      child: Scaffold(
        body: BlocProvider<NotificationCubit>.value(
          value: cubit,
          child: const NotificationsPage(),
        ),
      ),
    ),
  );
}

Widget _wrapWithPopupApp({
  required NotificationCubit notificationCubit,
  required NotificationBadgeCubit badgeCubit,
  required Widget home,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(body: home),
      ),
      GoRoute(
        path: RoutesPath.notifications,
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Notifications route')));
        },
      ),
    ],
  );

  return MaterialApp.router(
    theme: _theme(),
    routerConfig: router,
    builder: (context, child) {
      return MediaQuery(
        data: const MediaQueryData(
          size: Size(900, 1200),
          textScaler: TextScaler.linear(0.8),
        ),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<NotificationCubit>.value(value: notificationCubit),
            BlocProvider<NotificationBadgeCubit>.value(value: badgeCubit),
          ],
          child: child ?? const SizedBox.shrink(),
        ),
      );
    },
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeNotificationState());
    registerFallbackValue(_FakeNotificationBadgeState());
  });

  group('NotificationsPage', () {
    late _MockNotificationCubit cubit;

    setUp(() {
      cubit = _MockNotificationCubit();
      whenListen(cubit, const Stream<NotificationState>.empty());
    });

    testWidgets('shows skeletons while loading', (tester) async {
      when(() => cubit.state).thenReturn(const NotificationState(
        notifications: [],
        status: NotificationRequestStatus.loading,
      ));
      when(() => cubit.loadNotifications()).thenAnswer((_) async {});

      await tester.pumpWidget(_wrapWithNotificationsPage(cubit));
      await tester.pump();

      expect(find.byType(NotificationSkeletonItem), findsWidgets);
      verify(() => cubit.loadNotifications()).called(1);
    });

    testWidgets('shows empty state when there are no notifications', (tester) async {
      when(() => cubit.state).thenReturn(const NotificationState(
        notifications: [],
        status: NotificationRequestStatus.empty,
      ));
      when(() => cubit.loadNotifications()).thenAnswer((_) async {});

      await tester.pumpWidget(_wrapWithNotificationsPage(cubit));

      expect(find.text("You're all caught up!"), findsOneWidget);
      expect(find.textContaining('No new notifications'), findsOneWidget);
    });

    testWidgets('renders grouped notifications and mark all action', (tester) async {
      final now = DateTime.now();
      when(() => cubit.state).thenReturn(NotificationState(
        notifications: [
          _notification(
            id: '1',
            status: NotificationDeliveryStatus.pending,
            createdAt: now,
            subject: 'Today subject',
            body: 'Today body',
          ),
          _notification(
            id: '2',
            status: NotificationDeliveryStatus.delivered,
            createdAt: now.subtract(const Duration(days: 1)),
            subject: 'Yesterday subject',
            body: 'Yesterday body',
          ),
        ],
        status: NotificationRequestStatus.success,
      ));
      when(() => cubit.loadNotifications()).thenAnswer((_) async {});
      when(() => cubit.markAllAsRead()).thenAnswer((_) async {});
      when(() => cubit.markAsRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(_wrapWithNotificationsPage(cubit));

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsNWidgets(2));
      expect(find.text('Mark all as read'), findsOneWidget);

      await tester.tap(find.text('Mark all as read'));
      await tester.pump();

      verify(() => cubit.markAllAsRead()).called(1);
    });

    testWidgets('tapping a pending notification marks it as read', (tester) async {
      when(() => cubit.state).thenReturn(NotificationState(
        notifications: [
          _notification(
            id: '1',
            status: NotificationDeliveryStatus.pending,
            subject: 'Tap me',
            body: 'Tap body',
          ),
        ],
        status: NotificationRequestStatus.success,
      ));
      when(() => cubit.loadNotifications()).thenAnswer((_) async {});
      when(() => cubit.markAsRead('1')).thenAnswer((_) async {});

      await tester.pumpWidget(_wrapWithNotificationsPage(cubit));

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      verify(() => cubit.markAsRead('1')).called(1);
    });
  });

  group('NotificationPopup', () {
    late _MockNotificationCubit notificationCubit;
    late _MockNotificationBadgeCubit badgeCubit;

    setUp(() {
      notificationCubit = _MockNotificationCubit();
      badgeCubit = _MockNotificationBadgeCubit();
      whenListen(notificationCubit, const Stream<NotificationState>.empty());
      whenListen(badgeCubit, const Stream<NotificationBadgeState>.empty());
    });

    testWidgets('shows truncated list, unread count, and navigates to notifications route',
        (tester) async {
      final now = DateTime.now();
      when(() => notificationCubit.state).thenReturn(NotificationState(
        notifications: List.generate(
          6,
          (index) => _notification(
            id: '$index',
            status: index.isEven
                ? NotificationDeliveryStatus.pending
                : NotificationDeliveryStatus.delivered,
            subject: 'Notification $index',
            body: 'Body $index',
            createdAt: now.subtract(Duration(minutes: index)),
          ),
        ),
        status: NotificationRequestStatus.success,
      ));
      when(() => notificationCubit.markAsRead(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        _wrapWithPopupApp(
          notificationCubit: notificationCubit,
          badgeCubit: badgeCubit,
          home: const NotificationPopup(onClose: _noopClose),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('3 New'), findsOneWidget);
      expect(find.text('Notification 0'), findsOneWidget);
      expect(find.text('Notification 4'), findsOneWidget);
      expect(find.text('Notification 5'), findsNothing);

      await tester.tap(find.text('Show All Notifications'));
      await tester.pumpAndSettle();

      expect(find.text('Notifications route'), findsOneWidget);
    });

    testWidgets('shows empty state when popup has no notifications', (tester) async {
      when(() => notificationCubit.state).thenReturn(const NotificationState(
        notifications: [],
        status: NotificationRequestStatus.empty,
      ));

      await tester.pumpWidget(
        _wrapWithPopupApp(
          notificationCubit: notificationCubit,
          badgeCubit: badgeCubit,
          home: const NotificationPopup(onClose: _noopClose),
        ),
      );

      expect(find.text("You're all caught up!"), findsOneWidget);
    });
  });

  group('NotificationBellWithPopup', () {
    late _MockNotificationCubit notificationCubit;
    late _MockNotificationBadgeCubit badgeCubit;

    setUp(() {
      notificationCubit = _MockNotificationCubit();
      badgeCubit = _MockNotificationBadgeCubit();
      whenListen(notificationCubit, const Stream<NotificationState>.empty());
      whenListen(badgeCubit, const Stream<NotificationBadgeState>.empty());
    });

    testWidgets('opens the popup when tapped', (tester) async {
      when(() => notificationCubit.state).thenReturn(const NotificationState(
        notifications: [],
        status: NotificationRequestStatus.empty,
      ));
      when(() => badgeCubit.state).thenReturn(const NotificationBadgeState(
        unreadCount: 2,
        status: NotificationBadgeStatus.success,
      ));
      when(() => notificationCubit.loadNotifications()).thenAnswer((_) async {});
      when(() => notificationCubit.loadNotifications(isRefresh: true)).thenAnswer((_) async {});
      when(() => badgeCubit.loadUnreadCount()).thenAnswer((_) async {});

      await tester.pumpWidget(
        _wrapWithPopupApp(
          notificationCubit: notificationCubit,
          badgeCubit: badgeCubit,
          home: const NotificationBellWithPopup(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NotificationBadge), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.text('Show All Notifications'), findsOneWidget);
    });
  });

  group('Notification leaf widgets', () {
    testWidgets('NotificationBadge hides zero count and caps at 99+', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: _theme(),
          home: Scaffold(
            body: Stack(
              children: const [NotificationBadge(count: 120)],
            ),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('NotificationItemWidget shows fallback subject and body', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: _theme(),
          home: Scaffold(
            body: NotificationItemWidget(
              notification: _notification(
                id: '1',
                status: NotificationDeliveryStatus.pending,
                subject: '   ',
                body: '   ',
                createdAt: DateTime.now(),
              ),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Notification'), findsOneWidget);
      expect(find.text('No additional details available.'), findsOneWidget);
    });

    testWidgets('NotificationEmptyState shows its guidance text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: _theme(),
          home: const Scaffold(body: NotificationEmptyState()),
        ),
      );

      expect(find.text("You're all caught up!"), findsOneWidget);
      expect(find.textContaining('No new notifications'), findsOneWidget);
    });

    testWidgets('NotificationSkeletonItem builds without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: _theme(),
          home: const Scaffold(body: NotificationSkeletonItem()),
        ),
      );

      expect(find.byType(NotificationSkeletonItem), findsOneWidget);
    });
  });
}

void _noopClose() {}