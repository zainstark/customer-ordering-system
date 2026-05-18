import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/authentication/presentation/cubit/auth_state.dart';
import 'package:frontend/features/authentication/presentation/screens/login_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthCubit extends Mock
    implements AuthCubit {}

void main() {
  late MockAuthCubit cubit;

  setUp(() {
    cubit = MockAuthCubit();

    when(() => cubit.state)
        .thenReturn(const AuthState());

    when(() => cubit.stream)
        .thenAnswer((_) => const Stream.empty());

    when(
      () => cubit.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> pumpDesktopWidget(
    WidgetTester tester,
    Widget child,
  ) async {
    tester.view.physicalSize =
        const Size(1600, 1200);

    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthCubit>.value(
          value: cubit,
          child: child,
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets(
    'renders login UI',
    (tester) async {
      await pumpDesktopWidget(
        tester,
        const LoginScreen(),
      );

      expect(
        find.text('Welcome Back'),
        findsOneWidget,
      );

      expect(
        find.text('Sign In'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows validation errors',
    (tester) async {
      await pumpDesktopWidget(
        tester,
        const LoginScreen(),
      );

      await tester.tap(
        find.text('Sign In'),
      );

      await tester.pump();

      expect(
        find.text(
          'Please enter your email',
        ),
        findsOneWidget,
      );

      expect(
        find.text(
          'Please enter your password',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'invalid email validation',
    (tester) async {
      await pumpDesktopWidget(
        tester,
        const LoginScreen(),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'bademail',
      );

      await tester.tap(
        find.text('Sign In'),
      );

      await tester.pump();

      expect(
        find.text(
          'Please enter a valid email',
        ),
        findsOneWidget,
      );
    },
  );
}
