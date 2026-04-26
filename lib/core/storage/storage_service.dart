import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const String _emailKey = 'user_email';
  static const String _passwordKey = 'user_password_hash';

  Future<void> saveUser({
    required String email,
    required String password,
  }) async {
    await _prefs.setString(_emailKey, email);
    await _prefs.setString(_passwordKey, password);
  }

  ({String email, String password})? getUser() {
    final String? email = _prefs.getString(_emailKey);
    final String? password = _prefs.getString(_passwordKey);

    if (email == null || password == null) {
      return null;
    }

    return (email: email, password: password);
  }

  Future<void> clearUser() async {
    await _prefs.remove(_emailKey);
    await _prefs.remove(_passwordKey);
  }
}
