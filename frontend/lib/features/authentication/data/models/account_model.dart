import '../../domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.accountId,
    required super.displayName,
    required super.email,
    required super.role,
  });

  factory AccountModel.fromTokenPayload(Map<String, dynamic> json) {
    return AccountModel(
      accountId:   json['account_id']   ?? '',
      displayName: json['display_name'] ?? '',
      email:       json['email']        ?? '',
      role:        json['role']         ?? 'customer',
    );
  }
}
