import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (photo == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final fileName = p.basename(photo.path);

    final savedImage = await File(
      photo.path,
    ).copy('${directory.path}/$fileName');

    return savedImage.path;
  }
}
