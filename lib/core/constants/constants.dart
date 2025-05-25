/// lib/core/constants/constants.dart
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Глобальные константы для BLE и OBD-II
class Constants {
  /// Nordic UART Service UUID (часто используется адаптерами ELM327 BLE)
  static final Uuid obdServiceUuid = Uuid.parse('0000FFF0-0000-1000-8000-00805F9B34FB');

    /// Характеристика для записи команд (RX на устройстве)
  static final Uuid obdRxCharacteristicUuid = Uuid.parse('0000FFF2-0000-1000-8000-00805F9B34FB');

    /// Характеристика для получения уведомлений (TX от устройства)
  static final Uuid obdTxCharacteristicUuid = Uuid.parse('0000FFF1-0000-1000-8000-00805F9B34FB');
}




