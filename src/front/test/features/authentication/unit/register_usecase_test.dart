import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/authentication/domain/entities/account_entity.dart';
import 'package:frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:frontend/features/authentication/domain/usecases/register_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository repository;

  const account = AccountEntity(
    accountId: '1',
    displayName: 'John',
    email: 'john@test.com',
    role: 'customer',
  );

  setUp(() {
    repository = MockAuthRepository();
    usecase = RegisterUsecase(repository);
  });

  test('calls repository register', () async {
    when(
      () => repository.register(
        displayName: any(named: 'displayName'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => account);

    final result = await usecase(
      displayName: 'John',
      email: 'john@test.com',
      password: 'password123',
    );

    expect(result, account);
  });
}
