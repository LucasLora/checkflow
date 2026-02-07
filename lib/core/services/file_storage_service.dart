import 'dart:io';

class FileStorageService {
  Future<void> deleteFile(String path) async {
    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }
}
