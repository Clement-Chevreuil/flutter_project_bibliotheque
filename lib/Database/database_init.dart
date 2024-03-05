import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_project_n1/Model/utilisateur.dart';
import 'package:permission_handler/permission_handler.dart';

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
  static Utilisateur? _utilisateur;

  Future<Database> initDatabase([String? name]) async {
    if (name != null) {
      defaultName = name;
    }

    final path = join(await getDatabasesPath(), defaultName);

    final db = await openDatabase(
      path,
      version: 6,
      onCreate: (db, version) async {
        for (String tableName in tableNames) {
          await db.execute(
            "CREATE TABLE $tableName(ID INTEGER PRIMARY KEY, Nom TEXT UNIQUE, Image BLOB, Note INTEGER, Statut TEXT, Genres TEXT, created_at DATETIME, updated_at DATETIME NULL)",
          );
        }
        await db.execute(
          "CREATE TABLE Episode(ID INTEGER PRIMARY KEY,ID_Saison INTEGER, Nom TEXT, Image BLOB, Note INTEGER NULL, Statut TEXT NULL, Avis TEXT NULL, Description TEXT NULL, created_at DATETIME, updated_at DATETIME NULL)",
        );
        await db.execute(
          "CREATE TABLE Saison(ID INTEGER PRIMARY KEY,ID_Media INTEGER,Media Text, Nom TEXT, Image BLOB, Note INTEGER NULL, Statut TEXT NULL, Avis TEXT NULL,Description TEXT NULL, created_at DATETIME, updated_at DATETIME NULL)",
        );
        await db.execute(
          "CREATE TABLE Genre (ID INTEGER PRIMARY KEY, Nom TEXT UNIQUE, Media TEXT)",
        );
         await db.execute(
          "CREATE TABLE Utilisateur (ID INTEGER PRIMARY KEY, Episode INTEGER, Saison INTEGER, created_at DATETIME, updated_at DATETIME NULL)",
        );
        await db.execute(
           "INSERT INTO Utilisateur (Episode, Saison, created_at) VALUES (0, 0, CURRENT_TIMESTAMP)"
        );
      },
    );

    return db;
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await DatabaseInit().initDatabase(); // Utilisez le constructeur pour initialiser la base de données.
    return _database!;
  }

    static Future<Utilisateur> get utilisateur async {
    if (_utilisateur != null) return _utilisateur!;

    _utilisateur = await DatabaseInit().get(); // Utilisez le constructeur pour initialiser la base de données.
    return _utilisateur!;
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

    static Future<void> update(Utilisateur book) async {
    book.updated_at = DateTime.now();

    await _database!.update(
      "Utilisateur",
      book.toMap(),
      where: "id = 1",
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _utilisateur = book;
  }

  Future<Utilisateur?> get() async {
    final List<Map<String, dynamic>> maps =
    await _database!.query("Utilisateur", where: 'id = ?', whereArgs: [1]);

    if (maps.isNotEmpty) {
      Map<String, dynamic> map = maps.first;
      print(map['updated_at']);

      DateTime? updatedAt;
      if (map['updated_at'] != null && map['updated_at'] != "") {
        updatedAt = DateTime.parse(map['updated_at']);
      }

      return Utilisateur(
        id: map['ID'],
        episode: map['Episode'],
        saison: map['Saison'],
        created_at: DateTime.parse(map['created_at']),
        updated_at: updatedAt,
      );
    } else {
      return null; // Utilisateur avec l'ID spécifié non trouvé
    }
  }

  DateTime? parseDate(String? dateStr) {
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        print('Erreur de parsing de la date: $e');
        return null;
      }
    } else {
      return null;
    }
  }

}
