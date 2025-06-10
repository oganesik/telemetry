import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:telemetry/core/constants/constants.dart';
import 'package:telemetry/core/models/telemetry_data.dart';

import '../domain/ble_repository.dart';

/// Сервис для работы с BLE и телеметрией OBD-II
class BleService {
  final BleRepository _repo;
  String? _deviceId;
  StreamSubscription<ConnectionStateUpdate>? _connection;
  StreamSubscription<Uint8List>? _notificationSub;
  Timer? _pollTimer;
  DeviceConnectionState? _conState;
  // Контроллер для потока TelemetryData
  final _telemetryController = StreamController<TelemetryData>.broadcast();

  BleService(this._repo);
  DeviceConnectionState? get conState => _conState;

  /// Геттер для статуса адаптера BLE
  Stream<BleStatus> get statusStream => _repo.statusStream;

  /// Геттер для состояния GATT-соединения
  Stream<ConnectionStateUpdate> get connectionStream =>
      _deviceId == null
          ? const Stream.empty()
          : _repo.connectionStateStream(_deviceId!);

  /// Геттер для текущего deviceId
  String? get deviceId => _deviceId;

  /// Поток телеметрии
  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;

  /// Подключение к устройству по ID
  Future<void> connectToDevice(String deviceId) async {
    _deviceId = deviceId;
    try {
      await _repo.clearGattCache(deviceId);
    } catch (_) {}
    try {
      await _repo.requestMtu(deviceId, 250);
    } catch (_) {}
    await _connection?.cancel();
    _connection = _repo.connectionStateStream(deviceId).listen((event) {
      _conState = event.connectionState;
    }, onError: (_) {});
  }

  /// Начало автоматического опроса RPM и скорости
  Future<void> startTelemetry() async {
    final id = _deviceId;
    if (id == null) return;
    // Подписка на уведомления
    _notificationSub = _repo
        .subscribeToCharacteristic(
          deviceId: id,
          serviceUuid: Constants.obdServiceUuid,
          characteristicUuid: Constants.obdTxCharacteristicUuid,
        )
        .listen(_onDataReceived, onError: (_) {});
    // Запросы PID
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _writePid('010C'); // RPM
      _writePid('010D'); // Speed
    });
  }

  void _onDataReceived(Uint8List data) {
    // 1️⃣ Декодируем байты и обрезаем пробелы/переводы строки
    final message = utf8.decode(data, allowMalformed: true).trim();
    print(message);
    // 2️⃣ Отсекаем всё, что не начинается с "41 " (это ответ OBD-II на запрос 01XX)
    if (!message.startsWith('41 ')) {
      // Можно также дополнительно убрать эхо-команду ("01XX…") и NO DATA:
      // if (message.startsWith('01') || message.contains('NO DATA')) return;
      return;
    }

    // 3️⃣ Разбиваем на токены и проверяем, что их как минимум 4: ["41", "0C", "1A", "F8"]
    final raw = message.split(' ');
    if (raw.length < 4) return;

    // 4️⃣ Парсим PID и данные
    final pid = raw[1];
    final a = int.tryParse(raw[2], radix: 16);
    final b = int.tryParse(raw[3], radix: 16);
    if (a == null || b == null) return;

    int? rpm;
    int? speed;
    if (pid == '0C') {
      rpm = ((a << 8) + b) ~/ 4; // (A*256 + B) / 4
    } else if (pid == '0D') {
      speed = a; // A = скорость в км/ч
    } else {
      return; // не тот PID — игнорируем
    }

    // 5️⃣ Эмитим только если есть что отдавать
    _telemetryController.add(TelemetryData(rpm: rpm, speed: speed));
  }

  /// Отправка PID-команды адаптеру
  Future<void> _writePid(String pid) async {
    final id = _deviceId;
    if (id == null) return;
    final writeChar = QualifiedCharacteristic(
      serviceId: Constants.obdServiceUuid,
      characteristicId: Constants.obdRxCharacteristicUuid,
      deviceId: id,
    );
    try {
      await _repo.writeCharacteristicWithResponse(
        characteristic: writeChar,
        value: Uint8List.fromList(utf8.encode('$pid\r')),
      );
    } catch (_) {
      // игнорируем ошибки записи
    }
  }

  /// Остановка телеметрии
  Future<void> stopTelemetry() async {
    _pollTimer?.cancel();
    await _notificationSub?.cancel();
    await _telemetryController.close();
  }

  /// Отключение от устройства
  Future<void> disconnect() async {
    await stopTelemetry();
    if (_deviceId != null) {
      await _repo.disconnect(_deviceId!);
      _deviceId = null;
    }
    await _connection?.cancel();
  }
}
