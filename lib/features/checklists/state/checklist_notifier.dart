import 'package:checkflow/core/database/app_database.dart';
import 'package:checkflow/core/di/database_provider.dart';
import 'package:checkflow/core/di/file_storage_provider.dart';
import 'package:checkflow/features/checklists/data/checklist_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  final db = ref.read(databaseProvider);
  final storage = ref.read(fileStorageServiceProvider);
  return ChecklistRepository(db, storage);
});

final checklistListProvider =
    AsyncNotifierProvider<ChecklistNotifier, List<Checklist>>(
      ChecklistNotifier.new,
    );

class ChecklistNotifier extends AsyncNotifier<List<Checklist>> {
  late final ChecklistRepository _checklistRepository;

  @override
  Future<List<Checklist>> build() async {
    _checklistRepository = ref.read(checklistRepositoryProvider);
    return _checklistRepository.getAll();
  }

  Future<void> createChecklist(String title) async {
    state = const AsyncLoading();
    await _checklistRepository.createChecklistWithItems(title);
    state = AsyncData(await _checklistRepository.getAll());
  }

  void updateChecklistTitle(int checklistId, String newTitle) {
    final current = state.value;

    if (current == null) return;

    final updatedList = current.map((c) {
      if (c.id == checklistId) {
        return c.copyWith(title: newTitle);
      }
      return c;
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
