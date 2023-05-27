import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.purple),
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          // foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        drawer: const Drawer(
          child: Column(
            children: [Text("Waktu Solat Map visualization")],
          ),
        ),
        body: const App(),
      ),
    );
  }
}
