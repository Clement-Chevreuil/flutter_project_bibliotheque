import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Database/database_genre.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:flutter_project_n1/Database/database_media.dart';
import 'package:flutter_project_n1/exeptions/my_exceptions.dart';
import 'package:flutter_project_n1/interfaces/media/interface_helper.dart';
import 'package:flutter_project_n1/providers/save_media_gestion.dart';
import 'package:flutter_project_n1/Interfaces/genres_index.dart';
import 'package:flutter_project_n1/functions/images/url_picture_gestionnary.dart';
import 'package:flutter_project_n1/models/media.dart';
import 'package:flutter_project_n1/models/utilisateur.dart';
import 'package:flutter_project_n1/Validations/save_media_validation.dart';

class MediaManager extends StatefulWidget {
  final Media? mediaParam;
  final String? tableName;

  const MediaManager({super.key, this.mediaParam, required this.tableName});

  @override
  State<MediaManager> createState() => _MediaManagerState(mediaParam: mediaParam, tableName: tableName);
}

class _MediaManagerState extends State<MediaManager> {
  final bdMedia = DatabaseMedia("Series");
  final bdGenre = DatabaseGenre();
  Media? mediaParam;
  String? tableName;
  int? id;
  bool isInitComplete = false;
  final List<bool> _selections = [];
  List<String> genres = [];
  List<String> _selectionsGenres = [];
  final List<String> _selectionsGenresSelected = [];
  final List<TextEditingController> _textControllers = [];
  Utilisateur? utilisateur;

  _MediaManagerState({this.mediaParam, this.tableName});
  InterfaceHelper? interfaceHelper;

  Future<void> fetchData() async {
    _selectionsGenres = await bdGenre.getGenresList(tableName, "");
  }

  Future<Utilisateur?> getUtilisateur() async {
    utilisateur = await DatabaseInit.utilisateur;
    return null;
  }

  @override
  void initState() {
    super.initState();
    DatabaseInit();
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
      interfaceHelper = InterfaceHelper(nom: nom, note: note, statut: statut, image: imageBytes);
      isInitComplete = true;
      getUtilisateur();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitComplete) {
      return const CircularProgressIndicator();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Media Manager'),
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4.0,
                        child: Column(children: [
                          ExpansionTile(
                            title: Row(
                              // Centre les éléments horizontalement
                              children: [
                                const Text(
                                  'Genre :',
                                  style: TextStyle(
                                    fontSize: 16, // Taille du texte
                                    fontWeight: FontWeight.bold, // Texte en gras
                                  ),
                                ),
                                Container(
                                  transform: Matrix4.translationValues(0, -6.0, 0), // Translation vers le haut
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
                                    }, // Remplacez null par votre fonction onPressed
                                    icon: const Icon(Icons.settings),
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
                                    margin: const EdgeInsets.all(2.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _selections[index] = !_selections[index];
                                          if (_selections[index] == false) {
                                            _selectionsGenresSelected.remove(_selectionsGenres[index]);
                                          } else {
                                            _selectionsGenresSelected.add(_selectionsGenres[index]);
                                          }
                                        });
                                      },
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          color: _selections[index] ? Colors.white : Colors.black,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(
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
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            List<int> intList = _textControllers.map((controller) {
                              int parsedValue = int.tryParse(controller.text) ?? 0;
                              return parsedValue;
                            }).toList();

                            double noteInterface = await interfaceHelper!.getNote();

                            Media media = Media(
                              id: id,
                              nom: await interfaceHelper!.getNom(),
                              note: noteInterface.toInt(),
                              statut: await interfaceHelper!.getStatut(),
                              genres: _selectionsGenresSelected,
                              image: await interfaceHelper!.getImage(),
                              selectedImageUrl: await interfaceHelper!.getImageLink(),
                              saison_episode: intList,
                              table: tableName,
                            );

                            try {
                              SaveMediaValidation.saveMediaValidation(media);
                              if (!context.mounted) {
                                return;
                              }
                              media.image = await urlPictureGestionnary(media.image, media.selectedImageUrl, context);
                              saveMediaGestion(media);
                              if (!context.mounted) {
                                return;
                              }
                              Navigator.pop(context, media);
                            } catch (e) {
                              if (e is myException) {
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(e.message),
                                  backgroundColor: Colors.red,
                                ));
                              } else {}
                            }
                          },
                          child: id != null ? const Text("Update") : const Text("Create"),
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
}
