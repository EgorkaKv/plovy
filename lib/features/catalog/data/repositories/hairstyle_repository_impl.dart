import 'package:injectable/injectable.dart';
import 'package:plovy/features/catalog/data/datasources/hairstyle_local_datasource.dart';
import 'package:plovy/features/catalog/data/datasources/hairstyle_remote_datasource.dart';
import 'package:plovy/features/catalog/domain/repositories/hairstyle_repository.dart';

@LazySingleton(as: HairstyleRepository)
class HairstyleRepositoryImpl implements HairstyleRepository {
  HairstyleRepositoryImpl(this._remote, this._local);

  final HairstyleRemoteDataSource _remote;
  final HairstyleLocalDataSource _local;

  @override
  Future<HairstyleResult> getHairstyles() async {
    try {
      final data = await _remote.fetchHairstyles();
      await _local.saveHairstyles(data);
      return HairstyleResult(
        hairstyles: data,
        isFromCache: false,
        isStale: false,
      );
    } catch (_) {
      final cached = _local.getCachedHairstyles();
      if (cached != null) {
        return HairstyleResult(
          hairstyles: cached,
          isFromCache: true,
          isStale: _local.isCacheStale(),
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> clearCache() => _local.clearCache();
}
