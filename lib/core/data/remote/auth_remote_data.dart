
import '../../network/odooClint.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this.client);

  final Odooclint client;

  Future<bool> signIn({
    required String database,
    required String username,
    required String password,
  }) {
    return client.signIn(
      database: database,
      username: username,
      password: password,
    );
  }

  Future<bool> checkInternalUser() async {
    final currentUserId = client.userId;

    if (client.sessionCookie == null || currentUserId == null) {
      return false;
    }

    final result = await client.callKw(
      model: 'res.users',
      method: 'has_group',
      args: [
        [currentUserId],
        'base.group_user',
      ],
    );

    if (result is! bool) {
      throw Exception('Invalid Odoo group check response');
    }

    return result;

  }

  void logout() {
    client.logout();
  }
}
