import 'package:checkflow/core/database/app_database.dart';
import 'package:checkflow/core/di/database_provider.dart';
import 'package:checkflow/features/checklists/data/photo_repository.dart';
import 'package:checkflow/features/checklists/services/image_service.dart';
import 'package:checkflow/features/checklists/state/checklist_detail_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  final db = ref.read(databaseProvider);
  return PhotoRepository(db);
});

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

final photoNotifierProvider =
    AsyncNotifierProvider.family<
      PhotoNotifier,
      List<Photo>,
      ({int itemId, int checklistId})
    >(PhotoNotifier.new);

class PhotoNotifier
    extends FamilyAsyncNotifier<List<Photo>, ({int itemId, int checklistId})> {
  late final PhotoRepository _repository;
  late final int _itemId;
  late final int _checklistId;

  @override
  Future<List<Photo>> build(({int itemId, int checklistId}) args) async {
    _itemId = args.itemId;
    _checklistId = args.checklistId;
    _repository = ref.read(photoRepositoryProvider);

    return _repository.getPhotosByItem(_itemId);
  }

  Future<void> addPhoto(String path) async {
    final current = state.value ?? [];

    final photoId = await _repository.addPhoto(itemId: _itemId, path: path);

    state = AsyncData([
      Photo(
        id: photoId,
        itemId: _itemId,
        path: path,
        attachedAt: DateTime.now(),
      ),
      ...current,
    ]);

    ref.invalidate(checklistDetailProvider(_checklistId));
  }

  Future<void> deletePhoto(int photoId) async {
    final current = state.value ?? [];

    await _repository.deletePhoto(photoId);

    state = AsyncData(current.where((p) => p.id != photoId).toList());

    ref.invalidate(checklistDetailProvider(_checklistId));
  }
}
