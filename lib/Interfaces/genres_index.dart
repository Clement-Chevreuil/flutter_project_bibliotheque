import 'package:flutter/material.dart';
import '../Database/database_genre.dart';
import '../Model/genre.dart';
import 'package:getwidget/getwidget.dart';
import '/Database/database_init.dart';

class GenresIndex extends StatefulWidget {
  final String? mediaParam1;

  GenresIndex({this.mediaParam1});

  @override
  _GenresIndexState createState() =>
      _GenresIndexState(mediaParam1: mediaParam1);
}

class _GenresIndexState extends State<GenresIndex> {
  bool isAdvancedSearchVisible = false;
  int? idUpdate = null;
  final String? mediaParam1;
  late DatabaseInit _databaseInit;
  final TextEditingController _controller = TextEditingController();
  TextEditingController _controllerNom = TextEditingController(text: '');
  TextEditingController _controllerGenre = TextEditingController(text: '');
  int selectedGenreIndex =
      -1; // Initialisez la variable à -1 pour indiquer qu'aucun élément n'est sélectionné au départ
  List<String> _selectionsGenres = [
    "Series",
    "Animes",
    "Games",
    "Webtoons",
    "Books",
    "Movies"
  ];

  String tableName = "Series";
  List<Genre> genres = [];
  final bdGenres = DatabaseGenre();
  final GlobalKey<AnimatedListState> _listKey =
      GlobalKey(); // Clé pour la ListView.builder
  // instantiate the controller in your state

  _GenresIndexState({this.mediaParam1});

  void initState() {
    super.initState();
    loadGenres();
    _databaseInit = DatabaseInit();

    if (mediaParam1 != null) {
      tableName = mediaParam1!;
      selectedGenreIndex = _selectionsGenres
          .indexOf(mediaParam1!); // Trouvez l'index correspondant
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddGenreDialog(context); // Affiche la popup
        },
        mini: true, // Réduit la taille du bouton
        child: Icon(Icons
            .add), // Icône du bouton flottant (vous pouvez la personnaliser)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Position du bouton flottant (en bas à droite)
      //extendBody: true,
      appBar: AppBar(
        title: Text('Genres'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle the back button click
            Navigator.pop(context,"update");
          },
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
                    loadGenres();
                  },
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 0.0,
            runSpacing: 0.0,
            children: _selectionsGenres.asMap().entries.map((entry) {
              int index = entry.key;
              String item = entry.value;
              return Container(
                width: 100.0,
                height: 40.0,
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
                      loadGenres();
                    });
                    print("Genre sélectionné : ${_selectionsGenres[index]}");
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    primary: selectedGenreIndex == index
                        ? Colors.blue
                        : Colors.grey, // Changez la couleur du bouton ici
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: selectedGenreIndex == index
                          ? Colors.white
                          : Colors.black,
                      fontSize: 11.0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: FutureBuilder<List<Genre>>(
              future: bdGenres.getGenres(tableName, _controllerNom.text),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Text('Aucun Genre.'),
                  );
                } else {
                  genres = snapshot.data!;
                  return ListView.builder(
                    key: _listKey,
                    itemCount: genres.length + 1,
                    itemBuilder: (context, index) {
                      if (index < genres.length) {
                        Genre genre = genres[index];
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Titre du livre aligné verticalement avec les autres informations
                                          GFTypography(
                                            text: genre.nom ?? '',
                                            type: GFTypographyType.typo5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Boutons légèrement décalés vers la gauche

                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      idUpdate = genre.id;
                                      _controllerGenre.text = genre.nom!;
                                      _showAddGenreDialog(
                                          context); // Affiche la popup
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await DatabaseGenre().delete(genre);
                                      loadGenres();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Genre supprimé')),
                                      );
                                    },
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
        ],
      ),
    );
  }

  //FONCTIONS
  void loadGenres() async {
    List<Genre> updatedMediaList = await bdGenres.getGenres(tableName, _controllerNom.text);
    setState(() {
      genres.clear();
      genres.addAll(
          updatedMediaList); // Ajoutez les médias chargés depuis la base de données
      _listKey.currentState
          ?.setState(() {}); // Mettre à jour la ListView.builder
    });
  }

  void _showAddGenreDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Entrez les informations du genre pour $mediaParam1 :",
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _controllerGenre,
                decoration: InputDecoration(
                  hintText: "Nom du genre",
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_controllerGenre.text == "") {
                    // Affichez un message d'erreur car _controllerGenre est nul
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Erreur : _controllerGenre est nul"),
                      ),
                    );
                  } else {
                  
                      Genre newGenre = Genre();
                      newGenre.media = tableName;
                      newGenre.nom = _controllerGenre.text;
                      _controllerGenre.text = "";
                      if (idUpdate != null) {
                        newGenre.id = idUpdate;
                        int? verif = await bdGenres.update(newGenre);
                        if(verif == 0)
                              {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur lors de la création du genre'),
                                  ),
                                );
                                return;
                              }
                        idUpdate = null;
                      } else {
                        int? verif = await bdGenres.insert(newGenre);
                        if(verif == 0)
                              {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur lors de la création du genre'),
                                  ),
                                );
                                return;
                              }
                      }

                      setState(() {});
                      Navigator.of(context).pop(); // Ferme la popup
                   
                  }
                },
                child: idUpdate != null ? Text("Update") : Text("Ajouter"),
              ),
            ],
          ),
        );
      },
    );
  }
}
