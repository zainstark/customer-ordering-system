import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/Core/injector/injector.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_badge_state.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubit/notification_state.dart';
import 'package:frontend/features/shell/presentation/widgets/app_shell_scaffold.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationCubit extends MockCubit<NotificationState>
    implements NotificationCubit {}

class _MockNotificationBadgeCubit extends MockCubit<NotificationBadgeState>
    implements NotificationBadgeCubit {}

void main() {
  late _MockNotificationCubit notificationCubit;
  late _MockNotificationBadgeCubit badgeCubit;

  setUp(() {
    notificationCubit = _MockNotificationCubit();
    badgeCubit = _MockNotificationBadgeCubit();

    when(() => notificationCubit.state).thenReturn(
      const NotificationState(
        notifications: [],
        status: NotificationRequestStatus.initial,
      ),
    );
    whenListen(notificationCubit, const Stream<NotificationState>.empty());
    when(
      () => notificationCubit.loadNotifications(
        page: any(named: 'page'),
        isRefresh: any(named: 'isRefresh'),
      ),
    ).thenAnswer((_) async {});

    when(() => badgeCubit.state).thenReturn(
      const NotificationBadgeState(
        unreadCount: 0,
        status: NotificationBadgeStatus.initial,
      ),
    );
    whenListen(badgeCubit, const Stream<NotificationBadgeState>.empty());
    when(() => badgeCubit.loadUnreadCount()).thenAnswer((_) async {});

    getIt.reset();
    getIt.registerFactory<NotificationCubit>(() => notificationCubit);
    getIt.registerFactory<NotificationBadgeCubit>(() => badgeCubit);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpShell(
    WidgetTester tester, {
    required double width,
    required String currentPath,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: AppShellScaffold(
            currentPath: currentPath,
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  testWidgets('desktop layout shows top nav and hides bottom nav', (
    tester,
  ) async {
    await pumpShell(tester, width: 1200, currentPath: RoutesPath.menu);
    await tester.pump();

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
  });

  testWidgets('tablet/mobile layout shows bottom nav and hides top links', (
    tester,
  ) async {
    await pumpShell(tester, width: 800, currentPath: RoutesPath.menu);
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.byType(InkWell), findsOneWidget);
  });

  testWidgets('top nav marks current path as selected on desktop', (
    tester,
  ) async {
    await pumpShell(tester, width: 1200, currentPath: RoutesPath.orders);
    await tester.pump();

    final theme = ThemeData();
    final ordersText = tester.widget<Text>(find.text('Orders'));
    final menuText = tester.widget<Text>(find.text('Menu'));

    expect(ordersText.style?.color, theme.colorScheme.primary);
    expect(menuText.style?.color, theme.colorScheme.onSurfaceVariant);
  });

  testWidgets('bottom nav selected index follows current path', (tester) async {
    await pumpShell(tester, width: 700, currentPath: RoutesPath.cart);
    await tester.pump();

    final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(nav.selectedIndex, 2);
  });

  testWidgets('bottom nav falls back to menu index for unknown paths', (
    tester,
  ) async {
    await pumpShell(tester, width: 700, currentPath: '/unknown');
    await tester.pump();

    final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(nav.selectedIndex, 0);
  });
}
