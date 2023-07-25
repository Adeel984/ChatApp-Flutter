import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImageHelper {
  Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }
}
