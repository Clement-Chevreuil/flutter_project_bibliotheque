import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Interfaces/media_compare.dart';
import 'package:flutter_project_n1/Interfaces/media_dashboard.dart';
import 'package:flutter_project_n1/Interfaces/saison_index.dart';
import 'package:flutter_project_n1/Interfaces/saison_manager.dart';
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
import '../Logic/helper.dart';

import 'genres_index.dart';

class MediaIndex extends StatefulWidget {
  String mediaParam1;

  MediaIndex(this.mediaParam1);

  @override
  _MediaIndexState createState() => _MediaIndexState(mediaParam1: mediaParam1);
}

class _MediaIndexState extends State<MediaIndex> {
  final String? mediaParam1;
  final TextEditingController _controller = TextEditingController();
  late DatabaseInit _databaseInit;

  bool isAdvancedSearchVisible = false;
  TextEditingController _controllerNom = TextEditingController(text: '');

  List<IconData> itemIcons = [
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie
  ]; // Ajoutez ici les icônes correspondantes

  List<String> GenresList = [];

  final List<String> sidebarItems = [
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies"
  ];
  final List<String> OrderList = [
    "ID",
    "Note",
    "Nom",
    "AJOUT",
  ];
  final List<String> OrderListAscDesc = [
    "Ascendant",
    "Descendant",
  ];
  final List<String> StatutList = [
    "Fini",
    "En cours",
    "Abandonnee",
    "Envie",
  ];

  final bdMedia = DatabaseMedia("Books");
  final bdGenre = DatabaseGenre();

  final GlobalKey<AnimatedListState> _listKey =
      GlobalKey(); // Clé pour la ListView.builder

  String? selectedOrder = "ID";
  String selectedOrderAscDesc = "Ascendant";
  String? selectedStatut = null;

  static String tableName = "Books";

  List<Media> books = [];

  int? pageMax = 1;
  int page = 1;
  int index = 2;
  Set<String> selectedGenres = Set();
  // instantiate the controller in your state

  _MediaIndexState({this.mediaParam1});

  void initState() {
    super.initState();
    tableName = mediaParam1!;
    loadMedia();
    loadPageButtons();
    _databaseInit = DatabaseInit();
    fetchData();
  }

