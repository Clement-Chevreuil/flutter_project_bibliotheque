import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;


class DownloadImage {

  String myBDD = 'maBDD3.db';
  Future<Uint8List?> downloadImage(String imageUrl) async {
    Uint8List? imageBytes;
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final imageBytes2 = response.bodyBytes;
        imageBytes = Uint8List.fromList(imageBytes2);
        return imageBytes; // Image téléchargée avec succès
      } else {
        print(
            'Échec du téléchargement de l\'image. Statut HTTP : ${response.statusCode}');
        return null; // Échec du téléchargement de l'image
      }
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image : $e');
      return null; // Erreur lors du téléchargement de l'image
    }
  }
}