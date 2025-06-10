import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:http/http.dart' as http;
import 'package:telemetry/core/models/socket_io_state.dart';

import 'package:telemetry/core/models/telemetry_data.dart';
import 'package:telemetry/core/providires/socket_notifier.dart';
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

/// 1. Провайдер для SocketNotifier + его состояния
final socketNotifierProvider =
    StateNotifierProvider<SocketNotifier, SocketState>((ref) {
      // Укажите ваш URL сервера без слэша на конце
      const serverUrl = 'http://socialsquad.ru:3000';
      return SocketNotifier(serverUrl: serverUrl);
    });

/// 2. (Опционально) FutureProvider для получения roomId по HTTP
final roomIdProvider = FutureProvider<String>((ref) async {
  // Замените на ваш HTTP-клиент, здесь для примера – http из пакета http
  final uri = Uri.parse('http://socialsquad.ru:3000/api/createRoom');
  final response = await ref.read(httpClientProvider).get(uri);
  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['roomId'] as String;
  } else {
    throw Exception('Не удалось получить roomId: ${response.statusCode}');
  }
});

/// Простейший httpClientProvider для http-пакета
final httpClientProvider = Provider((ref) => http.Client());
