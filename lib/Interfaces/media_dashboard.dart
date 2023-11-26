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
import 'package:intl/intl.dart';

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

  List<Media>? mostRecentRecords;

  final List<String> sidebarItems = [
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies"
  ];

  List<String> _selectionsGenres = [
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies"
  ];
  bool isInitComplete = false;
  int selectedGenreIndex = 0;
 final GlobalKey<AnimatedListState> _listKey =
      GlobalKey();
  String tableName = "Series";

  final bdMedia = DatabaseMedia("Series");
  final bdGenre = DatabaseGenre();
  Map<String, int>? count;
  _MediaDashboardState();

  Map<String, int>? countsByStatut = null;

  void initState() {
    super.initState();
    _databaseInit = DatabaseInit();
    getLoadPage().then((value) =>  isInitComplete = true);
   
  }

  @override
  Widget build(BuildContext context) {

    if (!isInitComplete) {
      // Attendre que l'initialisation soit terminée
      return CircularProgressIndicator(); // Ou tout autre indicateur de chargement
    }

    return Scaffold(
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text("All Category"),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sidebarItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return InkWell(
                onTap: () {
                  // Méthode pour naviguer vers la page "MediaCompare"
                  widget.onPageChanged(index +
                      1); // Vous pouvez passer l'index de la page que vous souhaitez afficher
                },
                child: Container(
                  //height: MediaQuery.of(context).size.height * 0.2,
                  constraints: BoxConstraints(
                      maxHeight: 80.0, maxWidth: 120.0, minWidth: 120.0),
                  margin: EdgeInsets.symmetric(horizontal: 7.0, vertical: 5.0),
                  child: Card(
                    elevation: 8.0,
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(item),
                            Text(count != null ? count![item].toString() : " 0")
                          ],
                        )),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text("Category"),
          ),
        ),
        Wrap(
          spacing: 0.0,
          runSpacing: 0.0,
          children: _selectionsGenres.asMap().entries.map((entry) {
            int index = entry.key;
            String item = entry.value;
            return Container(
              width: 120.0,
              height: 60.0,
              margin: EdgeInsets.all(2.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (selectedGenreIndex == index) {
                      // Désélectionnez l'élément s'il est déjà sélectionné
                      selectedGenreIndex = -1;
                    } else {
                      selectedGenreIndex = index;
                    }
                    tableName = _selectionsGenres[index];
                    bdMedia.changeTable(tableName);
                    getLoadPage();
                  });
                  print("Genre sélectionné : ${_selectionsGenres[index]}");
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  primary: selectedGenreIndex == index
                      ? Color.fromARGB(255, 222, 233, 243)
                      : Color.fromARGB(59, 222, 233, 243) // Changez la couleur du bouton ici
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    color: selectedGenreIndex == index
                        ? Colors.black
                        : Colors.black,
                    fontSize: 11.0,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(_selectionsGenres[0]),
              ),
              Row(
                children: [
                  Container(
                    height: 165.0,
                    width: 200.0,
                    child: Wrap(
                      spacing: 5.0, // gap between adjacent chips
                      runSpacing: 5.0, // gap between lines
                      children: <Widget>[
                        Container(
                          width: 90.0,
                          height: 80.0,
                          child: Card(
                            child: Column(children : [Text('Fini'), Text(countsByStatut!['countFini'].toString())]),
                            elevation: 9.0,
                          ),
                        ),
                        Container(
                          width: 90.0,
                          height: 80,
                          child: Card(
                            child: Column(children : [Text('En Cours'), Text(countsByStatut!['countEnCours'].toString())]),
                            elevation: 9.0,
                          ),
                        ),
                        Container(
                          width: 90.0,
                          height: 80,
                          child: Card(
                            child: Column(children : [Text('Abandon'), Text(countsByStatut!['countAbandonner'].toString())]),
                            elevation: 9.0,
                          ),
                        ),
                        Container(
                          width: 90.0,
                          height: 80,
                          child: Card(
                            child: Column(children : [Text('Envie'), Text(countsByStatut!['countEnvieDeRegarder'].toString())]),
                            elevation: 9.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 165.0,
                      child: Card(
                        elevation: 8.0,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text("Courbe"),
                              ],
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text("Last Created/Updated"),
              ),
               
            ],
          ),

        ),
         Expanded(
            child: FutureBuilder<List<Media>>(
              future: bdMedia.getMostRecentRecords(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null ||snapshot.data?.length == 0) {
                  return Center(
                    child: Text('Aucun Media.'),
                  );
                } else {
                  mostRecentRecords = snapshot.data!;
                  return ListView.builder(
                    key: _listKey,
                    itemCount: mostRecentRecords!.length + 1,
                    itemBuilder: (context, index) {
                      if (index < mostRecentRecords!.length) {
                        Media media = mostRecentRecords![index];
                        return Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 5.0), // Espace autour de la Card
                          child: Card(
                            elevation: 8.0,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  16.0), // Espace à l'intérieur de la Card
                              child: Row(
                                children: [
                                  // Informations sur le livre à droite
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                           Expanded(
                                            child: Text(media.nom ?? '',),
                                           ),
                                          if(media.updated_at != null )
                                            Expanded(
                                              child: Text("Update"),
                                            )
                                          else
                                            Expanded(
                                              child:Text("Create"),
                                            ),

                                          if(media.updated_at != null )
                                            Text(DateFormat("MMM d, ''yy").format(media.updated_at!))
                                          else
                                            Text(DateFormat("MMM d, ''yy").format(media.created_at!)),

                                          
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox(height: 50);
                      }
                    },
                  );
                }
              },
            ),
          ),
      ]),
    );
  }

  Future getLoadPage() async {
    count = await bdMedia.getCountsForTables();
    countsByStatut = await bdMedia.getCountsByStatut();
    mostRecentRecords = await bdMedia.getMostRecentRecords();
    setState(() {});
  }

}
