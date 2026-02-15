import 'package:checkflow/core/services/file_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fileStorageServiceProvider = Provider<FileStorageService>((ref) {
  return FileStorageService();
});
