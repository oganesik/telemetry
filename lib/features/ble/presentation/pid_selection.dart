import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telemetry/core/schedule.dart';
import 'package:telemetry/features/ble/ble_connection_provider.dart';

/// Виджет для отображения списка доступных PID-ов и их выбора
class PidSelectionWidget extends ConsumerWidget {
  const PidSelectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем экземпляр BleConnectionNotifier
    final ap = ref.watch(bleConnectionProvider).availablePids ?? [];
    final sp = ref.watch(bleConnectionProvider).selectedPids ?? [];
    final bleNotifier = ref.watch(bleConnectionProvider.notifier);

    if (ap.isEmpty) {
      // Если список ещё не загружен, можно показать сообщение или спиннер
      return const Center(child: Text('Список PID-ов загружается...'));
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: ap.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final pid = ap[index];
          final isChecked = sp.contains(pid);
          return CheckboxListTile(
            title: Text(
              pidDefinitions[pid.substring(2)]?.description ??
                  "Неизвестный PID",
            ),
            value: isChecked,
            onChanged: (checked) {
              if (checked == true) {
                bleNotifier.selectPid(pid);
              } else {
                bleNotifier.unselectPid(pid);
              }
            },
          );
        },
      ),
    );
  }
}
