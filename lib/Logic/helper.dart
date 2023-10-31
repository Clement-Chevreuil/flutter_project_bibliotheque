import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;



class DatabaseHelper {
  String myBDD = 'maBDD3.db';

  Future<void> exportDatabase(BuildContext context) async {
    try {
      // Get the source database file
      String sourceDBPath = p.join(await getDatabasesPath(), myBDD);
      File sourceFile = File(sourceDBPath);

      // Get the downloads directory on Android
      String downloadsPath = '';
      if (Platform.isAndroid) {
        downloadsPath = '/storage/emulated/0/Download';
      }

      // Create the destination file in the downloads directory
      String destinationPath = p.join(downloadsPath, 'exported_database.db');
      File destinationFile = File(destinationPath);

      // Copy the source database file to the destination
      await sourceFile.copy(destinationPath);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database exported successfully')),
      );
    } catch (e) {
      print('Error exporting database: $e');
    }
  }

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

  
  Future<Uint8List?> openImagePicker(bool isImagePickerActive, ImagePicker picker) async {
    if (isImagePickerActive) {
      return null; // Return if the image picker is already active
    }

    isImagePickerActive = true; // Mark the image picker as active
    try {
      final pickedImage = await picker.getImage(source: ImageSource.gallery);

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

  Future<List<String>?> searchImages(String searchTerm) async {
    List<String> imageUrls;
    final apiKey = 'AIzaSyCK0hAKBHu6fQhlKTOtBj2LbKNTuniLNmA';
    final cx = '40dc66ef904ad48c9';
    final apiUrl =
        'https://www.googleapis.com/customsearch/v1?q=$searchTerm&key=$apiKey&cx=$cx&num=10&searchType=image';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Récupérez le nombre total de résultats en tant qu'entier.
        final int totalResults =
            int.tryParse(responseData['searchInformation']['totalResults']) ??
                0;

        // Affichez le nombre total de résultats dans la console.
        print('Nombre total de résultats : $totalResults');

        // Récupérez les liens vers les images à partir de la réponse.
        final List<dynamic> items = responseData['items'];
        imageUrls = [];
        for (var item in items) {
          final imageUrl = item['link'];
          imageUrls.add(imageUrl);
          print(imageUrl);
        }
        return imageUrls;
 
      } else {
        // Gérez les erreurs de l'API ici.
        print('Erreur de l\'API : ${response.statusCode}');
        // Affichez un message d'erreur à l'utilisateur.
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Erreur de l\'API')),
        // );
        return null;
      }
    } catch (e) {
      // Gérez les erreurs de requête ici.
      print('Erreur de requête : $e');
      // Affichez un message d'erreur à l'utilisateur.
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Erreur de requête')),
      // );
      return null;
    }
  }
}
