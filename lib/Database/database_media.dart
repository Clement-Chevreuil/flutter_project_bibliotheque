import 'package:flutter_project_n1/models/media.dart';
import 'package:sqflite/sqflite.dart';
import 'database_init.dart';
import 'dart:typed_data';

class DatabaseMedia {
  String table;
  DatabaseMedia(this.table);

  final List<String> tableNames = ["Series", "Animes", "Games", "Webtoons", "Books", "Movies"];
  final dbProvider = DatabaseInit.database;

  Future<void> changeTable(String name) async {
    table = name;
  }

  //CRUD

  Future<int> insertMedia(Media book) async {
    book.created_at = DateTime.now();
    book.updated_at = null;
    final db = await dbProvider;
    int id = await db.insert(
      table,
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return id;
  }

  Future<int?> updateMedia(Media book) async {
    book.updated_at = DateTime.now();
    final db = await dbProvider;

    int id = await db.update(
      table,
      {
        'nom': book.nom,
        'image': book.image, // Utilisez Uint8List pour stocker des données binaires
        'note': book.note,
        'statut': book.statut,
        'genres': book.genres?.join(', '),
        'updated_at': book.updated_at?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [book.id],
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return id;
  }

  Future<void> deleteMedia(Media book) async {
    final db = await dbProvider;
    await db.delete(
      table,
      where: 'ID = ?',
      whereArgs: [book.id],
    );
  }

  Future<Media?> getMediaWithId(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps = await db.query(table, where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      Map<String, dynamic> map = maps.first;
      return Media(
        id: map['ID'],
        nom: map['Nom'],
        image: map['Image'],
        note: map['Note'],
        statut: map['Statut'],
        genres: map['Genres']?.split(',').toList(),
        created_at: DateTime.parse(map['created_at']),
        updated_at: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      );
    } else {
      return null; // Media with the specified ID not found
    }
  }

  //END

  Future<List<Media>> getMedias(int pageNumber, String? statut, String? order, Set<String>? genres, String search, String orderAscDesc) async {
    final db = await dbProvider;
// Get the total page count
    int offset = (pageNumber - 1) * (10);
    List<String> whereConditions = [];
    List<dynamic> whereValues = [];

    if (search.isNotEmpty) {
      whereConditions.add('Nom LIKE ?');
      whereValues.add('%$search%');
    }

    if (statut != null) {
      whereConditions.add('Statut = ?');
      whereValues.add(statut);
    }

    if (genres != null && genres.isNotEmpty) {
      whereConditions.add('Genres IN (${genres.map((_) => '?').join(', ')})');
      whereValues.addAll(genres.toList());
    }

    String whereClause = whereConditions.isNotEmpty ? 'WHERE ${whereConditions.join(' AND ')}' : '';

    if (orderAscDesc == "Ascendant") {
      orderAscDesc = "ASC";
    } else {
      orderAscDesc = "DESC";
    }

    if (order == "AJOUT") {
      order = "created_at";
    }
    if (order != null) {
      whereClause += (' ORDER BY $order $orderAscDesc');
    }

    whereValues.add(offset);

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM $table $whereClause LIMIT 10 OFFSET ?',
      whereValues,
    );

    return List.generate(maps.length, (i) {
      return Media(
        id: maps[i]['ID'],
        nom: maps[i]['Nom'],
        image: maps[i]['Image'],
        note: maps[i]['Note'],
        statut: maps[i]['Statut'],
        genres: maps[i]['Genres']?.split(', ').toList(),
        created_at: maps[i]['created_at'] != null ? DateTime.parse(maps[i]['created_at']) : null,
        updated_at: maps[i]['updated_at'] != null ? DateTime.parse(maps[i]['updated_at']) : null,
      );
    });
  }

  Future<List<Media>> getMediasSimpleVersion() async {
    final db = await dbProvider;

    List<dynamic> whereValues = [];

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM $table WHERE LENGTH(Image) <= 2 * 1024 * 1024 LIMIT 90',
      whereValues,
    );

    return List.generate(maps.length, (i) {
      return Media(
        nom: maps[i]['Nom'],
        image: maps[i]['Image'] is Uint8List ? maps[i]['Image'] : maps[i - 1]['Image'],
        note: maps[i]['Note'],
        statut: maps[i]['Statut'],
      );
    });
  }

  Future<int?> countPageMedia(String? statut, Set<String>? genres, String search) async {
    List<String> whereConditions = [];
    List<dynamic> whereValues = [];

    final db = await dbProvider;

    if (search.isNotEmpty) {
      whereConditions.add('Nom LIKE ?');
      whereValues.add('%$search%');
    }

    if (statut != null) {
      whereConditions.add('Statut = ?');
      whereValues.add(statut);
    }

    if (genres != null && genres.isNotEmpty) {
      whereConditions.add('Genres IN (${genres.map((_) => '?').join(', ')})');
      whereValues.addAll(genres.toList());
    }

    whereConditions.add('LENGTH(Image) <= ?');
    whereValues.add(2 * 1024 * 1024);

    String whereClause = whereConditions.isNotEmpty ? ' WHERE ${whereConditions.join(' AND ')}' : '';

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table $whereClause',
      whereValues,
    );
    int? count = Sqflite.firstIntValue(result);

    if (count != null) {
      int totalPage = (count + 10 - 1) ~/ 10;
      return totalPage;
    } else {
      return null;
    }
  }

