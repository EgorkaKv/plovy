import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HttpService {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}
