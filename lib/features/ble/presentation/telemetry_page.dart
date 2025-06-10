import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telemetry/core/models/socket_io_state.dart';
import 'package:telemetry/core/models/telemetry_data.dart';
import 'package:telemetry/features/ble/ble_connection_provider.dart';
import 'package:telemetry/features/ble/presentation/connect_indicator.dart';
import 'package:telemetry/features/ble/presentation/gauges/coolant_gauge.dart';
import 'package:telemetry/features/ble/presentation/gauges/speedometer.dart';
import 'package:telemetry/features/ble/presentation/gauges/tachometer.dart';
import 'package:telemetry/features/ble/providers.dart';
import 'package:telemetry/features/ble/telemetry_notifier.dart';

/// Страница отображения телеметрии с автозапросом RPM и скорости
class TelemetryPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(roomIdProvider);
    final socketState = ref.watch(socketNotifierProvider);
    final data = ref.watch(telemetryNotifierProvider);
    final controller = ref.watch(bleConnectionProvider.notifier);

    ref.listen<TelemetryData>(telemetryNotifierProvider, (previous, next) {
      // Этот колбек вызывается только тогда, когда newData != oldData
      ref.read(socketNotifierProvider.notifier).send(next.toJson());
    });
    ref.listen<AsyncValue<String>>(roomIdProvider, (previous, next) {
      next.when(
        data: (roomId) {
          // Если уже было подключение к этому же roomId, не повторяем init.
          final current = socketState.roomId;
          if (current != roomId) {
            ref.read(socketNotifierProvider.notifier).init(roomId);
          }
        },

        error: (err, stack) {
          // Можно логировать ошибку, но UI покажет это в roomAsync.when(error:…)
        },
        loading: () {},
      );
    });
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.open_in_browser),

        onPressed: () {
          roomAsync.when(
            data: (roomId) {
              _showToast(context);
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  Clipboard.setData(
                    ClipboardData(text: "https://socialsquad.ru/$roomId"),
                  );

                  return AlertDialog(
                    title: const Text('Ссылка для удаленного просмотра'),
                    content: Text(
                      "https://socialsquad.ru/$roomId \nСтатус: ${_statusToString(socketState.status)}",
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
            error: (error, Stack) {
              Center(
                child: Text(
                  'Ошибка загрузки Room ID:\n$error',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
      appBar: AppBar(
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ConnectIndicator(),
          ),
        ],
        title: const Text('Телеметрия'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            // 1. Ваша логика перед уходом (в том числе можно stopTelemetry)
            controller.disconnect();
            // 2. Возврат на предыдущий экран
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(child: Speedometer(speed: data.speed?.toDouble() ?? 0)),
              Expanded(child: Tachometer(rpm: data.rpm?.toDouble() ?? 0)),
            ],
          ),

          CoolantGauge(temperature: data.coolantTemp?.toDouble() ?? 0),
        ],
      ),
    );
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Ссылка скопирована'),
        action: SnackBarAction(
          label: 'Закрыть',
          onPressed: scaffold.hideCurrentSnackBar,
        ),
      ),
    );
  }

  String _statusToString(SocketStatus status) {
    switch (status) {
      case SocketStatus.disconnected:
        return 'Отключено';
      case SocketStatus.connecting:
        return 'Подключаемся...';
      case SocketStatus.connected:
        return 'Подключено';
      case SocketStatus.error:
        return 'Ошибка';
    }
  }
}
