import 'package:checkflow/core/database/tables/items.dart';
import 'package:drift/drift.dart';

class Photos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get path => text()();

  DateTimeColumn get attachedAt => dateTime().withDefault(currentDateAndTime)();

  IntColumn get itemId =>
      integer().references(Items, #id, onDelete: KeyAction.cascade)();
}
