/// lib/features/ble/infrastructure/flutter_reactive_ble_impl.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:telemetry/core/constants/constants.dart';

import '../domain/ble_repository.dart';

class FlutterReactiveBleImpl implements BleRepository {
  final FlutterReactiveBle _ble;
  StreamSubscription<ConnectionStateUpdate>? _connection;

  FlutterReactiveBleImpl(this._ble);

  @override
  Stream<BleStatus> get statusStream => _ble.statusStream;

  @override
  Stream<ConnectionStateUpdate> connectionStateStream(String deviceId) {
    return _ble.connectToDevice(
      id: deviceId,
      servicesWithCharacteristicsToDiscover: {
        Constants.obdServiceUuid: [
          Constants.obdRxCharacteristicUuid,
          Constants.obdTxCharacteristicUuid,
        ],
      },
    );
  }

  @override
  Stream<Uint8List> subscribeToCharacteristic({
    required String deviceId,
    required Uuid serviceUuid,
    required Uuid characteristicUuid,
  }) {
    final qualified = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: characteristicUuid,
      deviceId: deviceId,
    );
    return _ble
        .subscribeToCharacteristic(qualified)
        .map((data) => Uint8List.fromList(data));
  }

  @override
  Future<void> writeCharacteristicWithResponse({
    required QualifiedCharacteristic characteristic,
    required Uint8List value,
  }) async {
    await _ble.writeCharacteristicWithResponse(characteristic, value: value);
  }

  @override
  Future<void> disconnect(String deviceId) async {
    await _connection?.cancel();
    _connection = null;
  }

  @override
  Future<void> clearGattCache(deviceId) async {
    await _ble.clearGattCache(deviceId);
  }

  @override
  Future<int> requestMtu(String deviceId, int mtu) async {
    return await _ble.requestMtu(deviceId: deviceId, mtu: mtu);
  }
}
