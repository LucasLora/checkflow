import 'package:checkflow/core/database/app_database.dart';
import 'package:checkflow/core/di/database_provider.dart';
import 'package:checkflow/features/checklists/data/checklist_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  final db = ref.read(databaseProvider);
  return ChecklistRepository(db);
});

final checklistListProvider =
    AsyncNotifierProvider<ChecklistNotifier, List<Checklist>>(
      ChecklistNotifier.new,
    );

class ChecklistNotifier extends AsyncNotifier<List<Checklist>> {
  late final ChecklistRepository _repository;

  @override
  Future<List<Checklist>> build() async {
    _repository = ref.read(checklistRepositoryProvider);
    return _repository.getAll();
  }

  Future<void> createChecklist(String title) async {
    state = const AsyncLoading();
    await _repository.createChecklistWithItems(title);
    state = AsyncData(await _repository.getAll());
  }

  void updateChecklistTitle(int checklistId, String newTitle) {
    final current = state.value;

    if (current == null) return;

    final updatedList = current.map((checklist) {
      if (checklist.id == checklistId) {
        return checklist.copyWith(title: newTitle);
      }
      return checklist;
    }).toList();

    state = AsyncData(updatedList);
  }

  void removeChecklist(int checklistId) {
    final current = state.value;

    if (current == null) return;

    final updatedList = current.where((c) => c.id != checklistId).toList();

    state = AsyncData(updatedList);
  }
}
