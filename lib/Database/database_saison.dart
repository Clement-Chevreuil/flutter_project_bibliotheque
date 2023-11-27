import 'package:flutter_project_n1/Model/saison.dart';
import 'package:sqflite/sqflite.dart';
import 'database_init.dart';

class DatabaseSaison {
  DatabaseSaison();

  static Database? _database;
  final dbProvider = DatabaseInit.database;

  //CRUD

  Future<int> insert(Saison book) async {
    book.created_at =  DateTime.now();
    book.updated_at =  null;
    final db = await dbProvider;
    int id = await db.insert(
      "Saison",
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> update(Saison book) async {
  book.updated_at = DateTime.now();
  final db = await dbProvider;
  
  await db.update(
    "Saison",
    book.toMap(),
    where: "id = ?",
    whereArgs: [book.id],
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  Future<void> delete(Saison book) async {
    final db = await dbProvider;
    await db.delete(
      "Saison",
      where: 'ID = ?',
      whereArgs: [book.id],
    );
  }

    Future<Saison?> get(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps =
        await db.query("Saison", where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      Map<String, dynamic> map = maps.first;
      return Saison(
          id: map['ID'],
          nom: map['Nom'],
          image: map['Image'],
          note: map['Note'],
          statut: map['Statut'],
          avis: map['Avis'],
          description: map['Description'],
          created_at :   DateTime.parse(map['created_at']),
          updated_at :  map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
          );
    } else {
      return null; // Media with the specified ID not found
    }
  }

  Future<List<Saison>> getAll(int idMedia, String table) async {
    final db = await dbProvider;
    List<String> whereConditions = [];
    List<dynamic> whereValues = [];

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM Saison WHERE ID_Media = $idMedia AND Media = "$table"',
      whereValues,
    );

    return List.generate(maps.length, (i) {
            return Saison(
        id: maps[i]['ID'],
        nom: maps[i]['Nom'],
        image: maps[i]['Image'],
        note: maps[i]['Note'],
        statut: maps[i]['Statut'],
        avis: maps[i]['Avis'],
        description: maps[i]['Description'],
        created_at :  maps[i]['updated_at'] != null ?  DateTime.parse(maps[i]['created_at']) : null,
        updated_at :  maps[i]['updated_at'] != null ? DateTime.parse(maps[i]['updated_at']) : null,
      );
    });
  }

  //END


}
