import 'package:flutter_project_n1/data/datacontrol/database_init.dart';
import 'package:flutter_project_n1/data/models/episode.dart';
import 'package:sqflite/sqflite.dart';

class EpisodeDataSource {
  EpisodeDataSource();
  final dbProvider = DatabaseInit.database;

  //CRUD

  Future<void> insert(Episode book) async {
    book.created_at =  DateTime.now();
    book.updated_at =  null;
    final db = await dbProvider;
    await db.insert(
      "Episode",
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Episode book) async {
  book.updated_at = DateTime.now();
  final db = await dbProvider;
  
  await db.update(
    "Episode",
    book.toMap(),
    where: "id = ?",
    whereArgs: [book.id],
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  Future<void> delete(Episode book) async {
    final db = await dbProvider;
    await db.delete(
      "Episode",
      where: 'ID = ?',
      whereArgs: [book.id],
    );
  }

    Future<Episode?> get(int id) async {
    final db = await dbProvider;
    final List<Map<String, dynamic>> maps =
        await db.query("Episode", where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      Map<String, dynamic> map = maps.first;
      return Episode(
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

  Future<List<Episode>> getAll(int idSaison) async {
    final db = await dbProvider;
    List<dynamic> whereValues = [];

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT e.ID, e.Nom, e.Image, e.Note, e.statut, e.Avis, e.description, e.created_at, e.updated_at FROM Episode e, Saison s WHERE e.ID_Saison = s.ID AND e.ID_Saison = $idSaison',
      whereValues,
    );

    return List.generate(maps.length, (i) {
            return Episode(
        id: maps[i]['ID'],
        nom: maps[i]['Nom'],
        image: maps[i]['Image'],
        note: maps[i]['Note'],
        statut: maps[i]['Statut'],
        avis: maps[i]['Avis'],
        description: maps[i]['Description'],
        created_at :  maps[i]['created'] != null ?  DateTime.parse(maps[i]['created_at']) : null,
        updated_at :  maps[i]['updated_at'] != null ? DateTime.parse(maps[i]['updated_at']) : null,
      );
    });
  }

  //END


}
