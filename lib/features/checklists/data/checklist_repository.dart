import 'package:checkflow/core/database/app_database.dart';
import 'package:drift/drift.dart';

class ChecklistRepository {
  final AppDatabase db;

  ChecklistRepository(this.db);

  Future<List<Checklist>> getAll() {
    return db.select(db.checklists).get();
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
}
