import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/authentication/domain/entities/account_entity.dart';
import 'package:frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:frontend/features/authentication/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository repository;

  const account = AccountEntity(
    accountId: '1',
    displayName: 'John',
    email: 'john@test.com',
    role: 'customer',
  );

  setUp(() {
    repository = MockAuthRepository();
    usecase = LoginUsecase(repository);
  });

  test('calls repository login', () async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => account);

    final result = await usecase(
      email: 'john@test.com',
      password: 'password123',
    );

    expect(result, account);

    verify(
      () => repository.login(
        email: 'john@test.com',
        password: 'password123',
      ),
    ).called(1);
  });
}
