import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/Core/network/app_exception.dart';
import 'package:frontend/features/authentication/domain/entities/account_entity.dart';
import 'package:frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:frontend/features/authentication/domain/usecases/login_usecase.dart';
import 'package:frontend/features/authentication/domain/usecases/register_usecase.dart';
import 'package:frontend/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/authentication/presentation/cubit/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUsecase extends Mock
    implements RegisterUsecase {}

class MockLoginUsecase extends Mock
    implements LoginUsecase {}

class MockAuthRepository extends Mock
    implements AuthRepository {}

void main() {
  late AuthCubit cubit;
  late MockRegisterUsecase register;
  late MockLoginUsecase login;
  late MockAuthRepository repository;

  const account = AccountEntity(
    accountId: '1',
    displayName: 'John',
    email: 'john@test.com',
    role: 'customer',
  );

  setUp(() {
    register = MockRegisterUsecase();
    login = MockLoginUsecase();
    repository = MockAuthRepository();

    cubit = AuthCubit(
      register,
      login,
      repository,
    );
  });

  blocTest<AuthCubit, AuthState>(
    'login success',
    build: () {
      when(
        () => login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => account);

      return cubit;
    },
    act: (cubit) => cubit.login(
      email: 'john@test.com',
      password: '12345678',
    ),
    expect: () => [
      isA<AuthState>().having(
        (s) => s.status,
        'status',
        AuthStatus.loading,
      ),
      isA<AuthState>()
          .having(
            (s) => s.status,
            'status',
            AuthStatus.authenticated,
          )
          .having(
            (s) => s.account,
            'account',
            account,
          ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'login failure',
    build: () {
      when(
        () => login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        AppException(
          message: 'Invalid credentials',
        ),
      );

      return cubit;
    },
    act: (cubit) => cubit.login(
      email: 'wrong@test.com',
      password: 'wrong',
    ),
    expect: () => [
      isA<AuthState>().having(
        (s) => s.status,
        'status',
        AuthStatus.loading,
      ),
      isA<AuthState>()
          .having(
            (s) => s.status,
            'status',
            AuthStatus.error,
          )
          .having(
            (s) => s.errorMessage,
            'error',
            'Invalid credentials',
          ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'initialize authenticated',
    build: () {
      when(
        () => repository.tryRestoreSession(),
      ).thenAnswer((_) async => true);

      return cubit;
    },
    act: (cubit) => cubit.initialize(),
    expect: () => [
      isA<AuthState>().having(
        (s) => s.status,
        'status',
        AuthStatus.loading,
      ),
      isA<AuthState>().having(
        (s) => s.status,
        'status',
        AuthStatus.authenticated,
      ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'logout resets state',
    build: () {
      when(() => repository.logout())
          .thenAnswer((_) async {});

      return cubit;
    },
    act: (cubit) => cubit.logout(),
    expect: () => [
      isA<AuthState>().having(
        (s) => s.status,
        'status',
        AuthStatus.unauthenticated,
      ),
    ],
  );
}
