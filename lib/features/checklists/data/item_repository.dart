import 'package:checkflow/core/database/app_database.dart';
import 'package:drift/drift.dart';

class ItemWithStatus {
  final Item item;
  final bool hasPhotos;

  ItemWithStatus({required this.item, required this.hasPhotos});
}

class ItemRepository {
  final AppDatabase db;

  ItemRepository(this.db);

  Future<List<ItemWithStatus>> getItemsByChecklist(int checklistId) async {
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
}
