// lib/core/models/telemetry_data.dart

class TelemetryData {
  final int? rpm;
  final int? speed;
  final int? coolantTemp;

  const TelemetryData({this.rpm, this.speed, this.coolantTemp});

  /// Создаёт новую копию, заменяя только те поля, что не null в аргументах
  TelemetryData copyWith({int? rpm, int? speed, int? coolantTemp}) {
    return TelemetryData(
      rpm: rpm ?? this.rpm,
      speed: speed ?? this.speed,
      coolantTemp: coolantTemp ?? this.coolantTemp,
    );
  }

  /// Преобразует объект в Map для JSON‐сериализации
  Map<String, dynamic> toJson() {
    return {'rpm': rpm, 'speed': speed, 'coolantTemp': coolantTemp};
  }

  @override
  String toString() =>
      'TelemetryData(rpm: $rpm, speed: $speed, coolantTemp: $coolantTemp)';
}
