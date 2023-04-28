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
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          // foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        drawer: Drawer(
          child: Column(
            children: [Text("hello")],
          ),
        ),
        body: App(),
      ),
    );
  }
}
