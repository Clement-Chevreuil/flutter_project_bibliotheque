import 'package:flutter_project_n1/data/models/genre.dart';

abstract class GenreRepository {
  Future<int?> insertGenre(Genre genre);
  Future<int?> updateGenre(Genre genre);
  Future<void> deleteGenre(Genre genre);
}
