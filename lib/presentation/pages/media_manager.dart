import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'genres_index.dart';

class MediaManager extends StatefulWidget {
  final Media? mediaParam;
  final String? tableName;

  MediaManager({this.mediaParam, required this.tableName});

  @override
  _MediaManagerState createState() =>
      _MediaManagerState(mediaParam: mediaParam, tableName: tableName);
}

class _MediaManagerState extends State<MediaManager> {
  final bdMedia = DatabaseMedia("Series");
  final bdGenre = DatabaseGenre();
  final bdSaison = DatabaseSaison();
  final bdEpisode = DatabaseEpisode();
  late DatabaseInit _databaseInit;
  FunctionHelper help = new FunctionHelper();
  Media? mediaParam;
  String? tableName;
  int? id = null;
  bool isInitComplete = false;
  List<bool> _selections = [];
  List<String> genres = [];
  List<String> _selectionsGenres = [];
  List<String> _selectionsGenresSelected = [];
  List<TextEditingController> _textControllers = [];
  TextEditingController _controllerSaison = TextEditingController();
  Utilisateur? utilisateur;

  _MediaManagerState({this.mediaParam, this.tableName});
  InterfaceHelper? interfaceHelper;
  @override
  void initState() {
    super.initState();
    _databaseInit = DatabaseInit();
    fetchData().then((_) {
      for (String item in _selectionsGenres) {
        if (mediaParam != null && mediaParam!.genres != null) {
          if (mediaParam!.genres!.contains(item)) {
            _selections.add(true);
            _selectionsGenresSelected.add(item);
          } else {
            _selections.add(false);
          }
        } else {
          _selections.add(false);
        }
      }

      bdMedia.changeTable(tableName!);
      double note = 0.0;
      Uint8List? imageBytes;
      String? nom;
      String statut = "Fini";
      if (mediaParam != null) {
        nom = mediaParam!.nom;
        //_selectedValue = mediaParam!.statut!;
        imageBytes = mediaParam!.image;
        id = mediaParam!.id;
        note = mediaParam!.note!.toDouble();
        statut = mediaParam!.statut!;
      }
      interfaceHelper = InterfaceHelper(
          nom: nom, note: note, statut: statut, image: imageBytes);
      isInitComplete = true;
      setState(() {});
      getUtilisateur();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitComplete) {
      // Attendre que l'initialisation soit terminée
      return CircularProgressIndicator(); // Ou tout autre indicateur de chargement
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Media Manager'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    interfaceHelper!,
                    if (id == null)
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Card(
                          elevation:
                              4.0, // Ajoutez une élévation à la Card si vous le souhaitez
                          child: Column(children: [
                            if (utilisateur?.saison == 1)
                              ExpansionTile(
                                title: Text("Saison - Episodes"),
                                initiallyExpanded:
                                    false, // Vous pouvez changer ceci selon vos besoins

                                children: [
                                  TextField(
                                    controller: _controllerSaison,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText:
                                          'Enter a number between 1 and 100',
                                    ),
                                    onChanged: (value) {
                                      if (int.tryParse(value) != null) {
                                        int number = int.parse(value);
                                        if (number < 1 || number > 100) {
                                          _controllerSaison.clear();
                                        } else {
                                          // Update the list of TextControllers based on the entered number
                                          _textControllers = List.generate(
                                            number,
                                            (index) => TextEditingController(),
                                          );
                                        }
                                      }
                                      setState(() {}); // Refresh the UI
                                    },
                                  ),
                                  if (utilisateur!.episode == 1)
                                    SingleChildScrollView(
                                      child: SizedBox(
                                        height: 200,
                                        child: ListView.builder(
                                          itemCount: _textControllers.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: TextField(
                                                controller:
                                                    _textControllers[index],
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      "Nombre d'episode : $index",
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  SizedBox(
                                    height: 20,
                                  )
                                ],
                              ),
                          ]),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4.0,
                        child: Column(children: [
                          ExpansionTile(
                            title: Row(
                              // Centre les éléments horizontalement
                              children: [
                                Text(
                                  'Genre :',
                                  style: TextStyle(
                                    fontSize: 16, // Taille du texte
                                    fontWeight:
                                        FontWeight.bold, // Texte en gras
                                  ),
                                ),
                                Container(
                                  transform: Matrix4.translationValues(
                                      0, -6.0, 0), // Translation vers le haut
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
                                        print("lol");
                                        fetchData();
                                      }
                                    }, // Remplacez null par votre fonction onPressed
                                    icon: Icon(Icons.settings),
                                  ),
                                ),
                              ],
                            ),
                            initiallyExpanded: false,
                            children: [
                              Wrap(
                                spacing: 0.0,
                                runSpacing: 0.0,
                                children: _selectionsGenres.map((item) {
                                  int index = _selectionsGenres.indexOf(item);
                                  return Container(
                                    width: 100.0,
                                    height: 40.0,
                                    margin: EdgeInsets.all(2.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _selections[index] =
                                              !_selections[index];
                                          if (_selections[index] == false) {
                                            _selectionsGenresSelected.remove(
                                                _selectionsGenres[index]);
                                          } else {
                                            _selectionsGenresSelected
                                                .add(_selectionsGenres[index]);
                                          }
                                        });
                                        print(_selectionsGenresSelected);
                                      },
                                      // style: ElevatedButton.styleFrom(
                                      //   shape: RoundedRectangleBorder(
                                      //     borderRadius:
                                      //         BorderRadius.circular(0.0),
                                      //   ),
                                      //   primary: _selections[index]
                                      //       ? Colors.blue
                                      //       : Colors.grey,
                                      // ),
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          color: _selections[index]
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                        ]),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            String? nom = await interfaceHelper!.getNom();
                            Uint8List? imageBytes =
                                await interfaceHelper!.getImage();
                            String? selectedImageUrl =
                                await interfaceHelper!.getImageLink();
                            double? note = await interfaceHelper!.getNote();
                            String? statut = await interfaceHelper!.getStatut();

                            if (nom == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Veuillez remplir tous les champs requis')),
                              );
                              return;
                            }
                            if (imageBytes == null &&
                                selectedImageUrl != null) {
                              imageBytes =
                                  await help.downloadImage(selectedImageUrl!);
                            }
                            if (imageBytes != null) {
                              final imageSizeInBytes =
                                  imageBytes!.lengthInBytes;
                              final imageSizeInKB = imageSizeInBytes / 1024;
                              final imageSizeInMB = imageSizeInKB / 1024;

                              if (imageSizeInMB > 2) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'La taille est trop Grande veuillez choisir une image plus petite.')),
                                );
                                return;
                              }
                            } else {
                              final ByteData data = await rootBundle
                                  .load('images/default_image.jpeg');
                              final List<int> bytes = data.buffer.asUint8List();
                              imageBytes = Uint8List.fromList(bytes);
                            }

                            // Create a Media instance with the data from UI
                            Media book = Media(
                                nom: nom,
                                image:
                                    imageBytes, // Uint8List from the image picker
                                note: note == null ? 0 : note!.toInt(),
                                statut: statut,
                                genres: _selectionsGenresSelected);

                            List<int> intList =
                                _textControllers.map((controller) {
                              int parsedValue =
                                  int.tryParse(controller.text) ?? 0;
                              return parsedValue;
                            }).toList();

                            book.updateSaisonEpisode(intList);

                            if (id != null) {
                              book.id = id;
                            }
                            if (mediaParam != null) {
                              int? verif = await bdMedia.updateMedia(book);
                              print(verif);
                              if (verif == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Erreur lors de la création du media'),
                                  ),
                                );
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Media Update Successfully')),
                              );
                              Navigator.pop(context, book);
                            } else {
                              // Insert the book into the database
                              int idMedia = await bdMedia.insertMedia(book);
                              print(idMedia);
                              if (idMedia == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Erreur lors de la création du media'),
                                  ),
                                );
                                return;
                              }
                              if (id == null) {
                                List<int> idSaison = [];

                                final ByteData data = await rootBundle
                                    .load('images/default_image.jpeg');
                                final List<int> bytes =
                                    data.buffer.asUint8List();
                                Uint8List imageBytesTest =
                                    Uint8List.fromList(bytes);

                                for (int i = 1; i < intList.length + 1; i++) {
                                  Saison saison = new Saison();
                                  saison.id_media = idMedia;
                                  saison.nom = "Saison " + i.toString();
                                  saison.image = imageBytesTest;
                                  saison.media = tableName;
                                  int idSaison = await bdSaison.insert(saison);

                                  for (int j = 0; j < intList[i - 1]; j++) {
                                    Episode episode = new Episode();
                                    episode.id_saison = idSaison;
                                    episode.nom = "Episode " + j.toString();
                                    episode.image = imageBytesTest;
                                    await bdEpisode.insert(episode);
                                  }
                                }
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Media created successfully')),
                              );
                              Navigator.pop(context, "LoadMedia");
                            }
                          },
                          child: id != null ? Text("Update") : Text("Create"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchData() async {
    _selectionsGenres = await bdGenre.getGenresList(tableName, "");
    setState(() {});
    print(_selectionsGenres);
    // Utilisez genresList comme vous le souhaitez ici
  }

  Future<Utilisateur?> getUtilisateur() async {
    utilisateur = await DatabaseInit.utilisateur;
    // Utilisez genresList comme vous le souhaitez ici
  }
}
