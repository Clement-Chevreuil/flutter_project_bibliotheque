enum OrderEnum {
  ascendant,
  descendant,
}

extension OrderEnumExtension on OrderEnum {
  static const List<String> orderListAscDesc = [
    "Ascendant",
    "Descendant",
  ];

  String get name {
    return orderListAscDesc[index];
  }
}
