import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = Uuid();

  Future<String?> takePhoto() {
    return _pickAndSave(ImageSource.camera);
  }

  Future<String?> pickFromGallery() {
    return _pickAndSave(ImageSource.gallery);
  }

  Future<String?> _pickAndSave(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image == null) return null;

    final directory = await getApplicationDocumentsDirectory();

    final extension = p.extension(image.path);
    final uniqueName = '${_uuid.v4()}$extension';

    final savedImage = await File(
      image.path,
    ).copy('${directory.path}/$uniqueName');

    return savedImage.path;
  }
}
