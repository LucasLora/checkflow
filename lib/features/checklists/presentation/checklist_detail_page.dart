import 'package:checkflow/core/database/app_database.dart';
import 'package:checkflow/features/checklists/state/checklist_detail_notifier.dart';
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

class _ChecklistHeader extends StatelessWidget {
  final Checklist checklist;

  const _ChecklistHeader({required this.checklist});

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {
                  // TODO: Edit title
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Delete checklist
                },
                icon: const Icon(Icons.delete),
                label: const Text('Excluir'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Generate ZIP
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
