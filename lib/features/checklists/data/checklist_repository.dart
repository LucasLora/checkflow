import 'package:checkflow/core/database/app_database.dart';
import 'package:checkflow/core/services/file_storage_service.dart';
import 'package:drift/drift.dart';

class ChecklistRepository {
  ChecklistRepository(this.db, this.storage);

  final AppDatabase db;
  final FileStorageService storage;

  Future<List<Checklist>> getAll() {
    return (db.select(
      db.checklists,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.id)])).get();
  }

  Future<void> createChecklistWithItems(String title) async {
    await db.transaction(() async {
      final checklistId = await db
          .into(db.checklists)
          .insert(ChecklistsCompanion(title: Value(title)));

      final templates = await db.select(db.templateItems).get();

      await db.batch((batch) {
        batch.insertAll(
          db.items,
          templates
              .map(
                (t) => ItemsCompanion(
                  title: Value(t.title),
                  checklistId: Value(checklistId),
                ),
              )
              .toList(),
        );
      });
    });
  }

  Future<Checklist> getById(int id) {
    return (db.select(
      db.checklists,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<void> updateTitle(int checklistId, String newTitle) {
    return (db.update(db.checklists)
          ..where((tbl) => tbl.id.equals(checklistId)))
        .write(ChecklistsCompanion(title: Value(newTitle)));
  }

  Future<void> delete(int checklistId) async {
    final photos =
        await (db.select(db.photos).join([
              innerJoin(db.items, db.items.id.equalsExp(db.photos.itemId)),
            ])..where(db.items.checklistId.equals(checklistId)))
            .map((row) => row.readTable(db.photos))
            .get();

    final photosPaths = photos.map((p) => p.path).toList();

    await (db.delete(
      db.checklists,
    )..where((tbl) => tbl.id.equals(checklistId))).go();

    for (final photoPath in photosPaths) {
      await storage.deleteFile(photoPath);
    }
  }
}
