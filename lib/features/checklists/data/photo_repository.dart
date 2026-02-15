import 'package:checkflow/core/database/app_database.dart';
import 'package:checkflow/core/services/file_storage_service.dart';
import 'package:drift/drift.dart';

class PhotoRepository {
  PhotoRepository(this.db, this.storage);

  final AppDatabase db;
  final FileStorageService storage;

  Future<List<Photo>> getPhotosByItem(int itemId) {
    return (db.select(db.photos)
          ..where((tbl) => tbl.itemId.equals(itemId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.id)]))
        .get();
  }

  Future<int> addPhoto({required int itemId, required String path}) {
    return db
        .into(db.photos)
        .insert(PhotosCompanion(itemId: Value(itemId), path: Value(path)));
  }

  Future<void> deletePhoto(Photo photo) async {
    await (db.delete(db.photos)..where((tbl) => tbl.id.equals(photo.id))).go();

    await storage.deleteFile(photo.path);
  }
}
