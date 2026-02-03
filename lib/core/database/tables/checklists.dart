import 'package:drift/drift.dart';

class Checklists extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
