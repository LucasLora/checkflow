import 'package:checkflow/core/database/app_database.dart';
import 'package:checkflow/core/di/database_provider.dart';
import 'package:checkflow/features/checklists/data/checklist_repository.dart';
import 'package:checkflow/features/checklists/data/item_repository.dart';
import 'package:checkflow/features/checklists/services/zip_service.dart';
import 'package:checkflow/features/checklists/state/checklist_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final db = ref.read(databaseProvider);
  return ItemRepository(db);
});

class ChecklistDetailState {
  final Checklist checklist;
  final List<ItemWithStatus> items;

  ChecklistDetailState({required this.checklist, required this.items});
}

final checklistDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ChecklistDetailNotifier, ChecklistDetailState, int>(
      ChecklistDetailNotifier.new,
    );

final checklistZipServiceProvider = Provider<ChecklistZipService>((ref) {
  return ChecklistZipService(
    checklistRepository: ref.read(checklistRepositoryProvider),
    itemRepository: ref.read(itemRepositoryProvider),
  );
});

class ChecklistDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<ChecklistDetailState, int> {
  late ChecklistRepository _checklistRepository;
  late ItemRepository _itemRepository;
  late int _checklistId;

  @override
  Future<ChecklistDetailState> build(int checklistId) async {
    _checklistId = checklistId;
    _checklistRepository = ref.read(checklistRepositoryProvider);
    _itemRepository = ref.read(itemRepositoryProvider);

    final checklist = await _checklistRepository.getById(_checklistId);
    final items = await _itemRepository.getItemsWithStatusByChecklist(
      _checklistId,
    );

    return ChecklistDetailState(checklist: checklist, items: items);
  }

  Future<void> updateTitle(String newTitle) async {
    final current = state.value;

    if (current == null) return;

    await _checklistRepository.updateTitle(current.checklist.id, newTitle);

    state = AsyncData(
      ChecklistDetailState(
        checklist: current.checklist.copyWith(title: newTitle),
        items: current.items,
      ),
    );
  }

  Future<void> deleteChecklist() async {
    final checklistId = state.value?.checklist.id;

    if (checklistId == null) return;

    await _checklistRepository.delete(checklistId);
  }

  Future<String> exportZip() async {
    final zipService = ref.read(checklistZipServiceProvider);
    return zipService.generateZip(_checklistId);
  }
}
