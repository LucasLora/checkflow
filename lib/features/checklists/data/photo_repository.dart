import 'package:checkflow/core/database/app_database.dart';
import 'package:drift/drift.dart';

class PhotoRepository {
  final AppDatabase db;

  PhotoRepository(this.db);

  Future<List<Photo>> getPhotosByItem(int itemId) {
    return (db.select(db.photos)
          ..where((tbl) => tbl.itemId.equals(itemId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.attachedAt)]))
        .get();
  }

  Future<void> addPhoto({required int itemId, required String path}) {
    return db
        .into(db.photos)
        .insert(PhotosCompanion(itemId: Value(itemId), path: Value(path)));
  }

  Future<void> deletePhoto(int photoId) {
    return (db.delete(db.photos)..where((tbl) => tbl.id.equals(photoId))).go();
  }
}