  Future<Map<String, int>> getCountsForTables() async {
    Map<String, int> counts = {};
    final db = await dbProvider;
    for (String tableName in tableNames) {
      final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
      final counte = Sqflite.firstIntValue(result);
      counts[tableName] = counte!;
    }

    return counts;
  }

  Future<Map<String, int>> getCountsByStatut() async {
    Database db = await dbProvider;

    List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT
      SUM(CASE WHEN statut = 'Fini' THEN 1 ELSE 0 END) AS countFini,
      SUM(CASE WHEN statut = 'En cours' THEN 1 ELSE 0 END) AS countEnCours,
      SUM(CASE WHEN statut = 'Abandonnee' THEN 1 ELSE 0 END) AS countAbandonner,
      SUM(CASE WHEN statut = 'Envie de regarder' THEN 1 ELSE 0 END) AS countEnvieDeRegarder
    FROM $table
  ''');

    return {
      'countFini': result[0]['countFini'] as int? ?? 0,
      'countEnCours': result[0]['countEnCours'] as int? ?? 0,
      'countAbandonner': result[0]['countAbandonner'] as int? ?? 0,
      'countEnvieDeRegarder': result[0]['countEnvieDeRegarder'] as int? ?? 0,
    };
  }

  Future<List<Media>> getMostRecentRecords() async {
    Database db = await dbProvider; // Replace dbProvider with your actual Database instance provider function
    List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT *
    FROM $table
    ORDER BY DATETIME(created_at) DESC, DATETIME(updated_at) DESC
    LIMIT 6
  ''');

    return List.generate(maps.length, (i) {
      return Media(
        nom: maps[i]['Nom'],
        note: maps[i]['Note'],
        created_at: maps[i]['created_at'] != null ? DateTime.parse(maps[i]['created_at']) : null,
        updated_at: maps[i]['updated_at'] != null ? DateTime.parse(maps[i]['updated_at']) : null,
      );
    });
  }

  Future<List<Map<String, dynamic>>> getCountByDate() async {
    Database db = await dbProvider; // Remplacez dbProvider par votre fonction réelle pour obtenir une instance de Database
    List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT DATE(created_at) as date, COUNT(*) as count
    FROM $table
    GROUP BY date
  ''');

    return result;
  }

  Future<List<Map<String, dynamic>>> getMostViewedGenresByMonth() async {
    Database db = await dbProvider;
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT strftime('%Y-%m', created_at) as month,
             genres,
             COUNT(*) as count
      FROM $table
      GROUP BY month, genres
      ORDER BY month, count DESC
    ''');
    return result;
  }
}
