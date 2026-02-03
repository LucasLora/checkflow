import 'package:drift/drift.dart';

class TemplateItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();
}
