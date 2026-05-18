import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/authentication/presentation/cubit/auth_state.dart';
import 'package:frontend/features/authentication/presentation/screens/signup_screen.dart';
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
      () => cubit.register(
        displayName:
            any(named: 'displayName'),
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
    'renders signup UI',
    (tester) async {
      await pumpDesktopWidget(
        tester,
        const SignupScreen(),
      );

      expect(
        find.text('Create an account'),
        findsOneWidget,
      );

      expect(
        find.text('Create Account'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows validation errors',
    (tester) async {
      await pumpDesktopWidget(
        tester,
        const SignupScreen(),
      );

      await tester.tap(
        find.text('Create Account'),
      );

      await tester.pump();

      expect(
        find.text(
          'Please enter your name',
        ),
        findsOneWidget,
      );

      expect(
        find.text(
          'Please enter your email',
        ),
        findsOneWidget,
      );

      expect(
        find.text(
          'Please enter a password',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'password validation',
    (tester) async {
      await pumpDesktopWidget(
        tester,
        const SignupScreen(),
      );

      await tester.enterText(
        find.byType(TextFormField).at(2),
        '123',
      );

      await tester.tap(
        find.text('Create Account'),
      );

      await tester.pump();

      expect(
        find.text(
          'Password must be at least 8 characters',
        ),
        findsOneWidget,
      );
    },
  );
}
