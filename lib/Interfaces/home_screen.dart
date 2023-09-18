import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'add_update_media.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Database/database_helper.dart';
import '../Database/database_media.dart';
import '../Model/media.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:getwidget/getwidget.dart';

class HomeScreen extends StatefulWidget {
  final String? mediaParam1;

  HomeScreen({this.mediaParam1});

  @override
  _HomeScreenState createState() => _HomeScreenState(mediaParam1: mediaParam1);
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAdvancedSearchVisible = false;
  final String? mediaParam1;
  final TextEditingController _controller = TextEditingController();
  TextEditingController _controllerNom = TextEditingController(text: '');
  final List<String> sidebarItems = [
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies"
  ];
  List<IconData> itemIcons = [
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie,
    Icons.movie
  ]; // Ajoutez ici les icônes correspondantes

  List list = [
    "Flutter",
    "React",
    "Ionic",
    "Xamarin",
  ];
  final List<String> StatutList = [
    "Fini",
    "En cours",
    "Abandonnee",
    "Envie",
  ];
  final List<String> GenresList = [
    "Romance",
    "School",
    "Action",
    "Isekai",
    "+18",
  ];
  final List<String> OrderList = [
    "ID",
    "Note",
    "Nom",
  ];
  String? selectedStatut = null; // Variable pour stocker la valeur sélectionnée
  String? selectedOrder =
      null; // Variable pour stocker la valeur sélectionnée d'ordre
  Set<String> selectedGenres =
      Set(); // Ensemble pour stocker les genres sélectionnés
  String selectedTableName = "Series";
  String tableName = "Series";
  List<Media> books = [];
  final bdMedia = DatabaseMedia("Series");
  final GlobalKey<AnimatedListState> _listKey =
      GlobalKey(); // Clé pour la ListView.builder
  int? pageMax = 1;
  int page = 1;
  int index = 2;
  // instantiate the controller in your state

  _HomeScreenState({this.mediaParam1});

  void initState() {
    super.initState();
    loadMedia();
    loadPageButtons();
  }

  void loadMedia() async {
    bdMedia.changeTable(tableName);
    List<Media> updatedMediaList = await bdMedia.getMedias(page, selectedStatut,
        selectedOrder, selectedGenres, _controllerNom.text);
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
          Text(
            'Genre :',
            style: TextStyle(
              fontSize: 16, // Taille du texte
              fontWeight: FontWeight.bold, // Texte en gras
            ),
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
                      // Mettez à jour la valeur sélectionnée et rechargez les médias
                      setState(() {
                        if (isSelected) {
                          // Si le bouton est déjà sélectionné, annulez la sélection
                          selectedStatut = null;
                        } else {
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

  Future replaceDatabase() async {
    try {
      // Sélectionner un fichier depuis l'appareil
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null) {
        // Récupérer le fichier sélectionné
        final file = File(result.files.single.path!);

        String sourceDBPath = p.join(await getDatabasesPath(), "maBDD2.db");
        File sourceFile = File(sourceDBPath);

        // Supprimer l'ancien fichier de base de données s'il existe
        if (await sourceFile.exists()) {
          await sourceFile.delete();
        }

        bdMedia.closeDatabase();
        final appDirectory = await getDatabasesPath();
        final databasePath =
            '${appDirectory}/maBDD3.db'; // Changement de nom ici
        await file.copy(databasePath);
        bdMedia.initDatabase("maBDD3.db");
        loadMedia();

        return sourceFile.path;
      } else {
        // L'utilisateur a annulé la sélection du fichier
        return null;
      }
    } catch (e) {
      print(e);
      // Gérer l'erreur de remplacement du fichier de base de données
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action à effectuer lorsque le bouton est appuyé
          // Par exemple, vous pouvez ouvrir une nouvelle page ici
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddUpdateBookScreen(
                mediaParam: null,
                tableName: tableName,
              ),
            ),
          );
        },
        mini: true, // Réduit la taille du bouton
        child: Icon(Icons
            .add), // Icône du bouton flottant (vous pouvez la personnaliser)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Position du bouton flottant (en bas à droite)
      //extendBody: true,
      appBar: AppBar(
        title: Text('Gestion des Livres'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      'Sidebar Header',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  for (int i = 0; i < sidebarItems.length; i++)
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.zero, // Retirer les bords arrondis
                          ),
                        ),

                        backgroundColor: sidebarItems[i] == selectedTableName
                            ? MaterialStateProperty.all(Colors.transparent)
                            : MaterialStateProperty.all(
                                Colors.transparent), // Fond transparent
                      ),
                      onPressed: () {
                        setState(() {
                          selectedTableName = sidebarItems[i];
                          tableName = sidebarItems[i];
                          loadMedia();
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            itemIcons[i], // Utilisez l'icône correspondante
                            color: itemIcons[i] == selectedTableName
                                ? Colors.blue
                                : Colors.black, // Couleur de l'icône
                          ),
                          SizedBox(
                              width: 8), // Espacement entre l'icône et le texte
                          Text(
                            sidebarItems[i],
                            style: TextStyle(
                              fontWeight: sidebarItems[i] == selectedTableName
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Titre en bas du Drawer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      // Traitez l'action d'exportation ici
                      Navigator.pop(context);
                    },
                    child: Text("Exporter BDD"),
                  ),
                  TextButton(
                    onPressed: () {
                      replaceDatabase();
                      Navigator.pop(context);
                    },
                    child: Text("Remplacer BDD"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                  selectedGenres, _controllerNom.text),
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
                                                  AddUpdateBookScreen(
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
}
