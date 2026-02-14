import 'package:checkflow/core/database/app_database.dart';
import 'package:checkflow/features/checklists/presentation/item_photos_page.dart';
import 'package:checkflow/features/checklists/state/checklist_detail_notifier.dart';
import 'package:checkflow/features/checklists/state/checklist_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChecklistDetailPage extends ConsumerStatefulWidget {
  const ChecklistDetailPage({required this.checklistId, super.key});

  final int checklistId;

  @override
  ConsumerState<ChecklistDetailPage> createState() =>
      _ChecklistDetailPageState();
}

class _ChecklistDetailPageState extends ConsumerState<ChecklistDetailPage> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checklistDetailProvider(widget.checklistId));

    return Scaffold(
      appBar: AppBar(title: const Text('Checklist')),
      body: Stack(
        children: [
          state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Erro: $error')),
            data: (data) => _buildContent(data),
          ),
          if (_isExporting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(102),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Column _buildContent(ChecklistDetailState data) {
    final checklist = data.checklist;
    final items = data.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChecklistHeader(
          checklist: checklist,
          onEdit: () async => await _handleEdit(checklist),
          onDelete: () async => await _handleDelete(checklist),
          onExport: () async => await _handleExport(checklist),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final itemWithStatus = items[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(itemWithStatus.item.title),
                  trailing: Icon(
                    Icons.circle,
                    size: 12,
                    color: itemWithStatus.hasPhotos ? Colors.green : Colors.red,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ItemPhotosPage(
                          itemId: itemWithStatus.item.id,
                          checklistId: itemWithStatus.item.checklistId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleEdit(Checklist checklist) async {
    final newTitle = await _showEditChecklistDialog(context, checklist.title);

    if (newTitle != null && newTitle.isNotEmpty) {
      await ref
          .read(checklistDetailProvider(checklist.id).notifier)
          .updateTitle(newTitle);

      ref
          .read(checklistListProvider.notifier)
          .updateChecklistTitle(checklist.id, newTitle);
    }
  }

  Future<void> _handleDelete(Checklist checklist) async {
    final confirm = await _showDeleteConfirmationDialog(context);

    if (confirm != true) return;

    await ref
        .read(checklistDetailProvider(checklist.id).notifier)
        .deleteChecklist();

    ref.read(checklistListProvider.notifier).removeChecklist(checklist.id);

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleExport(Checklist checklist) async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    try {
      final resultExportZip = await ref
          .read(checklistDetailProvider(checklist.id).notifier)
          .exportZip();

      if (!mounted) return;

      final result = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          sourceFilePath: resultExportZip.path,
          fileName: resultExportZip.fileName,
        ),
      );

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Arquivo salvo com sucesso'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar ZIP:\n$e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}

class _ChecklistHeader extends StatelessWidget {
  const _ChecklistHeader({
    required this.checklist,
    required this.onEdit,
    required this.onDelete,
    required this.onExport,
  });

  final Checklist checklist;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onExport;

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
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
                label: const Text('Excluir'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onExport,
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
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );
}
