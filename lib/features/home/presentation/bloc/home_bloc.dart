import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:plovy/core/connection/connectivity_service.dart';
import 'package:plovy/core/mqtt/mqtt_service.dart';
import 'package:plovy/features/home/domain/entities/door_entry.dart';

// Events

sealed class HomeEvent {
  const HomeEvent();
}

class HomeStarted extends HomeEvent {
  const HomeStarted();
}

class _HomeMqttMessageReceived extends HomeEvent {
  const _HomeMqttMessageReceived(this.json);
  final String json;
}

class _HomeMqttStatusChanged extends HomeEvent {
  const _HomeMqttStatusChanged({required this.connected});
  final bool connected;
}

class _HomeConnectivityChanged extends HomeEvent {
  const _HomeConnectivityChanged({required this.online});
  final bool online;
}

// State

class HomeState {
  const HomeState({
    this.entries = const [],
    this.isMqttConnected = false,
    this.isOnline = true,
    this.showOfflineWarning = false,
  });

  final List<DoorEntry> entries;
  final bool isMqttConnected;
  final bool isOnline;
  final bool showOfflineWarning;

  int get visitorCount => entries.length;

  HomeState copyWith({
    List<DoorEntry>? entries,
    bool? isMqttConnected,
    bool? isOnline,
    bool? showOfflineWarning,
  }) {
    return HomeState(
      entries: entries ?? this.entries,
      isMqttConnected: isMqttConnected ?? this.isMqttConnected,
      isOnline: isOnline ?? this.isOnline,
      showOfflineWarning: showOfflineWarning ?? this.showOfflineWarning,
    );
  }
}

// Bloc

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._mqttService, this._connectivityService)
    : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<_HomeMqttMessageReceived>(_onMqttMessage);
    on<_HomeMqttStatusChanged>(_onMqttStatus);
    on<_HomeConnectivityChanged>(_onConnectivityChanged);
  }

  final MqttService _mqttService;
  final ConnectivityService _connectivityService;

  StreamSubscription<String>? _messageSubscription;
  StreamSubscription<bool>? _mqttStatusSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    final bool online = await _connectivityService.isConnected();
    emit(state.copyWith(isOnline: online));

    _connectivitySubscription = _connectivityService.statusStream.listen(
      (bool connected) => add(_HomeConnectivityChanged(online: connected)),
    );

    _mqttStatusSubscription = _mqttService.statusStream.listen(
      (bool connected) => add(_HomeMqttStatusChanged(connected: connected)),
    );

    _messageSubscription = _mqttService.messageStream.listen(
      (String json) => add(_HomeMqttMessageReceived(json)),
    );

    if (online) {
      await _mqttService.connect();
    }
  }

  void _onMqttMessage(
    _HomeMqttMessageReceived event,
    Emitter<HomeState> emit,
  ) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(event.json) as Map<String, dynamic>;
      final DoorEntry entry = DoorEntry.fromJson(json);
      emit(state.copyWith(entries: [entry, ...state.entries]));
    } catch (_) {
      // Ignore malformed messages
    }
  }

  void _onMqttStatus(
    _HomeMqttStatusChanged event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(isMqttConnected: event.connected));
  }

  Future<void> _onConnectivityChanged(
    _HomeConnectivityChanged event,
    Emitter<HomeState> emit,
  ) async {
    final bool wasOnline = state.isOnline;

    if (!event.online) {
      emit(state.copyWith(isOnline: false, showOfflineWarning: true));
      emit(state.copyWith(isOnline: false, showOfflineWarning: false));
      return;
    }

    emit(state.copyWith(isOnline: true));

    // Reconnect MQTT when internet is restored
    if (!wasOnline) {
      await _mqttService.connect();
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _mqttStatusSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _mqttService.disconnect();
    return super.close();
  }
}
