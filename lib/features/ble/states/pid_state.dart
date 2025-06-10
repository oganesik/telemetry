// pid_state.dart

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Структура, которую мы будем хранить в качестве `state` у BleConnectionNotifier
class PidState {
  /// Список всех доступных PID-ов, полученных из OBD
  final List<String>? availablePids;
  final DeviceConnectionState? connect;

  /// Список отмеченных PID-ов
  final List<String>? selectedPids;
  final List<String>? rawAt;
  PidState({
    required this.connect,
    required this.availablePids,
    required this.selectedPids,
    required this.rawAt,
  });

  /// Создаёт копию с изменёнными полями. Нужен для обновления состояния.
  PidState copyWith({
    List<String>? availablePids,
    List<String>? selectedPids,
    DeviceConnectionState? connect,
    List<String>? rawAt,
  }) {
    return PidState(
      availablePids: availablePids ?? this.availablePids,
      selectedPids: selectedPids ?? this.selectedPids,
      connect: connect ?? this.connect,
      rawAt: rawAt ?? this.rawAt,
    );
  }
}
