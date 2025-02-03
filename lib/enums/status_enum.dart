enum StatusEnum {
  fini,
  enCours,
  abandonnee,
  envie,
}

extension StatusEnumExtension on StatusEnum {
  static const List<String> statutList = ["Fini", "En cours", "Abandonnee", "Envie"];

  String get name {
    return statutList[index];
  }
}
