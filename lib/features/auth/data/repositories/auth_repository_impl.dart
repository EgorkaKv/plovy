import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';

import 'package:plovy/core/storage/storage_service.dart';
import 'package:plovy/features/auth/domain/entities/user.dart';
import 'package:plovy/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._storageService);

  final StorageService _storageService;

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    final String passwordHash = _hashPassword(password);
    await _storageService.saveUser(email: email, password: passwordHash);
  }

  @override
  Future<User> login({required String email, required String password}) async {
    final ({String email, String password})? savedUser =
        _storageService.getUser();

    if (savedUser == null) {
      throw Exception('User is not registered');
    }

    final String passwordHash = _hashPassword(password);

    if (savedUser.email != email || savedUser.password != passwordHash) {
      throw Exception('Invalid email or password');
    }

    await _storageService.saveSession(email: savedUser.email);

    return User(email: savedUser.email, password: savedUser.password);
  }

  @override
  Future<User?> getCurrentUser() async {
    final String? sessionEmail = _storageService.getSessionEmail();
    if (sessionEmail == null) {
      return null;
    }

    final ({String email, String password})? savedUser =
        _storageService.getUser();

    if (savedUser == null) {
      return null;
    }

    if (savedUser.email != sessionEmail) {
      return null;
    }

    return User(email: savedUser.email, password: savedUser.password);
  }

  @override
  Future<void> logout() async {
    await _storageService.clearSession();
  }

  String _hashPassword(String rawPassword) {
    return sha256.convert(utf8.encode(rawPassword)).toString();
  }
}
