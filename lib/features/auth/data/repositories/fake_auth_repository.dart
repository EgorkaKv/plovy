import 'package:plovy/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {}

  @override
  Future<Never> login({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<Never> getCurrentUser() async {
    throw UnimplementedError();
  }
}
