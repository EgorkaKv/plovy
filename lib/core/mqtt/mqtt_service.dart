import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:plovy/core/mqtt/mqtt_config.dart';

@lazySingleton
class MqttService {
  MqttServerClient? _client;

  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  Stream<bool> get statusStream => _statusController.stream;
  Stream<String> get messageStream => _messageController.stream;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> connect() async {
    if (isConnected) return;

    final MqttServerClient client = MqttServerClient.withPort(
      mqttHost,
      mqttClientId,
      mqttPort,
    );

    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;

    final MqttConnectMessage connectMessage = MqttConnectMessage()
        .withClientIdentifier(mqttClientId)
        .authenticateAs(mqttUsername, mqttPassword)
        .startClean();
    client.connectionMessage = connectMessage;

    try {
      await client.connect();
    } catch (_) {
      client.disconnect();
      return;
    }

    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      client.disconnect();
      return;
    }

    _client = client;
    client.subscribe(mqttTopic, MqttQos.atLeastOnce);
    client.updates!.listen(_onMessage);
  }

  void _onConnected() {
    _statusController.add(true);
  }

  void _onDisconnected() {
    _statusController.add(false);
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final MqttReceivedMessage<MqttMessage> msg in messages) {
      final MqttPublishMessage pubMsg = msg.payload as MqttPublishMessage;
      final String json = String.fromCharCodes(pubMsg.payload.message);
      _messageController.add(json);
    }
  }

  void disconnect() {
    _client?.disconnect();
    _client = null;
  }

  @disposeMethod
  void dispose() {
    disconnect();
    _statusController.close();
    _messageController.close();
  }
}
