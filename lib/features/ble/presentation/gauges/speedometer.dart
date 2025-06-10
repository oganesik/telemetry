import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

/// Speedometer widget using Syncfusion Flutter Gauges
class Speedometer extends StatelessWidget {
  /// Current speed value in km/h
  final double speed;

  /// Maximum speed for the gauge
  final double maxSpeed;

  const Speedometer({super.key, required this.speed, this.maxSpeed = 240});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: SfRadialGauge(
          enableLoadingAnimation: true,
          animationDuration: 4500,
          axes: <RadialAxis>[
            RadialAxis(
              showLastLabel: true,
              // 2) Смещаем все лейблы наружу на 15px
              minimum: 0,
              maximum: maxSpeed,
              showTicks: true,
              showLabels: true,
              interval: maxSpeed / 8,
              startAngle: 155,
              endAngle: 25,
              ranges: <GaugeRange>[
                GaugeRange(
                  startValue: 0,
                  endValue: maxSpeed * 0.33,
                  color: Colors.green,
                ),
                GaugeRange(
                  startValue: maxSpeed * 0.33,
                  endValue: maxSpeed * 0.66,
                  color: Colors.orange,
                ),
                GaugeRange(
                  startValue: maxSpeed * 0.66,
                  endValue: maxSpeed,
                  color: Colors.red,
                ),
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                  enableAnimation: true,
                  animationType: AnimationType.linear,
                  value: speed.clamp(0, maxSpeed),
                  needleStartWidth: 1,
                  needleEndWidth: 6,
                  knobStyle: KnobStyle(color: Colors.black),
                  // регулируем длину «иглы»
                  needleColor: Colors.black,
                ),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(
                    '${speed.toStringAsFixed(0)} km/h',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  angle: 90,
                  positionFactor: 0.3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
