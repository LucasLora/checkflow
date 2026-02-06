import 'dart:io';

import 'package:checkflow/features/checklists/state/photo_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemPhotosPage extends ConsumerWidget {
  final int itemId;

  const ItemPhotosPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(photoNotifierProvider(itemId));

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
                            .read(photoNotifierProvider(itemId).notifier)
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO(lucaslora): abrir câmera/galeria
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
