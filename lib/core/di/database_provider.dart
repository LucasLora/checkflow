import 'package:checkflow/core/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.defaults();
  ref.onDispose(db.close);
  return db;
});
