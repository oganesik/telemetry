import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../providers.dart';

/// Кнопка, открывающая список BLE-устройств и подключающаяся к выбранному
class DevicePickerButton extends ConsumerWidget {
  final double size;
  const DevicePickerButton({Key? key, this.size = 120}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bleStatus =
        ref.watch(bleStatusProvider).asData?.value ?? BleStatus.unknown;
    final isReady = bleStatus == BleStatus.ready;
    print(ref.watch(bleStatusProvider).asData?.value);

    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: isReady ? () => _showDeviceList(context, ref) : null,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor:
              isReady ? Theme.of(context).primaryColor : Colors.grey,
        ),
        child: const Icon(
          Icons.bluetooth_searching,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Показ модалки со списком устройств и подключение по тапу
  Future<void> _showDeviceList(BuildContext context, WidgetRef ref) async {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (_, refSheet, __) {
            return refSheet
                .watch(scanResultsProvider)
                .when(
                  data: (devices) {
                    if (devices.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('Поиск устройств...')),
                      );
                    }
                    return ListView.separated(
                      itemCount: devices.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) {
                        final d = devices[i];
                        final name = d.name.isNotEmpty ? d.name : d.id;
                        return ListTile(
                          title: Text(name),
                          subtitle: Text(d.id),
                          onTap: () async {
                            Navigator.of(ctx).pop();
                            try {
                              await ref
                                  .read(bleServiceProvider)
                                  .connectToDevice(d.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Подключено к \$name')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Ошибка подключения: \$e'),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (e, _) => Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text('Ошибка: \$e')),
                      ),
                );
          },
        );
      },
    );
  }
}
