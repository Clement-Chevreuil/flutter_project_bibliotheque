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

  String tableName = "Series";
  List<Media> books = [];
  final bdMedia = DatabaseMedia("Series");
  final GlobalKey<AnimatedListState> _listKey =
      GlobalKey(); // Clé pour la ListView.builder
  int? pageMax = 1;
  int page = 1;

  _HomeScreenState({this.mediaParam1});

  void initState() {
    super.initState();
    loadMedia();
    loadPageButtons();
  }

  void loadMedia() async {
    bdMedia.changeTable(tableName);
    List<Media> updatedMediaList = await bdMedia.getMedias(
        page, selectedStatut, selectedOrder, selectedGenres, _controllerNom.text);
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
    int? pageCount = await bdMedia.countPageMedia();
    if (pageCount != null) {
      setState(() {
        pageMax = pageCount;
      });
    }
  }

  // Fonction pour créer les boutons en fonction du nombre de pages
  Widget buildPageButtons(int pageCount) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(pageCount, (i) {
          final pageNumber = i + 1;
          final isSelected =
              pageNumber == page; // Vérifiez si le bouton est sélectionné

          return ElevatedButton(
            onPressed: () {
              // Mettez à jour la page sélectionnée
              setState(() {
                page = pageNumber;
              });
              loadMedia();
            },
            style: ElevatedButton.styleFrom(
              primary:
                  isSelected ? Colors.blue : null, // Fond bleu si sélectionné
            ),
            child: Text('Page $pageNumber'),
          );
        }),
      ),
    );
  }

  // Fonction pour créer les boutons en fonction du nombre de pages
  Widget buildPageButtonsGenres() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(GenresList.length, (i) {
          final genre = GenresList[i];
          final isSelected = selectedGenres
              .contains(genre); // Vérifiez si le genre est sélectionné

          return ElevatedButton(
            onPressed: () {
              // Mettez à jour les genres sélectionnés en ajoutant ou en supprimant le genre
              setState(() {
                if (isSelected) {
                  selectedGenres.remove(genre); // Désélectionner le genre
                } else {
                  selectedGenres.add(genre); // Sélectionner le genre
                }
              });
              loadMedia();
            },
            style: ElevatedButton.styleFrom(
              primary:
                  isSelected ? Colors.blue : null, // Fond bleu si sélectionné
            ),
            child: Text(genre),
          );
        }),
      ),
    );
  }

  Widget buildPageButtonsStatut() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(StatutList.length, (i) {
        final statut = StatutList[i];
        final isSelected = statut == selectedStatut; // Vérifiez si le bouton est sélectionné

        return ElevatedButton(
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
            primary:
                isSelected ? Colors.blue : null, // Fond bleu si sélectionné
          ),
          child: Text(statut),
        );
      }),
    ),
  );
}

 Widget buildPageButtonsOrders() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(OrderList.length, (i) {
        final order = OrderList[i];
        final isSelected =
            order == selectedOrder; // Vérifiez si le bouton est sélectionné

        return ElevatedButton(
          onPressed: () {
            // Mettez à jour la valeur d'ordre sélectionnée et rechargez les médias
            setState(() {
              selectedOrder = order;
            });
            loadMedia();
          },
          style: ElevatedButton.styleFrom(
            primary:
                isSelected ? Colors.blue : null, // Fond bleu si sélectionné
          ),
          child: Text(order),
        );
      }),
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
      appBar: AppBar(
        title: Text('Gestion des Livres'),
      ),
      drawer: Drawer(
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
            for (String item in sidebarItems)
              ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    tableName = item;
                    loadMedia();
                  });
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          if (pageMax != null) buildPageButtons(pageMax!),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Name",
                  ),
                  controller: _controllerNom
                ),
              ),
              ElevatedButton(
                onPressed: loadMedia,
                child: Text('Search'),
              ),
            ],
          ),
          AnimatedContainer(
            height: isAdvancedSearchVisible
                ? null
                : 0, // Utilisez null pour la hauteur pour permettre l'animation
            duration: Duration(milliseconds: 300), // Durée de l'animation
            child: Column(children: [
              buildPageButtonsGenres(),
              buildPageButtonsOrders(),
              buildPageButtonsStatut(),
            ]),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isAdvancedSearchVisible =
                    !isAdvancedSearchVisible; // Inversez la visibilité du bloc
              });
            },
            child: Text('Recherche Avancée'),
          ),
          Expanded(
            child: FutureBuilder<List<Media>>(
              future: bdMedia.getMedias(
                  page, selectedStatut, selectedOrder, selectedGenres, _controllerNom.text),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Text('Aucun livre enregistré.'),
                  );
                } else {
                  books = snapshot.data!;
                  return ListView.builder(
                    key: _listKey, // Utilisation de la clé ici
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      Media book = books[index];
                      return ListTile(
                        title: Text(book.nom ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Note: ${book.note ?? ''}'),
                            Text('Statut: ${book.statut ?? ''}'),
                            Text('Genres: ${book.genres?.join(', ') ?? ''}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddUpdateBookScreen(
                                      mediaParam:
                                          book, // Vous pouvez passer une instance Media si nécessaire
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Livre supprimé')),
                                );
                              },
                            ),
                          ],
                        ),
                        leading: Image.memory(book.image ?? Uint8List(0)),
                      );
                    },
                  );
                }
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
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
                  child: Text('Creer'),
                ),
                ElevatedButton(
                  onPressed: () {
                    DatabaseHelper().exportDatabase(context);
                  },
                  child: Text('Exporter la base de données'),
                ),
                ElevatedButton(
                  onPressed: () {
                    replaceDatabase();
                  },
                  child: Text('Remplacer la base de données'),
                ),
                // Add more buttons here if needed
              ],
            ),
          )
        ],
      ),
    );
  }
}
