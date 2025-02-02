class AppConsts {
  static const List<String> sidebarItems = ["Series", "Animes", "Games", "Webtoons", "Books", "Movies"];

  static const List<String> itemsTitle = [
    "Dashboard",
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies",
    "Compare",
    "Parametres",
  ];

  static const List<String> orderList = [
    "ID",
    "Note",
    "Nom",
    "AJOUT",
  ];
  static const List<String> orderListAscDesc = [
    "Ascendant",
    "Descendant",
  ];
  static List<String> statutList = [
    "Fini",
    "En cours",
    "Abandonnee",
    "Envie",
  ];

  static const List<Map<String, dynamic>> mediaData = [
    {"label": "Fini", "countKey": "countFini"},
    {"label": "En Cours", "countKey": "countEnCours"},
    {"label": "Abandonnee", "countKey": "countAbandonner"},
    {"label": "Envie", "countKey": "countEnvieDeRegarder"},
  ];

  static const double standardRadius = 8.0;
}
