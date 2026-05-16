import '../../domain/entities/account_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AccountEntity? account;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.account,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AccountEntity? account,
    String? errorMessage,
  }) {
    return AuthState(
      status:       status       ?? this.status,
      account:      account      ?? this.account,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
