/// lib/features/ble/domain/ble_repository.dart
import 'dart:typed_data';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Абстракция для BLE-операций (сканирование, подключение, чтение/подписка)
abstract class BleRepository {
  /// Стрим статуса BLE (on/off, unauthorized и пр.)
  Stream<BleStatus> get statusStream;

  /// Стрим обновлений состояния подключения для устройства [deviceId].
  Stream<ConnectionStateUpdate> connectionStateStream(String deviceId);

  /// Запрос очистки GATT-кэша для устройства [deviceId]
  Future<void> clearGattCache(String deviceId);

  /// Запрос MTU для устройства [deviceId], возвращает установленное значение.
  Future<int> requestMtu(String deviceId, int mtu);

  /// Подписывается на [characteristicUuid] сервиса [serviceUuid] для устройства [deviceId].
  Stream<Uint8List> subscribeToCharacteristic({
    required String deviceId,
    required Uuid serviceUuid,
    required Uuid characteristicUuid,
  });

  /// Запись с подтверждением в характеристику
  Future<void> writeCharacteristicWithResponse({
    required QualifiedCharacteristic characteristic,
    required Uint8List value,
  });

  /// Отключает текущее подключение.
  Future<void> disconnect(String deviceId);
}
