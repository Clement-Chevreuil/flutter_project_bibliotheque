import 'package:flutter_project_n1/models/genre.dart';

import 'database_init.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseGenre {
  String defaultName = "maBDD3.db";
  final dbProvider = DatabaseInit.database;

  Future<int?> insert(Genre genre) async {
    final db = await dbProvider;
    int id = await db.insert(
      "Genre",
      genre.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    return id;
  }

  Future<int?> update(Genre genre) async {
    final db = await dbProvider;

    int id = await db.update(
      "Genre",
      genre.toMap(),
      where: "ID = ?",
      whereArgs: [genre.id],
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    return id;
  }

  Future<Genre?> getGenresWithID(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query("Genre", where: 'ID = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      Map<String, dynamic> map = maps.first;
      return Genre(
        id: map['ID'],
        nom: map['Nom'],
        media: map['Media'],
      );
    } else {
      return null; // Media with the specified ID not found
    }
  }

  Future<List<Genre>> getGenres(String? table, String search) async {
    final db = await dbProvider;
    String whereConditions = "";
    List<dynamic> whereValues = [];

    whereConditions += ' WHERE Media LIKE ?';
    whereValues.add('$table');

    if (search.isNotEmpty) {
      whereConditions += ' AND Nom LIKE ?';
      whereValues.add('%$search%');
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM Genre $whereConditions',
      whereValues,
    );

    return List.generate(maps.length, (i) {
      return Genre(
        id: maps[i]['ID'],
        nom: maps[i]['Nom'],
        media: maps[i]['Media'],
      );
    });
  }

  Future<List<String>> getGenresList(String? table, String search) async {
    final db = await dbProvider;
    String whereConditions = "";
    List<dynamic> whereValues = [];

    whereConditions += ' WHERE Media LIKE ?';
    whereValues.add('$table');

    if (search != null && search.isNotEmpty) {
      whereConditions += ' AND Nom LIKE ?';
      whereValues.add('%$search%');
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM Genre $whereConditions',
      whereValues,
    );

    return List.generate(maps.length, (i) {
      return maps[i]['Nom'];
    });
  }

  Future<void> delete(Genre genre) async {
    final db = await dbProvider;
    await db.delete(
      "Genre",
      where: 'ID = ?',
      whereArgs: [genre.id],
    );
  }
}
