import 'package:checkflow/core/database/tables/checklists.dart';
import 'package:drift/drift.dart';

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  IntColumn get checklistId =>
      integer().references(Checklists, #id, onDelete: KeyAction.cascade)();
}
