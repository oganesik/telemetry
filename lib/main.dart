import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:telemetry/features/home/presentation/home_page.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()),
    ),
  );
}
