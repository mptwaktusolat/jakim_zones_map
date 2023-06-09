import 'package:flutter/material.dart';

import 'start_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.purple),
      title: 'Prayer Zones Visualization Tool',
      home: const StartScreen(),
    );
  }
}
