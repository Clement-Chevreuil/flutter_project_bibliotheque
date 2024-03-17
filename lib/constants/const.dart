// lib/constants/colors.dart

import 'package:flutter/material.dart';

class AppConst {
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC5);
  static const Color accentColor = Color(0xFFFFD700);
  static const Color textColor = Color(0xFF333333);
  static const Color backgroundColor = Color(0xFFF5F5F5);

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
