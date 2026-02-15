import 'package:checkflow/core/database/app_database.dart';
import 'package:checkflow/core/di/database_provider.dart';
import 'package:checkflow/features/checklists/data/checklist_repository.dart';
import 'package:checkflow/features/checklists/data/item_repository.dart';
import 'package:checkflow/features/checklists/services/checklist_zip_service.dart';
import 'package:checkflow/features/checklists/state/checklist_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final checklistZipServiceProvider = Provider<ChecklistZipService>((ref) {
  return ChecklistZipService(
    checklistRepository: ref.read(checklistRepositoryProvider),
    itemRepository: ref.read(itemRepositoryProvider),
  );
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final db = ref.read(databaseProvider);
  return ItemRepository(db);
});

final checklistDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ChecklistDetailNotifier, ChecklistDetailState, int>(
      ChecklistDetailNotifier.new,
    );

class ChecklistDetailState {
  ChecklistDetailState({required this.checklist, required this.items});

  final Checklist checklist;
  final List<ItemWithStatusDto> items;
}

class ChecklistDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<ChecklistDetailState, int> {
  late int _checklistId;

  late ChecklistRepository _checklistRepository;
  late ItemRepository _itemRepository;

  late ChecklistZipService _checklistZipService;

  @override
  Future<ChecklistDetailState> build(int checklistId) async {
    _checklistId = checklistId;

    _checklistRepository = ref.read(checklistRepositoryProvider);
    _itemRepository = ref.read(itemRepositoryProvider);

    _checklistZipService = ref.read(checklistZipServiceProvider);

    final checklist = await _checklistRepository.getById(_checklistId);
    final items = await _itemRepository.getItemsWithStatusByChecklist(
      _checklistId,
    );

    return ChecklistDetailState(checklist: checklist, items: items);
  }

  Future<void> updateChecklistTitle(String newTitle) async {
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
    final current = state.value;

    if (current == null) return;

    await _checklistRepository.delete(current.checklist.id);
  }

  Future<({String path, String fileName})> exportZip() async {
    return _checklistZipService.generateZip(_checklistId);
  }
}
