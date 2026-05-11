import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    final List<ConnectivityResult> results =
        await _connectivity.checkConnectivity();
    return results.any((ConnectivityResult r) => r != ConnectivityResult.none);
  }

  Stream<bool> get statusStream => _connectivity.onConnectivityChanged.map(
    (List<ConnectivityResult> results) =>
        results.any((ConnectivityResult r) => r != ConnectivityResult.none),
  );
}
