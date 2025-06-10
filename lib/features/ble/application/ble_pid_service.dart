import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:telemetry/core/constants/constants.dart';
import 'package:telemetry/features/ble/domain/ble_repository.dart';

/// Сервис для получения поддерживаемых PID-ов у OBD-адаптера
class BlePidService {
  final BleRepository _repo;

  BlePidService(this._repo);

  /// Отправляет команду 01 00 (0100) и возвращает список поддерживаемых PID
  Future<List<String>> fetchSupportedPids({required String deviceId}) async {
    final rawDataController = StreamController<Uint8List>();
    StreamSubscription<Uint8List>? notificationSub;

    notificationSub = _repo
        .subscribeToCharacteristic(
          serviceUuid: Constants.obdServiceUuid,
          deviceId: deviceId,
          characteristicUuid: Constants.obdTxCharacteristicUuid,
        )
        .listen(
          (data) {
            rawDataController.add(data);
          },
          onError: (e) {
            rawDataController.addError(e);
          },
        );

    final completer = Completer<List<String>>();
    late StreamSubscription<Uint8List> sub;

    sub = rawDataController.stream.listen(
      (rawBytes) {
        final message = utf8.decode(rawBytes, allowMalformed: true).trim();
        print(message);
        final supported = <String>[];

        if (!message.startsWith('7E8')) return;
        int idx = message.indexOf('41');
        if (idx < 0) return;
        final payload = message.substring(idx);

        if (!payload.startsWith('41') || payload.length < 6) return;
        final token = int.parse(
          payload.substring(4),
          radix: 16,
        ).toRadixString(2);
        for (int i = 0; i < 32; i++) {
          if (token[i] != "0") {
            final pidValue = i + 1;
            final pidHex = pidValue
                .toRadixString(16)
                .toUpperCase()
                .padLeft(2, '0');
            supported.add("01$pidHex");
          }
        }

        sub.cancel();
        completer.complete(supported);
      },
      onError: (e) {
        if (!completer.isCompleted) completer.completeError(e);
        sub.cancel();
      },
    );

    // Отправляем запрос 0100\r
    final writeChar = QualifiedCharacteristic(
      serviceId: Constants.obdServiceUuid,
      characteristicId: Constants.obdRxCharacteristicUuid,
      deviceId: deviceId,
    );
    await _repo.writeCharacteristicWithResponse(
      characteristic: writeChar,
      value: Uint8List.fromList(utf8.encode('0100\r')),
    );

    // Ждём ответа или таймаута
    final result = await completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        sub.cancel();
        throw TimeoutException('No response for 0100');
      },
    );

    // Очистка
    await notificationSub?.cancel();
    await rawDataController.close();

    return result;
  }
}
