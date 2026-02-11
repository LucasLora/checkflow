import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:checkflow/features/checklists/data/checklist_repository.dart';
import 'package:checkflow/features/checklists/data/item_repository.dart';
import 'package:checkflow/features/checklists/data/photo_repository.dart';

class ChecklistZipService {
  final ChecklistRepository checklistRepository;
  final ItemRepository itemRepository;
  final PhotoRepository photoRepository;

  ChecklistZipService({
    required this.checklistRepository,
    required this.itemRepository,
    required this.photoRepository,
  });

  Future<String> generateZip(int checklistId) async {
    final checklist = await checklistRepository.getById(checklistId);
    final items = await itemRepository.getItemsByChecklist(checklistId);

    final archive = Archive();

    final List<Map<String, Object>> itemsMetadata = [];
    final Map<String, Object> metadata = {
      'checklistId': checklist.id,
      'title': checklist.title,
      'createdAt': checklist.createdAt.toIso8601String(),
      'items': itemsMetadata,
    };

    for (final item in items) {
      final photoList = [];

      final photos = await photoRepository.getPhotosByItem(item.id);

      for (final photo in photos) {
        final extension = p.extension(photo.path);
        final safeExtension = extension.isNotEmpty ? extension : '.jpg';

        final fileName = '${photo.id}_photo$safeExtension';
        final entryName = p.join('photos', fileName).replaceAll('\\', '/');

        final file = File(photo.path);
        final exists = await file.exists();

        photoList.add({
          'photoId': photo.id,
          'fileName': fileName,
          'path': entryName,
          'attachedAt': photo.attachedAt.toIso8601String(),
          'missing': !exists,
        });

        if (exists) {
          final bytes = await file.readAsBytes();
          archive.addFile(ArchiveFile(entryName, bytes.length, bytes));
        }
      }

      itemsMetadata.add({
        'itemId': item.id,
        'title': item.title,
        'photos': photoList,
      });
    }

    final metadataJson = const JsonEncoder.withIndent('  ').convert(metadata);
    final metadataBytes = utf8.encode(metadataJson);
    archive.addFile(
      ArchiveFile('metadata.json', metadataBytes.length, metadataBytes),
    );

    final zipData = ZipEncoder().encode(archive);

    final directory = await getApplicationDocumentsDirectory();

    final safeTitle = checklist.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    final zipPath = p.join(directory.path, '$safeTitle.zip');

    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(zipData);

    return zipPath;
  }
}
