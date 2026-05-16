import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';
import '../../../../Core/network/app_exception.dart';

class AuthCubit extends Cubit<AuthState> {
  final RegisterUsecase _register;
  final LoginUsecase    _login;
  final AuthRepository  _repository;

  AuthCubit(this._register, this._login, this._repository)
      : super(const AuthState());

  Future<void> initialize() async {
    emit(state.copyWith(status: AuthStatus.loading));
    final restored = await _repository.tryRestoreSession();
    emit(state.copyWith(
      status: restored ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    ));
  }

  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {

      final account = await _register(
        displayName: displayName,
        email: email,
        password: password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, account: account));
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final account = await _login(email: email, password: password);
      emit(state.copyWith(status: AuthStatus.authenticated, account: account));
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
