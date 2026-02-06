import 'package:checkflow/core/database/app_database.dart';
import 'package:drift/drift.dart';

class ChecklistRepository {
  final AppDatabase db;

  ChecklistRepository(this.db);

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
    await db.transaction(() async {
      await (db.delete(db.photos)..where(
            (tbl) => tbl.itemId.isInQuery(
              db.selectOnly(db.items)
                ..addColumns([db.items.id])
                ..where(db.items.checklistId.equals(checklistId)),
            ),
          ))
          .go();

      await (db.delete(
        db.items,
      )..where((tbl) => tbl.checklistId.equals(checklistId))).go();

      await (db.delete(
        db.checklists,
      )..where((tbl) => tbl.id.equals(checklistId))).go();
    });
  }
}
