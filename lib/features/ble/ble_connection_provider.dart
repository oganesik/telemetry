import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telemetry/core/constants/constants.dart';
import 'package:telemetry/core/models/telemetry_data.dart';
import 'package:telemetry/features/ble/application/ble_pid_service.dart';
import 'package:telemetry/features/ble/domain/ble_repository.dart';
import 'package:telemetry/features/ble/providers.dart';
import 'package:telemetry/features/ble/states/pid_state.dart';

/// StateNotifier отвечает за подключение к устройству и сбор телеметрии
class BleConnectionNotifier extends StateNotifier<PidState> {
  final BleRepository _repo;
  final BlePidService _pidService;
  StreamSubscription<ConnectionStateUpdate>? _connectionSub;
  StreamSubscription<Uint8List>? _notificationSub;
  StreamSubscription<Uint8List>? _notificationATSub;
  Timer? _pollTimer;
  String? _deviceId;
  // Список всех найденных PID-ов
  List<String> _availablePids = [];
  final List<String> initCommands = [
    "ATZ",
    "ATE0",
    "ATS0",
    "ATL0",
    "ATH1",
    "ATSP0",
    "ATDPN",
    "ATSP0",
  ];
  // Список выбранных PID-ов
  List<String> _selectedPids = [];
  // Контроллер для стрима телеметрии
  final _telemetryController = StreamController<TelemetryData>.broadcast();
  final _pidController = StreamController<List<String>>.broadcast();
  // Храним последнее значение телеметрии для аккумулирования
  TelemetryData _lastData = const TelemetryData(
    rpm: null,
    speed: null,
    coolantTemp: null,
  );

  BleConnectionNotifier(this._repo, this._pidService)
    : super(
        PidState(
          availablePids: [],
          selectedPids: [],
          connect: DeviceConnectionState.disconnected,
          rawAt: [],
        ),
      );

  /// Подключение к устройству по ID
  Future<void> connectToDevice(String deviceId) async {
    _deviceId = deviceId;
    state = state.copyWith(connect: DeviceConnectionState.disconnected);
    await _connectionSub?.cancel();
    _connectionSub = _repo
        .connectionStateStream(deviceId)
        .listen(
          (update) {
            state = state.copyWith(connect: update.connectionState);
          },
          onError: (_) {
            state = state.copyWith(connect: DeviceConnectionState.disconnected);
          },
        );
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> initElm() async {
    final id = _deviceId;
    if (id == null) return;
    _notificationATSub = _repo
        .subscribeToCharacteristic(
          deviceId: id,
          serviceUuid: Constants.obdServiceUuid,
          characteristicUuid: Constants.obdTxCharacteristicUuid,
        )
        .listen(
          (data) async {
            final message = utf8.decode(data, allowMalformed: true).trim();
            print("Raw response:$message");
            state.rawAt?.add("Raw response:$message");
          },
          onError: (e) {
            print(e);
          },
        );
    for (final cmd in initCommands) {
      await Future.delayed(const Duration(milliseconds: 1000));
      print("Send Command:$cmd");
      state.rawAt?.add("Send command: $cmd");
      await _writePid(cmd);
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _notificationATSub?.cancel();
  }

  /// Запрашивает поддерживаемые PID-ы у ЭБУ через BlePidService
  Future<void> loadAvailablePids() async {
    print("STARTKURWA");
    final id = _deviceId;
    if (id == null) return;
    final pids = await _pidService.fetchSupportedPids(deviceId: id);
    print(pids);
    state = state.copyWith(availablePids: pids);
  }

  void selectPid(String pid) {
    if (!state.availablePids!.contains(pid)) return;
    if (!_selectedPids.contains(pid)) {
      _selectedPids = [..._selectedPids, pid];
      state = state.copyWith(selectedPids: _selectedPids);
    }
  }

  void unselectPid(String pid) {
    _selectedPids.remove(pid);
    state = state.copyWith(selectedPids: _selectedPids);
  }

  void kek() {
    _telemetryController.add(_lastData.copyWith(rpm: 22));
  }

  /// Геттер сохраненного deviceId
  String? get deviceId => _deviceId;

  /// Поток телеметрии
  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;
  Stream<List<String>> get pidStream => _pidController.stream;

  /// Запуск сбора телеметрии
  Future<void> startTelemetry() async {
    final id = _deviceId;
    if (id == null) return;
    // final List<String> initCommands = [
    //   "AT L0",
    //   "AT E0",
    //   "AT H1",
    //   "AT AT1",
    //   "AT ST FF",
    //   "AT SP 0",
    // ];
    // for (final cmd in initCommands) {
    //   await _writePid(cmd);

    //   await Future.delayed(const Duration(milliseconds: 200));
    // }
    // Подписка на уведомления
    _notificationSub = _repo
        .subscribeToCharacteristic(
          deviceId: id,
          serviceUuid: Constants.obdServiceUuid,
          characteristicUuid: Constants.obdTxCharacteristicUuid,
        )
        .listen(
          _onDataReceived,
          onError: (e) {
            print(e);
          },
        );

    // Периодические запросы PID
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      for (final pid in _selectedPids) {
        await Future.delayed(Duration(milliseconds: 100));
        _writePid(pid);
      }
    });
  }

