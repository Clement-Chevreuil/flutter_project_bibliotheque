enum CategoriesEnum {
  series,
  animes,
  games,
  webtoons,
  books,
  movies,
}

extension CategoriesEnumExtension on CategoriesEnum {
  static const List<String> sidebarItems = ["Series", "Animes", "Games", "Webtoons", "Books", "Movies"];

  String get name {
    return sidebarItems[index];
  }
}
