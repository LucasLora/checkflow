import 'package:checkflow/core/database/app_database.dart';
import 'package:drift/drift.dart';

Future<void> initialMigration(AppDatabase db) async {
  await db.batch((batch) {
    batch.insertAll(
      db.templateItems,
      _initialTemplateTitles
          .map((title) => TemplateItemsCompanion(title: Value(title)))
          .toList(),
    );
  });
}

const _initialTemplateTitles = [
  'Template Item 1',
  'Template Item 2',
  'Template Item 3',
  'Template Item 4',
  'Template Item 5',
  'Template Item 6',
  'Template Item 7',
  'Template Item 8',
  'Template Item 9',
  'Template Item 10',
  'Template Item 11',
  'Template Item 12',
  'Template Item 13',
  'Template Item 14',
  'Template Item 15',
  'Template Item 16',
  'Template Item 17',
  'Template Item 18',
  'Template Item 19',
  'Template Item 20',
  'Template Item 21',
  'Template Item 22',
  'Template Item 23',
  'Template Item 24',
  'Template Item 25',
  'Template Item 26',
  'Template Item 27',
  'Template Item 28',
  'Template Item 29',
  'Template Item 30',
];
