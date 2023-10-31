import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as p;

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_project_n1/Interfaces/genres_index.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Logic/function_helper.dart';
import '../Database/database_media.dart';
import '../Database/database_genre.dart';
import '../Model/media.dart';
import '../Model/genre.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:getwidget/getwidget.dart';
import '/Database/database_init.dart';

class DatabaseReader {
  String? defaultName = null;
  FilePickerResult? result = null;
  String? databaseFilePath = null;

  DatabaseReader() {
    //initDatabase();
  }

  final List<String> tableNames = [
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies"
  ];
  static Database? _database;

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database =
          null; // Assurez-vous de réinitialiser la référence à la base de données après sa fermeture.
    }
  }

  Future<List<Media>?> ChooseDatabase(String condition) async {
    print("hereTest");
    try {
      // Sélectionner un fichier depuis l'appareil
      if(result == null)
      {
         result =
          await FilePicker.platform.pickFiles(type: FileType.any);
      }

      if (result != null) {
        // Récupérer le fichier sélectionné
        databaseFilePath  = result!.files.single.path!;

        if (databaseFilePath == null) {
          // Handle the case where the database file path is null.
          print("Database file path is null.");
        }

        else{
          print("good");
        }
      
      
     

        final database = await openDatabase(databaseFilePath!);
        final List<Map<String, dynamic>> maps = await database.rawQuery(condition);

        return List.generate(maps.length, (i) {
          return Media(
            nom: maps[i]['Nom'],
            image: maps[i]['Image'] is Uint8List ? maps[i]['Image'] : maps[i-1]['Image'],
            note: maps[i]['Note'],
            statut: maps[i]['Statut'],
          );
        });
      } else {
        print("error: FilePickerResult is null.");
        return null;
      }
    } catch (e) {
      print("error: $e");
      return null;
    }
  }

  Future<void> saveAndReadDatabase(String databasePath) async {
    try {
      final Database database = await openDatabase(
        databasePath,
        version:
            1, // Vous pouvez spécifier la version de la base de données ici
      );

      final List<Map<String, dynamic>> rows = await database.query('maTable');

      for (final row in rows) {
        final int id = row['id'];
        final String nom = row['nom'];
        final int age = row['age'];

        // Faites ce que vous souhaitez avec les données
        print('ID: $id, Nom: $nom, Âge: $age');
      }

      // Fermer la base de données lorsque vous avez terminé
      await database.close();
    } catch (e) {
      print(e);
    }
  }
}
