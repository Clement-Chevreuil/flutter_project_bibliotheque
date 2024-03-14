import 'package:flutter_project_n1/domain/repositories/genre_repository.dart';

import '../datasources/database_genre.dart';
import '../models/genre.dart';

class GenreRepositoryImpl implements GenreRepository {
  final DatabaseGenre _databaseGenre;

  GenreRepositoryImpl(this._databaseGenre);

  Future<int?> insertGenre(Genre genre) async {
    return await _databaseGenre.insert(genre);
  }

  Future<int?> updateGenre(Genre genre) async {
    return await _databaseGenre.update(genre);
  }

  Future<void> deleteGenre(Genre genre) async {
    await _databaseGenre.delete(genre);
  }
}
