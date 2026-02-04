import 'package:checkflow/features/checklists/presentation/checklist_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: CheckFlowApp()));
}

class CheckFlowApp extends StatelessWidget {
  const CheckFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF005BAC)),
      ),
      home: const ChecklistListPage(),
    );
  }
}
