import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/account_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  AuthRepositoryImpl(this._dataSource);

  @override
  Future<AccountEntity> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final data = await _dataSource.register(
      displayName: displayName,
      email: email,
      password: password,
    );
    return AccountModel.fromTokenPayload(data);
  }

  @override
  Future<AccountEntity> login({
    required String email,
    required String password,
  }) async {
    final data = await _dataSource.login(email: email, password: password);
    return AccountModel.fromTokenPayload(data);
  }

  @override
  Future<void> logout() => _dataSource.logout();

  @override
  Future<bool> tryRestoreSession() => _dataSource.tryRestoreSession();
}
