/// lib/features/ble/infrastructure/fake_ble_repository.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../domain/ble_repository.dart';

/// Фейковая реализация BLE для мок-тестирования и запуска на десктопе
class FakeBleRepository implements BleRepository {
  // Контроллеры для стримов
  final _statusController = StreamController<BleStatus>.broadcast();
  final _connectionController =
      StreamController<ConnectionStateUpdate>.broadcast();

  FakeBleRepository() {
    // Имитируем сразу готовый адаптер
    _statusController.add(BleStatus.ready);
  }

  @override
  Stream<BleStatus> get statusStream => _statusController.stream;

  @override
  Future<void> clearGattCache(String deviceId) async {
    // Ничего не делаем
    return;
  }

  @override
  Future<int> requestMtu(String deviceId, int mtu) async {
    // Просто возвращаем запрошенный MTU
    return mtu;
  }

  @override
  Stream<ConnectionStateUpdate> connectionStateStream(String deviceId) {
    // Возвращаем контроллер, предзаполненный состояниями
    return _connectionController.stream;
  }

  @override
  Stream<Uint8List> subscribeToCharacteristic({
    required String deviceId,
    required Uuid serviceUuid,
    required Uuid characteristicUuid,
  }) {
    // Имитируем поток данных: каждые 500 мс отправляем фиктивный PID-ответ
    return Stream<Uint8List>.periodic(const Duration(milliseconds: 500), (
      count,
    ) {
      final raw =
          '41 0C ${((count * 10) % 255).toRadixString(16).padLeft(2, '0')} FF\r';
      return Uint8List.fromList(raw.codeUnits);
    });
  }

  @override
  Future<void> disconnect(String deviceId) async {
    _connectionController.add(
      ConnectionStateUpdate(
        deviceId: deviceId,
        connectionState: DeviceConnectionState.disconnected,
        failure: null,
      ),
    );
  }

  @override
  Future<void> writeCharacteristicWithResponse({
    required QualifiedCharacteristic characteristic,
    required Uint8List value,
  }) {
    // TODO: implement writeCharacteristicWithResponse
    throw UnimplementedError();
  }
}
