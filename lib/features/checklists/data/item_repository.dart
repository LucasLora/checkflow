import 'package:checkflow/core/database/app_database.dart';
import 'package:drift/drift.dart';

class ItemWithStatus {
  ItemWithStatus({required this.item, required this.hasPhotos});

  final Item item;
  final bool hasPhotos;
}

class ItemRepository {
  ItemRepository(this.db);

  final AppDatabase db;

  Future<List<ItemWithStatus>> getItemsWithStatusByChecklist(
    int checklistId,
  ) async {
    final query = db.select(db.items).join([
      leftOuterJoin(db.photos, db.photos.itemId.equalsExp(db.items.id)),
    ])..where(db.items.checklistId.equals(checklistId));

    final rows = await query.get();

    final result = <int, ItemWithStatus>{};

    for (final row in rows) {
      final item = row.readTable(db.items);
      final photo = row.readTableOrNull(db.photos);

      result[item.id] ??= ItemWithStatus(item: item, hasPhotos: false);

      if (photo != null) {
        result[item.id] = ItemWithStatus(item: item, hasPhotos: true);
      }
    }

    return result.values.toList();
  }

  Future<List<Item>> getItemsByChecklist(int checklistId) {
    return (db.select(
      db.items,
    )..where((tbl) => tbl.checklistId.equals(checklistId))).get();
  }
}
