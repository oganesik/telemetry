import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telemetry/features/ble/providers.dart';

class ConnectIndicator extends ConsumerWidget {
  const ConnectIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(connectionStateProvider)
        .when(
          data: (state) {
            // state — это DeviceConnectionState
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
          },
          loading:
              () => Row(
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
              ),
          error:
              (e, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('Ошибка'),
                ],
              ),
        );
  }
}
