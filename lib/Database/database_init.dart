import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';

import 'dart:io';

class DatabaseInit {
  String defaultName = "maBDD3.db";

  DatabaseInit() {
    initDatabase();
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

  Future<Database> initDatabase([String? name]) async {
    if (name != null) {
      defaultName = name;
    }

    final path = join(await getDatabasesPath(), defaultName);

    final db = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        for (String tableName in tableNames) {
          await db.execute(
            "CREATE TABLE $tableName(ID INTEGER PRIMARY KEY, Nom TEXT, Image BLOB, Note INTEGER, Statut TEXT, Genres TEXT, created_at DATETIME, updated_at DATETIME NULL)",
          );
        }
        await db.execute(
          "CREATE TABLE Episode(ID INTEGER PRIMARY KEY,ID_Saison INTEGER, Nom TEXT, Image BLOB, Note INTEGER NULL, Statut TEXT NULL, Avis TEXT NULL, Description TEXT NULL, created_at DATETIME, updated_at DATETIME NULL)",
        );
        await db.execute(
          "CREATE TABLE Saison(ID INTEGER PRIMARY KEY,ID_Media INTEGER,Media Text, Nom TEXT, Image BLOB, Note INTEGER NULL, Statut TEXT NULL, Avis TEXT NULL,Description TEXT NULL, created_at DATETIME, updated_at DATETIME NULL)",
        );
        await db.execute(
          "CREATE TABLE Genre (ID INTEGER PRIMARY KEY, Nom TEXT, Media TEXT)",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
      },
    );
    return db;
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await DatabaseInit()
        .initDatabase(); // Utilisez le constructeur pour initialiser la base de données.
    return _database!;
  }
  

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database =
          null; // Assurez-vous de réinitialiser la référence à la base de données après sa fermeture.
    }
  }

   Future<void> exportDatabaseWithUserChoice() async {
  // Demander à l'utilisateur de choisir un emplacement pour l'export
  final result = await FilePicker.platform.getDirectoryPath();
  if (result != null) {
    final exportPath = join(result, 'exported_database.db');

    // Fermer la base de données pour éviter les conflits pendant la copie
    closeDatabase();

    // Copier le fichier de base de données vers l'emplacement choisi
    final dbFile = File(_database!.path);
    final outputFile = File(exportPath);

    if (dbFile.existsSync()) {
      await dbFile.copy(outputFile.path);

      // Rouvrir la base de données pour une utilisation ultérieure
      initDatabase();
    } else {
      throw Exception('La base de données source n\'existe pas.');
    }
  }
  }

}
