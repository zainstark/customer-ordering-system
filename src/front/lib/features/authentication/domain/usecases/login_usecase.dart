import '../entities/account_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _repository;
  LoginUsecase(this._repository);

  Future<AccountEntity> call({
    required String email,
    required String password,
  }) => _repository.login(email: email, password: password);
}