  /// Обработчик принятых данных
  void _onDataReceived(Uint8List data) {
    final message = utf8.decode(data, allowMalformed: true).trim();

    if (message.startsWith('3E') || message.startsWith('01')) return;
    print(message);
    // Убираем CAN-заголовок до '41'
    int idx = message.indexOf('41');
    if (idx < 0) return;
    final payload = message.substring(idx);

    // Должно быть минимум PID + один байт: 41 XX YY
    if (!payload.startsWith('41') || payload.length < 6) return;

    // Разбиваем payload на байты (по 2 символа), безопасно проверяя границы
    final tokens = <String>[];
    for (var i = 0; i + 2 <= payload.length; i += 2) {
      tokens.add(payload.substring(i, i + 2));
    }

    // Если вдруг осталось неполное слово, игнорируем
    if (payload.length % 2 != 0) {
      // можно залогировать или проигнорировать последний неполный байт
    }

    final pid = tokens.length > 1 ? tokens[1] : null;
    final a = tokens.length > 2 ? int.tryParse(tokens[2], radix: 16) : null;
    final b = tokens.length > 3 ? int.tryParse(tokens[3], radix: 16) : null;
    if (pid == null || a == null) return;

    int? rpm;
    int? speed;
    int? coolant;

    if (pid == '0C' && b != null) {
      rpm = ((a << 8) + b) ~/ 4;
    } else if (pid == '0D') {
      speed = a;
    } else if (pid == '05') {
      coolant = a - 40;
    } else {
      return;
    }

    _lastData = _lastData.copyWith(
      rpm: rpm,
      speed: speed,
      coolantTemp: coolant,
    );

    _telemetryController.add(_lastData);
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
    } catch (_) {}
  }

  /// Остановка телеметрии
  Future<void> stopTelemetry() async {
    _pollTimer?.cancel();
    _lastData = const TelemetryData(rpm: null, speed: null, coolantTemp: null);
    await _notificationSub?.cancel();
  }

  /// Отключение от устройства
  Future<void> disconnect() async {
    state = state.copyWith(connect: DeviceConnectionState.disconnected);
    await stopTelemetry();
    if (_deviceId != null) {
      await _repo.disconnect(_deviceId!);
      _deviceId = null;
    }
    await _connectionSub?.cancel();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _notificationSub?.cancel();
    _connectionSub?.cancel();
    _telemetryController.close();
    super.dispose();
  }
}

/// Провайдер для состояния подключения
final bleConnectionProvider =
    StateNotifierProvider<BleConnectionNotifier, PidState>((ref) {
      final repo = ref.watch(bleRepositoryProvider);
      return BleConnectionNotifier(repo, BlePidService(repo));
    });
