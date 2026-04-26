import 'package:injectable/injectable.dart';

import 'package:plovy/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {}
}
