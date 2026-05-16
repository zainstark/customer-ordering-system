import '../entities/account_entity.dart';

abstract class AuthRepository {
  Future<AccountEntity> register({
    required String displayName,
    required String email,
    required String password,
  });

  Future<AccountEntity> login({
    required String email,
    required String password,
  });

  Future<void> logout();
  Future<bool> tryRestoreSession();
}
