import '../entities/genre.dart';

abstract class GenreRepository {
  Future<int?> insertGenre(Genre genre);
  Future<int?> updateGenre(Genre genre);
  Future<void> deleteGenre(Genre genre);
}
