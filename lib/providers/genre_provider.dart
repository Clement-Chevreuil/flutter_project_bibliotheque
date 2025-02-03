import 'package:flutter/material.dart';
import 'package:flutter_project_n1/Database/database_genre.dart';
import 'package:flutter_project_n1/enums/categories_enum.dart';
import 'package:flutter_project_n1/models/genre.dart';

class GenreProvider extends ChangeNotifier {
  /// Variables
  final bdGenres = DatabaseGenre();
  CategoriesEnum _mediaIndex = CategoriesEnum.series;
  List<Genre> _genres = [];
  List<int> _genreIdsSelected = [];

  /// Getter
  List<Genre> get genres => _genres;
  CategoriesEnum get mediaIndex => _mediaIndex;
  List<int> get genreIdsSelected => _genreIdsSelected;

  /// Functions
  void loadGenres() async {
    // TODO : remettre le search
    List<Genre> updatedMediaList = await bdGenres.getGenres(_mediaIndex.name, "");
    _genres = updatedMediaList;
  }

  void deleteGenre(Genre genre) async {
    await bdGenres.delete(genre);
    loadGenres();
  }

  void saveGenre(Genre genre) async {
    if (genre.id != null) {
      await bdGenres.update(genre);
    } else {
      await bdGenres.insert(genre);
    }
    loadGenres();
  }

  void updateMediaIndex(CategoriesEnum newIndex) {
    _mediaIndex = newIndex;
    loadGenres();
    notifyListeners();
  }

  void toggleGenresSelected(int id) {
    if (_genreIdsSelected.contains(id)) {
      _genreIdsSelected.remove(id);
    } else {
      _genreIdsSelected.add(id);
    }
    notifyListeners();
  }
}
