enum MenuEnum {
  dashboard,
  series,
  animes,
  games,
  webtoons,
  books,
  movies,
}

extension MenuEnumExtension on MenuEnum {
  static const List<String> sidebarItems = ["Dashboard", "Series", "Animes", "Games", "Webtoons", "Books", "Movies"];

  String get name {
    return sidebarItems[index];
  }
}
