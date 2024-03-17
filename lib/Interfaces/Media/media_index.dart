import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Database/database_genre.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:flutter_project_n1/Database/database_media.dart';
import 'package:flutter_project_n1/Interfaces/genres_index.dart';
import 'package:flutter_project_n1/Logic/pagination_builder.dart';
import 'package:flutter_project_n1/Model/media.dart';
import 'package:flutter_project_n1/constants/const.dart';
import 'package:getwidget/getwidget.dart';
import 'media_manager.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

class MediaIndex extends StatefulWidget {
  String mediaParam1;
  String? statut;

  MediaIndex(this.mediaParam1, this.statut);

  @override
  _MediaIndexState createState() =>
      _MediaIndexState(mediaParam1: mediaParam1, statut: statut);
}

class _MediaIndexState extends State<MediaIndex> {
  final String? mediaParam1;
  final TextEditingController _controller = TextEditingController();
  late DatabaseInit _databaseInit;
  final DateFormat formatter = DateFormat('yyyy MM dd');
  bool isAdvancedSearchVisible = false;
  TextEditingController _controllerNom = TextEditingController(text: '');

  List<String> GenresList = [];

  String? statut;

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
  int currentPage = 1;
  int index = 2;
  Set<String> selectedGenres = Set();

  // instantiate the controller in your state

  _MediaIndexState({
    this.mediaParam1,
    this.statut,
  });

