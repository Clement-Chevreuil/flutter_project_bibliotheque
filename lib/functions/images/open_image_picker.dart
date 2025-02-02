import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> openImagePicker(bool isImagePickerActive, ImagePicker picker) async {
  if (isImagePickerActive) {
    return null;
  }

  isImagePickerActive = true;
  try {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      Uint8List imageBytes = await pickedImage.readAsBytes();
      return imageBytes;
    }
  } catch (e) {
    return null;
  } finally {
    isImagePickerActive = false;
  }
  return null;
}
