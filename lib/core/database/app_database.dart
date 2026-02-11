import 'package:checkflow/core/database/migrations/migration_strategy.dart';
import 'package:checkflow/core/database/tables/checklists.dart';
import 'package:checkflow/core/database/tables/items.dart';
import 'package:checkflow/core/database/tables/photos.dart';
import 'package:checkflow/core/database/tables/template_items.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Checklists, TemplateItems, Items, Photos])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.defaults() : super(driftDatabase(name: 'checkflow_db'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => buildMigrationStrategy(this);
}
