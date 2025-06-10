import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

/// Speedometer widget using Syncfusion Flutter Gauges
class Tachometer extends StatelessWidget {
  /// Current speed value in km/h
  final double rpm;

  /// Maximum speed for the gauge
  final double maxRpm;

  const Tachometer({super.key, required this.rpm, this.maxRpm = 10000});

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      enableLoadingAnimation: true,
      animationDuration: 4500,
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: maxRpm,
          showLastLabel: true,
          interval: maxRpm / 8,
          startAngle: 150,
          endAngle: 30,
          ranges: <GaugeRange>[
            GaugeRange(
              startValue: 0,
              endValue: maxRpm * 0.33,
              color: Colors.green,
            ),
            GaugeRange(
              startValue: maxRpm * 0.33,
              endValue: maxRpm * 0.66,
              color: Colors.orange,
            ),
            GaugeRange(
              startValue: maxRpm * 0.66,
              endValue: maxRpm,
              color: Colors.red,
            ),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(
              value: rpm.clamp(0, maxRpm),
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
                '${rpm.toStringAsFixed(0)} rpm ',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              angle: 90,
              positionFactor: 0.3,
            ),
          ],
        ),
      ],
    );
  }
}
