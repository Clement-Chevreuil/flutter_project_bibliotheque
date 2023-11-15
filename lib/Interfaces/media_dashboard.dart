import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Interfaces/media_index.dart';
import 'package:flutter_project_n1/Interfaces/media_compare.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:getwidget/getwidget.dart';
import 'media_manager.dart';
import 'dart:typed_data';
import 'dart:io';

import '../Database/database_media.dart';
import '../Database/database_genre.dart';
import '../Database/database_reader.dart';
import '../Database/database_init.dart';
import '../Model/media.dart';
import '../Logic/function_helper.dart';

import 'genres_index.dart';

class MediaDashboard extends StatefulWidget {

  final Function(int) onPageChanged;
  MediaDashboard({required this.onPageChanged});

  @override
  _MediaDashboardState createState() => _MediaDashboardState();
}

class _MediaDashboardState extends State<MediaDashboard> {
  late DatabaseInit _databaseInit;

  List<String> GenresList = [];

  final List<String> sidebarItems = [
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies"
  ];

  final bdMedia = DatabaseMedia("Series");
  final bdGenre = DatabaseGenre();
  Map<String, int>? count;
  _MediaDashboardState();

  void initState() {
    super.initState();
    _databaseInit = DatabaseInit();
    getCountMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: sidebarItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
    return InkWell(
      onTap: () {
        
       // Méthode pour naviguer vers la page "MediaCompare"
        widget.onPageChanged(index+1); // Vous pouvez passer l'index de la page que vous souhaitez afficher
        
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
        child: Card(
          elevation: 8.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GFTypography(
                        text: item,
                        type: GFTypographyType.typo5,
                      ),
                      Text(count != null ? count![item].toString() : "0" )
                      ],
                    ),
                  ),
                ),
                // Boutons légèrement décalés vers la gauche
              ],
            ),
          ),
        ),
      ),
    );
  }).toList(),
      ),
    );
  }

  Future getCountMedia() async {
    count = await bdMedia.getCountsForTables();
    setState(() {});
  }
}


