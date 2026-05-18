import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/authentication/data/models/account_model.dart';

void main() {
  test('fromTokenPayload parses data correctly', () {
    final model = AccountModel.fromTokenPayload({
      'account_id': '1',
      'display_name': 'John',
      'email': 'john@test.com',
      'role': 'admin',
    });

    expect(model.accountId, '1');
    expect(model.displayName, 'John');
    expect(model.email, 'john@test.com');
    expect(model.role, 'admin');
  });

  test('fallback values work', () {
    final model = AccountModel.fromTokenPayload({});

    expect(model.accountId, '');
    expect(model.displayName, '');
    expect(model.email, '');
    expect(model.role, 'customer');
  });
}
