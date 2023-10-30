import '../Model/media.dart';
import 'package:sqflite/sqflite.dart';
import 'database_init.dart';
import 'dart:typed_data';

class DatabaseMedia {
  String table;
  DatabaseMedia(this.table);

  final List<String> tableNames = [
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies"
  ];
  final dbProvider = DatabaseInit.database;

  Future<void> changeTable(String name) async {
    table = name;
  }

  //CRUD

  Future<int> insertMedia(Media book) async {
    book.created_at =  DateTime.now();
    book.updated_at =  null;
    final db = await dbProvider;
    int id = await db.insert(
      table,
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> updateMedia(Media book) async {
  book.updated_at = DateTime.now();
  final db = await dbProvider;
  
  await db.update(
    table,
    book.toMap(),
    where: "id = ?",
    whereArgs: [book.id],
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
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
    final List<Map<String, dynamic>> maps =
        await db.query(table, where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      Map<String, dynamic> map = maps.first;
      return Media(
          id: map['ID'],
          nom: map['Nom'],
          image: map['Image'],
          note: map['Note'],
          statut: map['Statut'],
          genres:
              map['Genres'] != null ? map['Genres'].split(',').toList() : null,
          created_at :   DateTime.parse(map['created_at']),
          updated_at :  map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
          );
    } else {
      return null; // Media with the specified ID not found
    }
  }

  //END

  Future<List<Media>> getMedias(int pageNumber, String? statut, String? order, Set<String>? genres, String search, String orderAscDesc) async {
    final db = await dbProvider;
    int? count = await countPageMedia(statut, genres, search); // Get the total page count
    int offset = (pageNumber - 1) * (10);
    List<String> whereConditions = [];
    List<dynamic> whereValues = [];

    if (search != null && search.isNotEmpty) {
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

    String whereClause = whereConditions.isNotEmpty
        ? 'WHERE ${whereConditions.join(' AND ')}'
        : '';

    if(orderAscDesc == "Ascendant")
    {
      orderAscDesc = "ASC";
    }
    else
    {
      orderAscDesc = "DESC";
    }

    if(order == "AJOUT")
    {
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
        genres: maps[i]['Genres'] != null
            ? maps[i]['Genres'].split(', ').toList()
            : null,

        created_at :  maps[i]['updated_at'] != null ?  DateTime.parse(maps[i]['created_at']) : null,
        updated_at :  maps[i]['updated_at'] != null ? DateTime.parse(maps[i]['updated_at']) : null,
      );
    });
  }

    Future<List<Media>> getMediasSimpleVersion() async {
    final db = await dbProvider;
    List<String> whereConditions = [];
    List<dynamic> whereValues = [];

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM $table WHERE LENGTH(Image) <= 2 * 1024 * 1024 LIMIT 90',
      whereValues,
    );

    return List.generate(maps.length, (i) {
      return Media(
        
        nom: maps[i]['Nom'],
        image: maps[i]['Image'] is Uint8List ? maps[i]['Image'] : maps[i-1]['Image'],
        note: maps[i]['Note'],
        statut: maps[i]['Statut'],
      );
    });
  }

  Future<int?> countPageMedia(String? statut, Set<String>? genres, String search) async {
     List<String> whereConditions = [];
    List<dynamic> whereValues = [];

    final db = await dbProvider;

      if (search != null && search.isNotEmpty) {
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

    String whereClause = whereConditions.isNotEmpty
        ? ' WHERE ${whereConditions.join(' AND ')}'
        : '';

    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table $whereClause', whereValues,);
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




}
