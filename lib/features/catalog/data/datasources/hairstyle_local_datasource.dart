import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:plovy/features/catalog/data/models/hairstyle_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kCacheKey = 'hairstyles_cache';
const String _kCacheTsKey = 'hairstyles_cache_ts';
const Duration _kTtl = Duration(hours: 24);

@lazySingleton
class HairstyleLocalDataSource {
  HairstyleLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  Future<void> saveHairstyles(List<HairstyleModel> hairstyles) async {
    final encoded = jsonEncode(hairstyles.map((h) => h.toJson()).toList());
    await _prefs.setString(_kCacheKey, encoded);
    await _prefs.setInt(
      _kCacheTsKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<HairstyleModel>? getCachedHairstyles() {
    final raw = _prefs.getString(_kCacheKey);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => HairstyleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  DateTime? getCacheTimestamp() {
    final ms = _prefs.getInt(_kCacheTsKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  bool isCacheStale() {
    final ts = getCacheTimestamp();
    if (ts == null) return true;
    return DateTime.now().difference(ts) > _kTtl;
  }

  Future<void> clearCache() async {
    await _prefs.remove(_kCacheKey);
    await _prefs.remove(_kCacheTsKey);
  }
}
