import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'download_image.dart';

class UrlPictureGestionnary {
  DownloadImage downloadImage = new DownloadImage();

  Future<Uint8List?> urlPictureGestionnary(Uint8List? imageBytes, String? selectedImageUrl, BuildContext context) async
  {

    if (imageBytes == null && selectedImageUrl != null)
    {
      imageBytes = await downloadImage.downloadImage(selectedImageUrl!);
    }

    if (imageBytes != null)
    {
      final imageSizeInBytes = imageBytes!.lengthInBytes;
      final imageSizeInKB = imageSizeInBytes / 1024;
      final imageSizeInMB = imageSizeInKB / 1024;

      if (imageSizeInMB > 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'La taille est trop Grande veuillez choisir une image plus petite.')),
        );

      }
    }

    else
    {
      final ByteData data = await rootBundle.load('images/default_image.jpeg');
      final List<int> bytes = data.buffer.asUint8List();
      imageBytes = Uint8List.fromList(bytes);
    }

    return imageBytes;
  }
}
