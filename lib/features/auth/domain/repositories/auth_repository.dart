import 'package:plovy/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<void> register({required String email, required String password});

  Future<User> login({required String email, required String password});

  Future<User?> getCurrentUser();

  Future<void> logout();
}
