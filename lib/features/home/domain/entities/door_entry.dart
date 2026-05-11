class DoorEntry {
  const DoorEntry({required this.sensorId, required this.timestamp});

  final String sensorId;
  final DateTime timestamp;

  factory DoorEntry.fromJson(Map<String, dynamic> json) {
    return DoorEntry(
      sensorId: json['sensor_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
    );
  }
}
