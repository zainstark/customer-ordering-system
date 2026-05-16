import '../entities/account_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository _repository;
  RegisterUsecase(this._repository);

  Future<AccountEntity> call({
    required String displayName,
    required String email,
    required String password,
  }) => _repository.register(
        displayName: displayName,
        email: email,
        password: password,
      );
}
