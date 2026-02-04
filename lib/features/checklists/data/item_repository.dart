import 'package:checkflow/core/database/app_database.dart';

class ItemWithStatus {
  final Item item;
  final bool hasPhotos;

  ItemWithStatus({required this.item, required this.hasPhotos});
}

class ItemRepository {
  final AppDatabase db;

  ItemRepository(this.db);

  Future<List<ItemWithStatus>> getItemsByChecklist(int checklistId) async {
    final items = await (db.select(
      db.items,
    )..where((tbl) => tbl.checklistId.equals(checklistId))).get();

    return items
        .map(
          (item) => ItemWithStatus(
            item: item,
            hasPhotos:
                false, // TODO(lucaslora): Join with photos to get boolean
          ),
        )
        .toList();
  }
}
