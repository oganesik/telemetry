/// lib/core/models/obd_reading.dart
import 'dart:typed_data';
import 'dart:convert';

/// Модель для данных, полученных от OBD-II адаптера
class ObdReading {
  /// Сырая строка ответа (ASCII)
  final String rawData;

  /// Время получения
  final DateTime timestamp;

  ObdReading({
    required this.rawData,
    required this.timestamp,
  });

  /// Фабрика для создания из байтов BLE-уведомления
  factory ObdReading.fromBytes(Uint8List data) {
    // Преобразуем байты в строку (UTF-8 или ASCII)
    final raw = utf8.decode(data, allowMalformed: true).trim();
    return ObdReading(
      rawData: raw,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() => 'ObdReading(rawData: $rawData, timestamp: $timestamp)';
}