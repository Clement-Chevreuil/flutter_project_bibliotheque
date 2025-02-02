import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_n1/exeptions/my_exceptions.dart';
import 'download_image.dart';

Future<Uint8List> urlPictureGestionnary(Uint8List? imageBytes, String? selectedImageUrl, BuildContext context) async {
  if (imageBytes == null && selectedImageUrl != null) {
    imageBytes = await downloadImage(selectedImageUrl);
  }

  if (imageBytes != null) {
    final imageSizeInBytes = imageBytes.lengthInBytes;
    final imageSizeInKB = imageSizeInBytes / 1024;
    final imageSizeInMB = imageSizeInKB / 1024;

    if (imageSizeInMB > 2) {
      throw MyException('Please fill in all fields');
    }
  } else {
    final ByteData data = await rootBundle.load('images/default_image.jpeg');
    final List<int> bytes = data.buffer.asUint8List();
    imageBytes = Uint8List.fromList(bytes);
  }

  return imageBytes;
}
