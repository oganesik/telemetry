import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

/// Компонент линейного гейджа для температуры охлаждающей жидкости
class CoolantGauge extends StatelessWidget {
  /// Текущая температура охлаждающей жидкости в °C
  final double temperature;

  /// Минимальное значение шкалы (°C)
  final double minTemp;

  /// Максимальное значение шкалы (°C)
  final double maxTemp;

  const CoolantGauge({
    super.key,
    required this.temperature,
    this.minTemp = -40,
    this.maxTemp = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Температура ОЖ, °C',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SfLinearGauge(
            minimum: minTemp,
            maximum: maxTemp,
            interval: 20,
            markerPointers: [
              LinearShapePointer(
                value: temperature,
                shapeType: LinearShapePointerType.triangle,
                color: _pointerColor(),
                position: LinearElementPosition.inside,
              ),
            ],
            barPointers: [
              LinearBarPointer(
                value: temperature,
                color: _barColor(),
                thickness: 10,
              ),
            ],
            majorTickStyle: const LinearTickStyle(length: 10),
            minorTicksPerInterval: 4,
            axisTrackStyle: const LinearAxisTrackStyle(thickness: 8),
          ),
        ),
      ],
    );
  }

  Color _barColor() {
    if (temperature <= 90) {
      return Colors.green;
    } else if (temperature <= 110) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _pointerColor() {
    return Colors.black;
  }
}
