import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Database/database_episode.dart';
import 'package:flutter_project_n1/Database/database_genre.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:flutter_project_n1/Database/database_media.dart';
import 'package:flutter_project_n1/Database/database_saison.dart';
import 'package:flutter_project_n1/Exceptions/my_exceptions.dart';
import 'package:flutter_project_n1/Gestions/save_media_gestion.dart';
import 'package:flutter_project_n1/Interfaces/genres_index.dart';
import 'package:flutter_project_n1/Logic/Images/download_image.dart';
import 'package:flutter_project_n1/Logic/Images/url_picture_gestionnary.dart';
import 'package:flutter_project_n1/Logic/Interfaces/interface_helper.dart';
import 'package:flutter_project_n1/Model/media.dart';
import 'package:flutter_project_n1/Model/utilisateur.dart';
import 'package:flutter_project_n1/Validations/save_media_validation.dart';


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
      return const CircularProgressIndicator(); // Ou tout autre indicateur de chargement
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
                    if (id == null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation:
                              4.0, // Ajoutez une élévation à la Card si vous le souhaitez
                          child: Column(children: [
                            if (utilisateur?.saison == 1)
                              ExpansionTile(
                                title: const Text("Saison - Episodes"),
                                initiallyExpanded:
                                    false, // Vous pouvez changer ceci selon vos besoins

                                children: [
                                  TextField(
                                    controller: _controllerSaison,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
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
                                              padding: const EdgeInsets.all(16.0),
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
                                  const SizedBox(
                                    height: 20,
                                  )
                                ],
                              ),
                          ]),
                        ),
                      ),
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
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {

                            List<int> intList = _textControllers.map((controller)
                            {
                              int parsedValue = int.tryParse(controller.text) ?? 0;
                              return parsedValue;
                            }).toList();

                            double noteInterface = await interfaceHelper!.getNote();

                            Media media = Media(
                              id: id,
                              nom: await interfaceHelper!.getNom(),
                              note: noteInterface.toInt(),
                              statut:  await interfaceHelper!.getStatut(),
                              genres: _selectionsGenresSelected,
                              image: await interfaceHelper!.getImage(),
                              selectedImageUrl: await interfaceHelper!.getImageLink(),
                              saison_episode: intList,
                              table: tableName,
                            );

                            try
                            {
                              SaveMediaValidation.saveMediaValidation(media);
                              media.image = await urlPictureGestionnary(media.image, media.selectedImageUrl, context);
                              saveMediaGestion(media);
                              Navigator.pop(context, media);
                            }
                            catch (e)
                            {
                              if (e is myException)
                              {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                   content: Text(e.message),
                                   backgroundColor: Colors.red,
                                 ));
                              }
                              else
                              {
                                print('An unexpected error occurred: $e');
                              }
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
