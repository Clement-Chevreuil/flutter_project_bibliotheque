import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:flutter_project_n1/Database/database_saison.dart';
import 'package:flutter_project_n1/Interfaces/Episode/episode_index.dart';
import 'package:flutter_project_n1/Interfaces/Saison/saison_manager.dart';
import 'package:flutter_project_n1/Model/saison.dart';
import 'package:getwidget/getwidget.dart';
import 'dart:typed_data';


class SaisonIndex extends StatefulWidget {
  final String? mediaParam1;
  final int? idSaison;

  SaisonIndex({this.mediaParam1, this.idSaison});

  @override
  _SaisonIndexState createState() => _SaisonIndexState(mediaParam1: mediaParam1, idSaison: idSaison);
}

class _SaisonIndexState extends State<SaisonIndex> {
  
  final String? mediaParam1;
  final int? idSaison;

  late DatabaseInit _databaseInit;

  bool isAdvancedSearchVisible = false;
  TextEditingController _controllerNom = TextEditingController(text: '');
  TextEditingController _controller = TextEditingController();

  
  final bdSaison = DatabaseSaison();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  
  static String tableName = "Books";
  List<Saison> books = [];

  _SaisonIndexState({this.mediaParam1, this.idSaison});

  void initState() {
    super.initState();
    tableName = mediaParam1!;
    loadSaison();
    _databaseInit = DatabaseInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saison Manager'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SaisonManager(
                mediaParam: null,
                tableName: tableName,
              ),
            ),
          );
        },
        mini: true,
        child: const Icon(Icons
            .add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat,
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<Saison>>(
              future: bdSaison.getAll(idSaison!, mediaParam1!),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Text('Aucun livre enregistré.'),
                  );
                } else {
                  books = snapshot.data!;
                  return ListView.builder(
                    key: _listKey,
                    itemCount: books.length + 1,
                    itemBuilder: (context, index) {
                      if (index < books.length) {
                        Saison book = books[index];
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EpisodeIndex(
                                    idSaison: book.id,
                                  ),
                                ),
                              );
                              // Handle the click on the Card here
                              print('Card Clicked');
                            },
                            child:Container(
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
                                  // Image du livre à gauche avec une taille ajustée
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Image.memory(
                                      book.image ?? Uint8List(0),
                                      height:
                                          120, // Ajustez la hauteur de l'image
                                      width:
                                          90, // Ajustez la largeur de l'image
                                    ),
                                  ),
                                  // Informations sur le livre à droite
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Titre du livre aligné verticalement avec les autres informations
                                          GFTypography(
                                            text: book.nom ?? '',
                                            type: GFTypographyType.typo5,
                                          ),
                                          Text('Note: ${book.note ?? ''}'),
                                          Text('Statut: ${book.statut ?? ''}'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Boutons légèrement décalés vers la gauche
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SaisonManager(
                                                mediaParam: book,
                                                tableName: tableName,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          await DatabaseSaison().delete(book);
                                          loadSaison();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('Livre supprimé')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
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
        ],
      ),
    );
  }

  //FONCTIONS
  void loadSaison() async {
    // bdSaison.changeTable(tableName);
    // List<Saison> updatedSaisonList = await bdSaison.getSaisons(page, selectedStatut,
    //     selectedOrder, selectedGenres, _controllerNom.text, selectedOrderAscDesc);
    // setState(() {
    //   books.clear();
    //   books.addAll(
    //       updatedSaisonList); // Ajoutez les médias chargés depuis la base de données
    //   _listKey.currentState
    //       ?.setState(() {}); // Mettre à jour la ListView.builder
    // });
  }
}


