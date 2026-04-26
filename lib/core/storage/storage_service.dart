import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const String _emailKey = 'user_email';
  static const String _passwordHashKey = 'user_password_hash';

  Future<void> saveUser({
    required String email,
    required String passwordHash,
  }) async {
    await _prefs.setString(_emailKey, email);
    await _prefs.setString(_passwordHashKey, passwordHash);
  }

  ({String email, String passwordHash})? getUser() {
    final String? email = _prefs.getString(_emailKey);
    final String? passwordHash = _prefs.getString(_passwordHashKey);

    if (email == null || passwordHash == null) {
      return null;
    }

    return (email: email, passwordHash: passwordHash);
  }

  Future<void> clearUser() async {
    await _prefs.remove(_emailKey);
    await _prefs.remove(_passwordHashKey);
  }
}
