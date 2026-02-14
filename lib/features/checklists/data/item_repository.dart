import 'package:checkflow/core/database/app_database.dart';
import 'package:drift/drift.dart';

class ItemWithStatus {
  ItemWithStatus({required this.item, required this.hasPhotos});

  final Item item;
  bool hasPhotos;
}

class ItemWithPhotos {
  ItemWithPhotos({required this.item, required this.photos});

  final Item item;
  final List<Photo> photos;
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

      result.putIfAbsent(
        item.id,
        () => ItemWithStatus(item: item, hasPhotos: false),
      );

      if (photo != null) {
        result[item.id]!.hasPhotos = true;
      }
    }

    return result.values.toList();
  }

  Future<List<ItemWithPhotos>> getItemsWithPhotosByChecklist(
    int checklistId,
  ) async {
    final query = db.select(db.items).join([
      leftOuterJoin(db.photos, db.photos.itemId.equalsExp(db.items.id)),
    ])..where(db.items.checklistId.equals(checklistId));

    final rows = await query.get();

    final result = <int, ItemWithPhotos>{};

    for (final row in rows) {
      final item = row.readTable(db.items);
      final photo = row.readTableOrNull(db.photos);

      result.putIfAbsent(item.id, () => ItemWithPhotos(item: item, photos: []));

      if (photo != null) {
        result[item.id]!.photos.add(photo);
      }
    }

    return result.values.toList();
  }
}
