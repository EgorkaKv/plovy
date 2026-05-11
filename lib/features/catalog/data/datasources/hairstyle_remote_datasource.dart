import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:plovy/core/network/http_service.dart';
import 'package:plovy/features/catalog/data/config/catalog_config.dart';
import 'package:plovy/features/catalog/data/models/hairstyle_model.dart';

@lazySingleton
class HairstyleRemoteDataSource {
  HairstyleRemoteDataSource(this._httpService);

  final HttpService _httpService;

  Future<List<HairstyleModel>> fetchHairstyles() async {
    final response = await _httpService.dio.get<dynamic>(hairstyleApiUrl);

    if (response.statusCode != 200) {
      throw Exception('Failed to load hairstyles: ${response.statusCode}');
    }

    // GitHub Raw returns Content-Type: text/plain, so Dio keeps the body as a
    // String instead of decoding it. Handle both cases.
    final Map<String, dynamic> body = response.data is String
        ? jsonDecode(response.data as String) as Map<String, dynamic>
        : response.data as Map<String, dynamic>;

    final data = body['data'] as List<dynamic>;
    return data
        .map((e) => HairstyleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
