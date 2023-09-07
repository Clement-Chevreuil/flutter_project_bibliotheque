  import '../Model/media.dart';
  import 'package:sqflite/sqflite.dart';
  import 'package:path/path.dart';

  class DatabaseMedia {
    String table;
    String defaultName = "maBDD3.db";
    DatabaseMedia(this.table);

    final List<String> tableNames = ["Series", "Animes", "Games", "Webtoons", "Books", "Movies"];
    static Database? _database;

    Future<Database> initDatabase(String name) async {
      defaultName = name;
      final path = join(await getDatabasesPath(), name);

      final db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          for (String tableName in tableNames) {
            await db.execute(
              "CREATE TABLE $tableName(ID INTEGER PRIMARY KEY, Nom TEXT, Image BLOB, Note INTEGER, Statut TEXT, Genres TEXT)",
            );
          }
        },
      );
      return db;
    }

    void closeDatabase() async {
      if (_database != null) {
      await _database!.close();
      _database = null; // Assurez-vous de réinitialiser la référence à la base de données après sa fermeture.
    }
    }

    Future<void> changeTable(String name) async {
      final db = await initDatabase(defaultName);
      table = name;
    }
    Future<void> insertMedia(Media book) async {
      final db = await initDatabase(defaultName);
      await db.insert(
        table,
        book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    Future<void> updateMedia(Media book) async {
      final db = await initDatabase(defaultName);
      await db.update(
        table,
        book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    Future<List<Media>> getMedias() async {
      print(table);
      final db = await initDatabase(defaultName);
      //final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM $table LIMIT 7');
      final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM $table WHERE LENGTH(Image) <= ? LIMIT ?', [2 * 1024 * 1024, 10]);
      return List.generate(maps.length, (i) {
        return Media(
          id: maps[i]['ID'],
          nom: maps[i]['Nom'],
          image: maps[i]['Image'],
          note: maps[i]['Note'],
          statut: maps[i]['Statut'],
          genres: maps[i]['Genres'] != null ? maps[i]['Genres'].split(', ').toList() : null,
          
          
        );
      });
    }
    
    Future<int?> countPageMedia() async {
      final db = await initDatabase(defaultName);
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
      int? count = Sqflite.firstIntValue(result);

      if (count != null) {
        int totalPage = (count + 10 - 1) ~/ 10;
        return totalPage;
      } else {
        return null;
      }
    }
    
    Future<Media?> getMediaWithId(int id) async {
      final db = await initDatabase(defaultName);
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
          genres: map['Genres'] != null ? map['Genres'].split(',').toList() : null
        );
      } else {
        return null; // Media with the specified ID not found
      }
    }
    Future<void> deleteMedia(Media book) async {
      final db = await initDatabase(defaultName);
      await db.delete(
        table,
        where: 'ID = ?',
        whereArgs: [book.id],
      );
    }
  }
