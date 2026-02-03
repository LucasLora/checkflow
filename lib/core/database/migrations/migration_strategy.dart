import 'package:checkflow/core/database/app_database.dart';
import 'package:checkflow/core/database/migrations/initial_migration.dart';
import 'package:drift/drift.dart';

MigrationStrategy buildMigrationStrategy(AppDatabase db) {
  return MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await initialMigration(db);
    },
  );
}