  void initState() {
    super.initState();
    tableName = mediaParam1!;
    selectedStatut = statut;
    loadMedia(currentPage, selectedStatut, selectedOrder, selectedGenres,
        _controllerNom.text, selectedOrderAscDesc);
    loadPageButtons();

    _databaseInit = DatabaseInit();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaManager(
                mediaParam: null,
                tableName: tableName,
              ),
            ),
          );
          if (result != null) {
            loadMedia(currentPage, selectedStatut, selectedOrder,
                selectedGenres, _controllerNom.text, selectedOrderAscDesc);
          }
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
                    style: const TextStyle(
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
                  icon: const Icon(
                    Icons.search,
                    color: Colors.black, // Icône en noir
                  ),
                  onPressed: () {
                    loadMedia(
                        currentPage,
                        selectedStatut,
                        selectedOrder,
                        selectedGenres,
                        _controllerNom.text,
                        selectedOrderAscDesc);
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
                    child: const Icon(
                      Icons.sort,
                      color: Colors.black, // Icône en noir
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
              height: isAdvancedSearchVisible ? null : 0,
              // Utilisez null pour la hauteur pour permettre l'animation
              duration: Duration(milliseconds: 300),
              // Durée de l'animation
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                // Ajustez la quantité de padding selon vos préférences
                child: Card(
                  elevation:
                      4.0, // Ajoutez une élévation à la Card si vous le souhaitez
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        // Ajoutez du padding à l'intérieur de la Card
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.all(4.0),
                              // Marge autour du widget complet
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // Centre les éléments horizontalement
                                  children: [
                                    const Text(
                                      'Genre :',
                                      style: TextStyle(
                                        fontSize: 16, // Taille du texte
                                        fontWeight:
                                            FontWeight.bold, // Texte en gras
                                      ),
                                    ),
                                    Container(
                                      transform:
                                          Matrix4.translationValues(0, -6.0, 0),
                                      // Translation vers le haut
                                      child: IconButton(
                                        onPressed: () async {
                                          var result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => GenresIndex(
                                                mediaParam1: tableName,
                                              ),
                                            ),
                                          );
                                          if (result != null) {
                                            fetchData();
                                          }
                                        },
                                        // Remplacez null par votre fonction onPressed
                                        icon: const Icon(Icons.settings),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                              ]),
                            ),
                            // Espacement entre le texte et les boutons
                            Container(
                              margin: EdgeInsets.all(4.0),
                              // Marge autour du widget complet
                              child: const Column(children: [
                                Text(
                                  "Ordre :",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 8.0),
                            Container(
                              margin: const EdgeInsets.all(4.0),
                              // Marge autour du widget complet
                              child: const Column(children: [
                                Text(
                                  "Statut :",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8.0),
                              ]),
                            ),
                            Container(
                              margin: EdgeInsets.all(4.0),
                              // Marge autour du widget complet
                              child: const Column(children: [
                                Text(
                                  "Sens :",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8.0),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          Expanded(
            child: FutureBuilder<List<Media>>(
              future: bdMedia.getMedias(
                  currentPage,
                  selectedStatut,
                  selectedOrder,
                  selectedGenres,
                  _controllerNom.text,
                  selectedOrderAscDesc),
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
                        Media book = books[index];

                        return GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => SaisonIndex(
                              //       mediaParam1: tableName,
                              //       idSaison: book.id,
                              //     ),
                              //   ),
                              // );
                              // Handle the click on the Card here
                              print('Card Clicked');
                            },
                            child: Container(
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
                                              Text(
                                                  'Created_at: ${book.created_at != null ? formatter.format(book.created_at!) : ''}'),
                                              Text(
                                                  'Updated_at: ${book.updated_at != null ? formatter.format(book.updated_at!) : ''}'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Boutons légèrement décalés vers la gauche
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () async {
                                              var result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MediaManager(
                                                    mediaParam: book,
                                                    tableName: tableName,
                                                  ),
                                                ),
                                              );
                                              if (result != null) {
                                                setState(() {
                                                  book = result;
                                                });
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () async {
                                              await DatabaseMedia(tableName)
                                                  .deleteMedia(book);
                                              loadMedia(
                                                  currentPage,
                                                  selectedStatut,
                                                  selectedOrder,
                                                  selectedGenres,
                                                  _controllerNom.text,
                                                  selectedOrderAscDesc);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
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
            padding: const EdgeInsets.all(20.0), // Ajoutez le padding souhaité
            child: pageMax != null
                ? new PaginationBuilder().paginationBuilder(
                    pageMax!,
                    currentPage,
                    (pageSelectedReturned) {
                      setState(() {
                        currentPage = pageSelectedReturned;
                      });
                      loadMedia(
                          currentPage,
                          selectedStatut,
                          selectedOrder,
                          selectedGenres,
                          _controllerNom.text,
                          selectedOrderAscDesc);
                    },
                  )
                : SizedBox(), // Affiche les boutons si pageMax n'est pas nulle
          )
        ],
      ),
    );
  }

  //FONCTIONS
  void loadMedia(
      int pageParam,
      String? selectedStatutParam,
      String? selectedOrderParam,
      Set<String> selectedGenresParam,
      String nomParam,
      String selectedOrderAscDescParam) async {
    bdMedia.changeTable(tableName);
    List<Media> updatedMediaList = await bdMedia.getMedias(
        pageParam,
        selectedStatutParam,
        selectedOrderParam,
        selectedGenresParam,
        nomParam,
        selectedOrderAscDescParam);
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
  Widget buildPageButtonsGenres() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(GenresList.length, (i) {
          final genre = GenresList[i];
          final isSelected = selectedGenres.contains(genre);

          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  currentPage = 1;
                  setState(() {
                    if (isSelected) {
                      selectedGenres.remove(genre);
                    } else {
                      selectedGenres.add(genre);
                    }
                  });
                  loadMedia(
                      currentPage,
                      selectedStatut,
                      selectedOrder,
                      selectedGenres,
                      _controllerNom.text,
                      selectedOrderAscDesc);
                },
                // style: ElevatedButton.styleFrom(
                //   primary: isSelected ? Colors.blue : null,
                // ),
                child: Text(genre),
              ));
        }),
      ),
    );
  }

  Widget buildPageButtonsStatut() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(AppConst.StatutList.length, (i) {
          statut = AppConst.StatutList[i];
          final isSelected =
              statut == selectedStatut; // Vérifiez si le bouton est sélectionné
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {
                currentPage = 1;
                // Mettez à jour la valeur sélectionnée et rechargez les médias
                setState(() {
                  if (isSelected) {
                    // Si le bouton est déjà sélectionné, annulez la sélection
                    selectedStatut = null;
                  } else {
                    selectedStatut = statut;
                  }
                });
                loadMedia(currentPage, selectedStatut, selectedOrder,
                    selectedGenres, _controllerNom.text, selectedOrderAscDesc);
              },
              // style: ElevatedButton.styleFrom(
              //   primary: isSelected
              //       ? Colors.blue
              //       : null, // Fond bleu si sélectionné
              // ),
              child: Text(statut!),
            ),
          );
        }),
      ),
    );
  }

  Future<void> fetchData() async {
    GenresList = await bdGenre.getGenresList(tableName, "");
    setState(() {});
  }

  Widget buildPageButtonsOrders() {
    return Container(
      margin: EdgeInsets.all(4.0), // Marge autour du widget complet
      child: Column(
        children: [
          const Text(
            "Ordre :",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          // Espacement entre le texte et les boutons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(AppConst.OrderList.length, (i) {
                final order = AppConst.OrderList[i];
                final isSelected = order == selectedOrder;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      currentPage = 1;
                      // Mettez à jour la valeur sélectionnée et rechargez les médias
                      setState(() {
                        if (!isSelected) {
                          selectedOrder = order;
                        }
                      });
                      loadMedia(
                          currentPage,
                          selectedStatut,
                          selectedOrder,
                          selectedGenres,
                          _controllerNom.text,
                          selectedOrderAscDesc);
                    },
                    // style: ElevatedButton.styleFrom(
                    //   primary: isSelected
                    //       ? Colors.blue
                    //       : null, // Fond bleu si sélectionné
                    // ),
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
    return
        // Espacement entre le texte et les boutons
        SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(AppConst.OrderListAscDesc.length, (i) {
          final order = AppConst.OrderListAscDesc[i];
          final isSelected = order == selectedOrderAscDesc;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {
                currentPage = 1;
                // Mettez à jour la valeur sélectionnée et rechargez les médias
                setState(() {
                  if (!isSelected) {
                    selectedOrderAscDesc = order;
                  }
                });
                loadMedia(currentPage, selectedStatut, selectedOrder,
                    selectedGenres, _controllerNom.text, selectedOrderAscDesc);
              },
              // style: ElevatedButton.styleFrom(
              //   primary: isSelected
              //       ? Colors.blue
              //       : null, // Fond bleu si sélectionné
              // ),
              child: Text(order),
            ),
          );
        }),
      ),
    );
  }
}
