import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';



class OpenImagePicker {

  Future<Uint8List?> openImagePicker(bool isImagePickerActive, ImagePicker picker) async {
    if (isImagePickerActive) {
      return null; // Return if the image picker is already active
    }

    isImagePickerActive = true; // Mark the image picker as active
    try {
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        Uint8List imageBytes = await pickedImage.readAsBytes();
        return imageBytes;
      }
    } catch (e) {
      print('Error selecting image: $e');
    } finally {
      isImagePickerActive = false; // Mark the image picker as not active
    }
  }
}