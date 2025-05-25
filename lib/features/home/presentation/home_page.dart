import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:telemetry/features/ble/presentation/connect_indicator.dart';
import 'package:telemetry/features/ble/presentation/device_picker_button.dart';
import 'package:telemetry/features/ble/presentation/telemetry_page.dart';
import 'package:telemetry/features/ble/providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Подписываемся на состояние GATT-соединения
    final connState = ref.watch(connectionStateProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Подключение'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ConnectIndicator(),
          ),
        ],
      ),
      body: Center(
        child:
            connState == DeviceConnectionState.connected
                // Если уже подключились — показываем кнопку «Начать обмен»
                ? ElevatedButton.icon(
                  icon: const Icon(Icons.data_usage),
                  label: const Text('Начать обмен'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    // Переходим на TelemetryPage, где обмениваемся данными
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => TelemetryPage()));
                  },
                )
                // Иначе — показываем кнопку выбора устройства
                : const DevicePickerButton(),
      ),
    );
  }
}
