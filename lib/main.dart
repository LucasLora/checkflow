import 'package:flutter/material.dart';

void main() {
  runApp(const CheckFlowApp());
}

class CheckFlowApp extends StatelessWidget {
  const CheckFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('CheckFlow'))),
    );
  }
}
