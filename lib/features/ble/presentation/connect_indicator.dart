import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telemetry/features/ble/ble_connection_provider.dart';

class ConnectIndicator extends ConsumerWidget {
  const ConnectIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем текущее состояние подключения
    final state =
        ref.watch(bleConnectionProvider).connect ??
        DeviceConnectionState.disconnected;

    // Если в процессе подключения или отключения — показываем индикатор
    if (state == DeviceConnectionState.connecting ||
        state == DeviceConnectionState.disconnecting) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 6),
          Text('...'),
        ],
      );
    }

    // Определяем, подключены ли мы
    final isConnected = state == DeviceConnectionState.connected;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          isConnected ? 'Подключен' : 'Отключен',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
