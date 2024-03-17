import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_n1/data/datacontrol/database_init.dart';
import 'package:getwidget/getwidget.dart';
import 'dart:typed_data';
import 'episode_manager.dart';

class EpisodeIndex extends StatefulWidget {
  final int? idSaison;

  EpisodeIndex({this.idSaison});

  @override
  _EpisodeIndexState createState() => _EpisodeIndexState(idSaison: idSaison);
}

class _EpisodeIndexState extends State<EpisodeIndex> {
  
  final int? idSaison;

  late DatabaseInit _databaseInit;

  bool isAdvancedSearchVisible = false;
  TextEditingController _controllerNom = TextEditingController(text: '');
  TextEditingController _controller = TextEditingController();

  
  final bdEpisode = DatabaseEpisode();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  List<Episode> books = [];

  _EpisodeIndexState({this.idSaison});

  void initState() {
    super.initState();
    loadSaison();
    _databaseInit = DatabaseInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Episode Index'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EpisodeManager(
                idSaison: idSaison,
              ),
            ),
          );
        },
        mini: true,
        child: Icon(Icons
            .add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat,
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<Episode>>(
              future: bdEpisode.getAll(idSaison!),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Text('Aucun livre enregistré.'),
                  );
                } else {
                  books = snapshot.data!;
                  return ListView.builder(
                    key: _listKey,
                    itemCount: books.length + 1,
                    itemBuilder: (context, index) {
                      if (index < books.length) {
                        Episode book = books[index];
                        return GestureDetector(
                            onTap: () {
                              
                            
                              // Handle the click on the Card here
                              print('Card Clicked');
                            },
                            child:Container(
                          margin: const EdgeInsets.symmetric(
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
                                                  EpisodeManager(
                                                episode: book,
                                                idSaison: idSaison,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          await DatabaseEpisode().delete(book);
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


