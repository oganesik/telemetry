// lib/features/ble/telemetry_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telemetry/core/models/telemetry_data.dart';
import 'package:telemetry/features/ble/ble_connection_provider.dart';

// 1) Notifier, который держит последний RPM+Speed и сливает новые данные в старое состояние
class TelemetryNotifier extends StateNotifier<TelemetryData> {
  TelemetryNotifier(this._rawStream)
    : super(TelemetryData(rpm: null, speed: null, coolantTemp: null)) {
    // как только создаётся Notifier — подписываемся на «сырые» обновления
    _sub = _rawStream.listen((raw) {
      // обновляем только изменившееся поле
      state = state.copyWith(
        rpm: raw.rpm ?? state.rpm,
        speed: raw.speed ?? state.speed,
        coolantTemp: raw.coolantTemp ?? state.coolantTemp,
      );
    });
  }

  final Stream<TelemetryData> _rawStream;
  late final StreamSubscription<TelemetryData> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// 2) Провайдер «сырых» данных из BleConnectionNotifier
final rawTelemetryProvider = Provider<Stream<TelemetryData>>((ref) {
  return ref.watch(bleConnectionProvider.notifier).telemetryStream;
});

// 3) Провайдер аккумулированной телеметрии
final telemetryNotifierProvider =
    StateNotifierProvider<TelemetryNotifier, TelemetryData>((ref) {
      final rawStream = ref.watch(rawTelemetryProvider);

      return TelemetryNotifier(rawStream);
    });
