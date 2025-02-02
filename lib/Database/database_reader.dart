import 'package:sqflite/sqflite.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/media.dart';
import 'package:file_picker/file_picker.dart';

class DatabaseReader {
  String? defaultName;
  FilePickerResult? result;
  String? databaseFilePath;

  DatabaseReader() {
    //initDatabase();
  }

  final List<String> tableNames = ["Series", "Animes", "Games", "Webtoons", "Books", "Movies"];
  static Database? _database;

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<List<Media>?> chooseDatabase(String condition) async {
    try {
      result ??= await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null) {
        databaseFilePath = result!.files.single.path!;

        final database = await openDatabase(databaseFilePath!);
        final List<Map<String, dynamic>> maps = await database.rawQuery(condition);

        return List.generate(
          maps.length,
          (i) {
            return Media(
              nom: maps[i]['Nom'],
              image: maps[i]['Image'] is Uint8List ? maps[i]['Image'] : maps[i - 1]['Image'],
              note: maps[i]['Note'],
              statut: maps[i]['Statut'],
            );
          },
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> saveAndReadDatabase(String databasePath) async {
    try {
      final Database database = await openDatabase(
        databasePath,
        version: 1, // Vous pouvez spécifier la version de la base de données ici
      );

      final List<Map<String, dynamic>> rows = await database.query('maTable');

      for (final row in rows) {
        final int id = row['id'];
        final String nom = row['nom'];
        final int age = row['age'];
      }

      // Fermer la base de données lorsque vous avez terminé
      await database.close();
    } catch (e) {}
  }
}