  void changeTableName(String newTableName) {
    setState(() {
      tableName = newTableName;
      loadMedia(); // Chargez les médias avec le nouveau tableName
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaManager(
                mediaParam: null,
                tableName: tableName,
              ),
            ),
          );
        },
        mini: true,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: Colors.black, // Couleur du bord en noir
                width: 1.0, // Bordure plus fine
              ),
              color: Colors.transparent, // Fond transparent
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.black, // Texte en noir
                      fontSize: 16.0, // Taille du texte
                    ),
                    decoration: InputDecoration(
                      hintText: "Recherche...",
                      hintStyle: TextStyle(
                        color: Colors.black
                            .withOpacity(0.5), // Texte d'indication en noir
                      ),
                      border: InputBorder.none,
                    ),
                    controller: _controllerNom,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.black, // Icône en noir
                  ),
                  onPressed: () {
                    loadMedia();
                  },
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isAdvancedSearchVisible =
                          !isAdvancedSearchVisible; // Inversez la visibilité du bloc
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.sort,
                      color: Colors.black, // Icône en noir
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
              height: isAdvancedSearchVisible
                  ? null
                  : 0, // Utilisez null pour la hauteur pour permettre l'animation
              duration: Duration(milliseconds: 300), // Durée de l'animation
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical:
                        8.0), // Ajustez la quantité de padding selon vos préférences
                child: Card(
                  elevation:
                      4.0, // Ajoutez une élévation à la Card si vous le souhaitez
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(
                            16.0), // Ajoutez du padding à l'intérieur de la Card
                        child: Column(
                          children: [
                            buildPageButtonsGenres(),
                            buildPageButtonsOrders(),
                            buildPageButtonsStatut(),
                            buildPageButtonsOrdersAscDesc(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          Expanded(
            child: FutureBuilder<List<Media>>(
              future: bdMedia.getMedias(page, selectedStatut, selectedOrder,
                  selectedGenres, _controllerNom.text, selectedOrderAscDesc),
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
                        Media book = books[index];

                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SaisonIndex(
                                    mediaParam1: tableName,
                                    idSaison: book.id,
                                  ),
                                ),
                              );
                              // Handle the click on the Card here
                              print('Card Clicked');
                            },
                            child: Container(
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
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
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
                                              Text(
                                                  'Statut: ${book.statut ?? ''}'),
                                              Text(
                                                  'Genres: ${book.genres?.join(', ') ?? ''}'),
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
                                                      MediaManager(
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
                                              await DatabaseMedia(tableName)
                                                  .deleteMedia(book);
                                              loadMedia();
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
                            ));
                      } else {
                        return SizedBox(height: 50);
                      }
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0), // Ajoutez le padding souhaité
            child: pageMax != null
                ? buildPageButtons(pageMax!)
                : SizedBox(), // Affiche les boutons si pageMax n'est pas nulle
          ),
        ],
      ),
    );
  }

  //FONCTIONS
  void loadMedia() async {
    bdMedia.changeTable(tableName);
    List<Media> updatedMediaList = await bdMedia.getMedias(
        page,
        selectedStatut,
        selectedOrder,
        selectedGenres,
        _controllerNom.text,
        selectedOrderAscDesc);
    setState(() {
      books.clear();
      books.addAll(
          updatedMediaList); // Ajoutez les médias chargés depuis la base de données
      _listKey.currentState
          ?.setState(() {}); // Mettre à jour la ListView.builder
    });
    loadPageButtons();
  }

  void loadPageButtons() async {
    int? pageCount = await bdMedia.countPageMedia(
        selectedStatut, selectedGenres, _controllerNom.text);
    if (pageCount != null) {
      setState(() {
        pageMax = pageCount;
      });
    }
  }

  // Fonction pour créer les boutons en fonction du nombre de pages
  Widget buildPageButtons(int pageCount) {
    // Assurez-vous qu'il y a au moins deux boutons à afficher
    if (pageCount < 2) {
      return SizedBox();
    }

    // Définissez le nombre total de boutons à afficher autour de la page actuelle (toujours 7)
    int totalButtons = 7;
    int pageMin = 2;
    int pageMax = 2;
    // Calculez les bornes inférieures et supérieures pour afficher les boutons
    int lowerBound = page - pageMin;
    int upperBound = page + pageMax;

    // Ajustez les bornes pour s'assurer qu'il y a toujours 7 boutons
    if (lowerBound < 1) {
      lowerBound = 1;
      upperBound = lowerBound + totalButtons - 2;
    }
    if (upperBound > pageCount) {
      upperBound = pageCount;
      lowerBound = upperBound - totalButtons + 2;
    }
    if (page == 3) {
      upperBound += 1;
    }

    if (page == pageCount - 2) {
      lowerBound -= 1;
    }

    // Générez les boutons en fonction des bornes inférieures et supérieures
    List<Widget> buttons = [];

    for (int i = lowerBound; i <= upperBound; i++) {
      buttons.add(buildButton(i));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (lowerBound > 1) buildButton(1), // Bouton de la page minimum
          ...buttons, // Boutons centraux
          if (upperBound < pageCount)
            buildButton(pageCount), // Bouton de la page maximum
        ],
      ),
    );
  }

  Widget buildButton(int pageNumber) {
    final isSelected =
        pageNumber == page; // Vérifiez si le bouton est sélectionné

    return SizedBox(
      width: 36.0, // Largeur fixe
      height: 36.0, // Hauteur fixe
      child: TextButton(
        onPressed: () {
          // Mettez à jour la page sélectionnée
          setState(() {
            page = pageNumber;
          });
          loadMedia();
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero, // Aucun remplissage autour du texte
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0), // Bordures carrées
          ),
          backgroundColor:
              isSelected ? Colors.blue : Colors.transparent, // Couleur de fond
        ),
        child: Text(
          '$pageNumber',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black, // Couleur du texte
          ),
        ),
      ),
    );
  }

  // Fonction pour créer les boutons en fonction du nombre de pages
  Widget buildPageButtonsGenres() {
    return Container(
      margin: EdgeInsets.all(4.0), // Marge autour du widget complet
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centre les éléments horizontalement
            children: [
              Text(
                'Genre :',
                style: TextStyle(
                  fontSize: 16, // Taille du texte
                  fontWeight: FontWeight.bold, // Texte en gras
                ),
              ),
              Container(
                transform: Matrix4.translationValues(
                    0, -6.0, 0), // Translation vers le haut
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenresIndex(
                          mediaParam1: tableName,
                        ),
                      ),
                    );
                  }, // Remplacez null par votre fonction onPressed
                  icon: Icon(Icons.settings),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0), // Espacement entre le texte et les boutons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(GenresList.length, (i) {
                final genre = GenresList[i];
                final isSelected = selectedGenres.contains(genre);

                return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        page = 1;
                        setState(() {
                          if (isSelected) {
                            selectedGenres.remove(genre);
                          } else {
                            selectedGenres.add(genre);
                          }
                        });
                        loadMedia();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: isSelected ? Colors.blue : null,
                      ),
                      child: Text(genre),
                    ));
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPageButtonsStatut() {
    return Container(
      margin: EdgeInsets.all(4.0), // Marge autour du widget complet
      child: Column(
        children: [
          Text(
            "Statut :",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0), // Espacement entre le texte et les boutons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(StatutList.length, (i) {
                final statut = StatutList[i];
                final isSelected = statut ==
                    selectedStatut; // Vérifiez si le bouton est sélectionné

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      page = 1;
                      // Mettez à jour la valeur sélectionnée et rechargez les médias
                      setState(() {
                        if (isSelected) {
                          // Si le bouton est déjà sélectionné, annulez la sélection
                          selectedStatut = null;
                        } else {
                          selectedStatut = statut;
                        }
                      });
                      loadMedia();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: isSelected
                          ? Colors.blue
                          : null, // Fond bleu si sélectionné
                    ),
                    child: Text(statut),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchData() async {
    GenresList = await bdGenre.getGenresList(tableName, "");
  }

  Widget buildPageButtonsOrders() {
    return Container(
      margin: EdgeInsets.all(4.0), // Marge autour du widget complet
      child: Column(
        children: [
          Text(
            "Ordre :",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0), // Espacement entre le texte et les boutons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(OrderList.length, (i) {
                final order = OrderList[i];
                final isSelected = order == selectedOrder;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      page = 1;
                      // Mettez à jour la valeur sélectionnée et rechargez les médias
                      setState(() {
                        if (!isSelected) {
                          selectedOrder = order;
                        }
                      });
                      loadMedia();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: isSelected
                          ? Colors.blue
                          : null, // Fond bleu si sélectionné
                    ),
                    child: Text(order),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPageButtonsOrdersAscDesc() {
    return Container(
      margin: EdgeInsets.all(4.0), // Marge autour du widget complet
      child: Column(
        children: [
          Text(
            "Sens :",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0), // Espacement entre le texte et les boutons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(OrderListAscDesc.length, (i) {
                final order = OrderListAscDesc[i];
                final isSelected = order == selectedOrderAscDesc;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      page = 1;
                      // Mettez à jour la valeur sélectionnée et rechargez les médias
                      setState(() {
                        if (!isSelected) {
                          selectedOrderAscDesc = order;
                        }
                      });
                      loadMedia();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: isSelected
                          ? Colors.blue
                          : null, // Fond bleu si sélectionné
                    ),
                    child: Text(order),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
