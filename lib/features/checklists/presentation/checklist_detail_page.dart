import 'package:checkflow/core/database/app_database.dart';
import 'package:checkflow/features/checklists/state/checklist_detail_notifier.dart';
import 'package:checkflow/features/checklists/state/checklist_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChecklistDetailPage extends ConsumerWidget {
  final int checklistId;

  const ChecklistDetailPage({super.key, required this.checklistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checklistDetailProvider(checklistId));

    return Scaffold(
      appBar: AppBar(title: const Text('Checklist')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
        data: (data) {
          final checklist = data.checklist;
          final items = data.items;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChecklistHeader(checklist: checklist),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final itemWithStatus = items[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(itemWithStatus.item.title),
                        trailing: Icon(
                          Icons.circle,
                          size: 12,
                          color: itemWithStatus.hasPhotos
                              ? Colors.green
                              : Colors.red,
                        ),
                        onTap: () {
                          // TODO(lucaslora): Open photos
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChecklistHeader extends ConsumerWidget {
  final Checklist checklist;

  const _ChecklistHeader({required this.checklist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(checklist.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Criado em: ${checklist.createdAt.toLocal().toString().split('.').first}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final newTitle = await _showEditChecklistDialog(
                    context,
                    checklist.title,
                  );

                  if (newTitle != null && newTitle.isNotEmpty) {
                    await ref
                        .read(checklistDetailProvider(checklist.id).notifier)
                        .updateTitle(newTitle);

                    ref
                        .read(checklistListProvider.notifier)
                        .updateChecklistTitle(checklist.id, newTitle);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await _showDeleteConfirmationDialog(context);

                  if (confirm != true) return;

                  await ref
                      .read(checklistDetailProvider(checklist.id).notifier)
                      .deleteChecklist();

                  ref
                      .read(checklistListProvider.notifier)
                      .removeChecklist(checklist.id);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text('Excluir'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO(lucaslora): Generate ZIP
                },
                icon: const Icon(Icons.archive),
                label: const Text('ZIP'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<String?> _showEditChecklistDialog(
  BuildContext context,
  String currentTitle,
) {
  final controller = TextEditingController(text: currentTitle);

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Editar checklist'),
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
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.of(context).pop(text);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      );
    },
  );
}

Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Excluir checklist'),
        content: const Text(
          'Tem certeza que deseja excluir este checklist?\n'
          'Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );
}
