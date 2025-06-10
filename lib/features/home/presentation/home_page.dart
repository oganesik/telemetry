import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:telemetry/features/ble/ble_connection_provider.dart';

import 'package:telemetry/features/ble/presentation/connect_indicator.dart';
import 'package:telemetry/features/ble/presentation/device_picker_button.dart';
import 'package:telemetry/features/ble/presentation/pid_selection.dart';
import 'package:telemetry/features/ble/presentation/telemetry_page.dart';
import 'package:telemetry/features/ble/providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем текущее состояние (nullable, поэтому даём дефолт)
    final connectionState =
        ref.watch(bleConnectionProvider).connect ??
        DeviceConnectionState.disconnected;
    // Нативный контроллер для вызова методов
    final controller = ref.watch(bleConnectionProvider.notifier);
    Widget content;
    if (connectionState == DeviceConnectionState.connecting ||
        connectionState == DeviceConnectionState.disconnecting) {
      // Если в процессе (подключение/отключение) — показываем индикатор
      content = const CircularProgressIndicator();
    } else if (connectionState == DeviceConnectionState.connected) {
      // Если подключены — предлагаем перейти на страницу обмена данными
      content = ElevatedButton.icon(
        icon: const Icon(Icons.data_usage),
        label: const Text('Начать обмен'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () async {
          await controller.loadAvailablePids();
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Column(
                children: [
                  PidSelectionWidget(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      controller.startTelemetry();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => TelemetryPage()),
                      );
                    },
                    label: const Text("Продолжить"),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      // Иначе — кнопка выбора и подключения к устройству
      content = const DevicePickerButton();
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.disconnect();
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Ответы на AT команды'),
                content: Text(
                  ref
                          .watch(bleConnectionProvider)
                          .rawAt
                          ?.join("\n")
                          .toString() ??
                      "Ошибка",
                ),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Закрыть'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      appBar: AppBar(
        title: const Text('Подключение'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ConnectIndicator(),
          ),
        ],
      ),
      body: Center(child: content),
    );
  }
}
