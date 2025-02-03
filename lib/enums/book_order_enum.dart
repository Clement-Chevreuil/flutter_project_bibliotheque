enum BookOrderEnum {
  id,
  note,
  name,
  ajout,
}

extension BookOrderEnumExtension on BookOrderEnum {
  static const List<String> orderList = ["ID", "Note", "Nom", "AJOUT"];

  String get name {
    return orderList[index];
  }
}
