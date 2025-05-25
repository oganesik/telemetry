import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:telemetry/features/ble/providers.dart';

/// Страница отображения телеметрии с автозапросом RPM и скорости
class TelemetryPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Телеметрия')),
      body: ref
          .watch(telemetryProvider)
          .when(
            data:
                (data) => Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('RPM: ${data.rpm ?? '-'}'),
                      SizedBox(height: 8),
                      Text('Speed: ${data.speed ?? '-'} km/h'),
                    ],
                  ),
                ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Ошибка: $e')),
          ),
    );
  }
}
