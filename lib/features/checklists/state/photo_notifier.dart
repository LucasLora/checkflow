import 'package:checkflow/core/database/app_database.dart';
import 'package:checkflow/core/di/database_provider.dart';
import 'package:checkflow/features/checklists/data/photo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  final db = ref.read(databaseProvider);
  return PhotoRepository(db);
});

final photoNotifierProvider =
    AsyncNotifierProvider.family<PhotoNotifier, List<Photo>, int>(
      PhotoNotifier.new,
    );

class PhotoNotifier extends FamilyAsyncNotifier<List<Photo>, int> {
  late final PhotoRepository _repository;
  late final int _itemId;

  @override
  Future<List<Photo>> build(int itemId) async {
    _itemId = itemId;
    _repository = ref.read(photoRepositoryProvider);

    return _repository.getPhotosByItem(itemId);
  }

  Future<void> addPhoto(String path) async {
    state = const AsyncLoading();

    await _repository.addPhoto(itemId: _itemId, path: path);

    state = AsyncData(await _repository.getPhotosByItem(_itemId));
  }

  Future<void> deletePhoto(int photoId) async {
    final current = state.value ?? [];

    await _repository.deletePhoto(photoId);

    state = AsyncData(current.where((p) => p.id != photoId).toList());
  }
}
