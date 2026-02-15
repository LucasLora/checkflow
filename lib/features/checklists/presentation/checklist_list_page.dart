import 'dart:async';

import 'package:checkflow/features/checklists/presentation/checklist_detail_page.dart';
import 'package:checkflow/features/checklists/state/checklist_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChecklistListPage extends ConsumerWidget {
  const ChecklistListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checklistListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checklists')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
        data: (checklists) {
          if (checklists.isEmpty) {
            return const Center(child: Text('Nenhum checklist encontrado'));
          }

          return ListView.builder(
            itemCount: checklists.length,
            itemBuilder: (context, index) {
              final checklist = checklists[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(checklist.title),
                  subtitle: Text(
                    'Criado em: ${checklist.createdAt.toLocal().toString().split('.').first}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ChecklistDetailPage(checklistId: checklist.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final title = await _showCreateChecklistDialog(context);

          if (title != null && title.isNotEmpty) {
            unawaited(
              ref.read(checklistListProvider.notifier).createChecklist(title),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<String?> _showCreateChecklistDialog(BuildContext context) {
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Criar Checklist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Título',
            border: OutlineInputBorder(),
          ),
          maxLength: 40,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(controller.text.trim());
            },
            child: const Text('Criar'),
          ),
        ],
      );
    },
  );
}
