import 'package:flutter_project_n1/data/datasources/local/genre_data_source.dart';
import 'package:flutter_project_n1/data/models/genre.dart';
import 'package:flutter_project_n1/domain/repositories/genre_repository.dart';

class GenreRepositoryImpl implements GenreRepository {
  final GenreDataSource _genreDataSource;

  GenreRepositoryImpl(this._genreDataSource);

  Future<int?> insertGenre(Genre genre) async {
    return await _genreDataSource.insert(genre);
  }

  Future<int?> updateGenre(Genre genre) async {
    return await _genreDataSource.update(genre);
  }

  Future<void> deleteGenre(Genre genre) async {
    await _genreDataSource.delete(genre);
  }
}
