import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:telemetry/core/models/telemetry_data.dart';
import 'package:telemetry/features/ble/application/ble_service.dart';
import 'package:telemetry/features/ble/domain/ble_repository.dart';
import 'package:telemetry/features/ble/infrastructure/flutter_reactive_ble_impl.dart';

/// Провайдер самого BLE-клиента
final flutterReactiveBleProvider = Provider<FlutterReactiveBle>((ref) {
  return FlutterReactiveBle();
});

/// Провайдер репозитория BLE (абстракция)
final bleRepositoryProvider = Provider<BleRepository>((ref) {
  final ble = ref.watch(flutterReactiveBleProvider);
  return FlutterReactiveBleImpl(ble);
});

/// Провайдер сервиса BLE (бизнес-логика)
final bleServiceProvider = Provider<BleService>((ref) {
  final repo = ref.watch(bleRepositoryProvider);
  return BleService(repo);
});

/// Провайдер состояния адаптера BLE (ready, poweredOff, unauthorized и т.п.)
final bleStatusProvider = StreamProvider<BleStatus>((ref) {
  return ref.watch(bleServiceProvider).statusStream;
});

final telemetryProvider = StreamProvider<TelemetryData>((ref) {
  final svc = ref.watch(bleServiceProvider);
  // Здесь нужно знать deviceId: допустим, в BleService оно уже установлено
  svc.startTelemetry();

  return svc.telemetryStream;
});

/// Провайдер состояния GATT-соединения
/// Сначала выдаёт disconnected, затем обновляет по реальным событиям
final connectionStateProvider = StreamProvider<DeviceConnectionState>((ref) {
  final service = ref.watch(bleServiceProvider);
  final controller = StreamController<DeviceConnectionState>();
  // Начальное состояние
  controller.add(DeviceConnectionState.disconnected);
  // Подписка на реальные обновления
  final sub = service.connectionStream
      .map((update) => update.connectionState)
      .listen(
        (state) => controller.add(state),
        onError: (e, st) => controller.addError(e, st),
      );
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

/// Провайдер списка найденных устройств OBD-II
final scanResultsProvider = StreamProvider<List<DiscoveredDevice>>((ref) {
  final ble = ref.watch(flutterReactiveBleProvider);
  final controller = StreamController<List<DiscoveredDevice>>();
  final devices = <DiscoveredDevice>[];
  final sub = ble
      .scanForDevices(scanMode: ScanMode.lowLatency, withServices: [])
      .listen((device) {
        if (!devices.any((d) => d.id == device.id)) {
          devices.add(device);
          controller.add(List.unmodifiable(devices));
        }
      }, onError: (e, st) => controller.addError(e, st));
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});
