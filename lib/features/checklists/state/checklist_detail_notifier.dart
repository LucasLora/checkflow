import 'package:checkflow/core/database/app_database.dart';
import 'package:checkflow/core/di/database_provider.dart';
import 'package:checkflow/features/checklists/data/checklist_repository.dart';
import 'package:checkflow/features/checklists/data/item_repository.dart';
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

final checklistDetailProvider =
    AsyncNotifierProvider.family<
      ChecklistDetailNotifier,
      ChecklistDetailState,
      int
    >(ChecklistDetailNotifier.new);

class ChecklistDetailNotifier
    extends FamilyAsyncNotifier<ChecklistDetailState, int> {
  late final ChecklistRepository _checklistRepository;
  late final ItemRepository _itemRepository;

  @override
  Future<ChecklistDetailState> build(int checklistId) async {
    _checklistRepository = ref.read(checklistRepositoryProvider);
    _itemRepository = ref.read(itemRepositoryProvider);

    final checklist = await _checklistRepository.getById(checklistId);
    final items = await _itemRepository.getItemsByChecklist(checklistId);

    return ChecklistDetailState(checklist: checklist, items: items);
  }
}
