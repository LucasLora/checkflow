import 'dart:io';

import 'package:checkflow/features/checklists/state/photo_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemPhotosPage extends ConsumerWidget {
  const ItemPhotosPage({
    required this.itemId,
    required this.checklistId,
    super.key,
  });

  final int itemId;
  final int checklistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      photoNotifierProvider((itemId: itemId, checklistId: checklistId)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Fotos')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(child: Text('Nenhuma foto adicionada'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];

              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.file(File(photo.path), fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        ref
                            .read(
                              photoNotifierProvider((
                                itemId: itemId,
                                checklistId: checklistId,
                              )).notifier,
                            )
                            .deletePhoto(photo.id);
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () async {
              final imageService = ref.read(imageServiceProvider);

              final path = await imageService.takePhoto();
              if (path == null) return;

              await ref
                  .read(
                    photoNotifierProvider((
                      itemId: itemId,
                      checklistId: checklistId,
                    )).notifier,
                  )
                  .addPhoto(path);
            },
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: () async {
              final imageService = ref.read(imageServiceProvider);

              final path = await imageService.pickFromGallery();
              if (path == null) return;

              await ref
                  .read(
                    photoNotifierProvider((
                      itemId: itemId,
                      checklistId: checklistId,
                    )).notifier,
                  )
                  .addPhoto(path);
            },
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
