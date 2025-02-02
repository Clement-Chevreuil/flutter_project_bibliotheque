import 'package:flutter/material.dart';
import 'package:flutter_project_n1/database/database_genre.dart';
import 'package:flutter_project_n1/database/database_media.dart';
import 'package:flutter_project_n1/enums/categories_enum.dart';
import 'package:flutter_project_n1/enums/menu_enum.dart';
import 'package:flutter_project_n1/models/media.dart';

class MediaProvider extends ChangeNotifier {
  bool _isLoading = false;
  final String _mediaIndex = CategoriesEnum.series.name;
  int _currentPage = 0;
  String _pageName = CategoriesEnum.series.name;
  bool _isAdvancedSearchVisible = false;
  List<String> _genresList = [];
  String? _selectedOrder = "ID";
  String selectedOrderAscDesc = "Ascendant";
  String? selectedStatut;
  static String _tableName = "Books";
  int? pageMax = 1;
  int currentPageMedia = 1;
  int index = 2;
  Set<String> selectedGenres = {};
  List<Media> medias = [];
  String _search = "";

  final DatabaseMedia bdMedia = DatabaseMedia(CategoriesEnum.series.name);
  final DatabaseGenre bdGenre = DatabaseGenre();

  bool get isLoading => _isLoading;
  String get mediaIndex => _mediaIndex;
  int get currentPage => _currentPage;
  String get pageName => _pageName;
  bool get isAdvancedSearchVisible => _isAdvancedSearchVisible;
  List<String> get genresList => _genresList;
  String get tableName => _tableName;
  String? get selectedOrder => _selectedOrder;
  String get search => _search;

  Future<void> setLoading(bool value) async {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> setCurrentPage(int page) async {
    _currentPage = page;
    _pageName = MenuEnum.values[page].name;
    notifyListeners();
  }

  Future<void> toggleAdvancedSearchVisible() async {
    _isAdvancedSearchVisible = !_isAdvancedSearchVisible;
    notifyListeners();
  }

  Future<void> genresData() async {
    _genresList = await bdGenre.getGenresList(_mediaIndex, "");
  }

  //FONCTIONS
  void loadMedia() async {
    bdMedia.changeTable(_mediaIndex);
    List<Media> updatedMediaList = await bdMedia.getMedias(
      currentPage,
      selectedStatut,
      selectedOrder,
      selectedGenres,
      search,
      selectedOrderAscDesc,
    );

    medias = updatedMediaList;
    loadPageButtons(search);
    notifyListeners();
  }

  void loadPageButtons(String text) async {
    int? pageCount = await bdMedia.countPageMedia(selectedStatut, selectedGenres, text);
    if (pageCount != null) {
      pageMax = pageCount;
    }
  }

  void setTableName(String name) {
    _tableName = name;
    notifyListeners();
  }

  void setCurrentPageMedia(int page) {
    currentPageMedia = page;
    notifyListeners();
  }

  void updateMediaList(String text) async {
    await setLoading(true);
    try {
      List<Media> updatedMediaList = await bdMedia.getMedias(
        currentPage,
        selectedStatut,
        selectedOrder,
        selectedGenres,
        text,
        selectedOrderAscDesc,
      );
      medias = updatedMediaList;
      notifyListeners();
    } finally {
      await setLoading(false);
    }
  }

  void updateSelectedGenres(Set<String> genres) {
    selectedGenres = genres;
    notifyListeners();
  }

  void toggleSelectedGenre(String genre) {
    if (selectedGenres.contains(genre)) {
      selectedGenres.remove(genre);
    } else {
      selectedGenres.add(genre);
    }
    notifyListeners();
  }

  void setSelectedOrder(String? order) {
    _selectedOrder = order;
    notifyListeners();
  }

  void setSelectedStatut(String? statut) {
    selectedStatut = statut;
    notifyListeners();
  }

  void setSelectedOrderAscDesc(String orderAscDesc) {
    selectedOrderAscDesc = orderAscDesc;
    notifyListeners();
  }

  void setSearch(String text) {
    _search = text;
    notifyListeners();
  }
}
