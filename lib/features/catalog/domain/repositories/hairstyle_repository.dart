import 'package:plovy/features/catalog/domain/entities/hairstyle.dart';

class HairstyleResult {
  const HairstyleResult({
    required this.hairstyles,
    required this.isFromCache,
    required this.isStale,
  });

  final List<Hairstyle> hairstyles;
  final bool isFromCache;
  final bool isStale;
}

abstract class HairstyleRepository {
  Future<HairstyleResult> getHairstyles();
  Future<void> clearCache();
}
