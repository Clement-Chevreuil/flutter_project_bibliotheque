// lib/constants/colors.dart

import 'package:flutter/material.dart';

class AppConst {

  static const List<String> sidebarItems = [
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies"
  ];

  static const List<String> ItemsTitle = [
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


  static const List<String> OrderList = [
    "ID",
    "Note",
    "Nom",
    "AJOUT",
  ];
  static const List<String> OrderListAscDesc = [
    "Ascendant",
    "Descendant",
  ];
  static List<String> StatutList = [
    "Fini",
    "En cours",
    "Abandonnee",
    "Envie",
  ];

  static const List<IconData> itemIcons = [
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie
  ];


  static const List<Map<String, dynamic>> mediaData = [
    {"label": "Fini", "countKey": "countFini"},
    {"label": "En Cours", "countKey": "countEnCours"},
    {"label": "Abandonnee", "countKey": "countAbandonner"},
    {"label": "Envie", "countKey": "countEnvieDeRegarder"},
  ];

}
