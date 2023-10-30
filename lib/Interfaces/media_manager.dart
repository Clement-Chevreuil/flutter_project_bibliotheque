import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sqflite/sqflite.dart';

import 'media_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../Database/database_media.dart';
import '../Database/database_genre.dart';
import '../Database/database_init.dart';
import '../Database/database_saison.dart';
import '../Database/database_episode.dart';
import '../Model/media.dart';
import '../Model/saison.dart';
import '../Model/episode.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MediaManager extends StatefulWidget {
  final Media? mediaParam;
  final String? tableName;

  MediaManager({this.mediaParam, required this.tableName});

  @override
  _MediaManagerState createState() =>
      _MediaManagerState(mediaParam: mediaParam, tableName: tableName);
}

class _MediaManagerState extends State<MediaManager> {
  final Media? mediaParam;
  final String? tableName;

  final picker = ImagePicker();
  List<bool> _toggleValues = [false, false, false, false, false];
  final bdMedia = DatabaseMedia("Series");
  final bdGenre = DatabaseGenre();
  final bdSaison = DatabaseSaison();
  final bdEpisode = DatabaseEpisode();

  String _selectedValue = "Fini";
  double? note = 0;
  int? id = null;
  Uint8List? imageBytes;

  List<bool> isSelected = List.generate(9, (index) => false);
  List<bool> _selections = [];
  bool isImagePickerActive =
      false; // Add this variable to track the image picker state
  List<String> genres = [];
  TextEditingController _controllerNom = TextEditingController(text: '');
  TextEditingController _controllerNote = TextEditingController(text: '');
  List<String> imageUrls = [];
  final TextEditingController _controllerSaison = TextEditingController();
  List<TextEditingController> _textControllers = [];

  //GESTION GENRE

  List<String> _selectionsGenres = [];
  List<String> _selectionsGenresSelected = [];

  bool isImageDialogOpen = false; // Ajoutez cette variable d'état

  late DatabaseInit _databaseInit;
  late DatabaseEpisode _databaseEpisode;
  late DatabaseSaison _databaseSaison;
  String?
      selectedImageUrl; // Ajoutez cette variable pour stocker l'URL de l'image sélectionnée

  _MediaManagerState({this.mediaParam, this.tableName});

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
      if (mediaParam != null) {
        _controllerNom = TextEditingController(text: mediaParam!.nom);
        _selectedValue = mediaParam!.statut!;
        imageBytes = mediaParam!.image;
        id = mediaParam!.id;
        note = mediaParam!.note!.toDouble();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Menu Example'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Ouvrez la boîte de dialogue des images lorsque vous cliquez sur l'image
                  openImagePicker();
                },
                child: Container(
                    width: double.infinity,
                    height: 350, // Ajustez la hauteur selon vos besoins
                    color: Colors.transparent,
                    child: selectedImageUrl != null
                        ? Stack(
                            children: [
                              Image.network(
                                selectedImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $error');
                                  return Text('Image not available');
                                },
                              ),
                            ],
                          )
                        : imageBytes != null
                            ? Stack(
                                children: [
                                  Image.memory(imageBytes!), // Votre image
                                ],
                              )
                            : Stack(
                                children: [
                                  Container(
                                    color: Colors.grey,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Image',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              )),
              ),
              Card(
                color: Colors.transparent,
                margin: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                elevation: 0,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                              ),
                              decoration: InputDecoration(
                                hintText: "Recherche...",
                                hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                border: InputBorder.none,
                              ),
                              controller: _controllerNom,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                            onPressed: _loadImagesAndShowPopup,
                          ),
                        ],
                      ),
                    ),
                    RatingBar.builder(
                      minRating: 0,
                      itemSize: 46,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.black,
                      ),
                      updateOnDrag: true,
                      onRatingUpdate: (rating) => setState(() {
                        note = rating;
                        // Vous devrez peut-être adapter cela en fonction de votre code
                        // Si 'rating' est lié à un état, sinon ignorez cette partie
                      }),
                      initialRating: note!,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ToggleSwitch(
                      minWidth: 40.0,
                      minHeight: 40.0,
                      cornerRadius: 5.0,
                      inactiveFgColor: Colors.white,
                      activeBgColors: [
                        [Colors.white54],
                        [Colors.white54],
                        [Colors.white54],
                        [Colors.white54],
                      ],
                      initialLabelIndex: 0,
                      totalSwitches: 4,
                      customIcons: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 20.0,
                        ),
                        Icon(
                          Icons.check,
                          size: 20.0,
                        ),
                        Icon(
                          Icons.cancel_outlined,
                          size: 20.0,
                        ),
                        Icon(
                          Icons.star_border,
                          size: 20.0,
                        )
                      ],
                      onToggle: (index) {
                        List<String> StatutList = [
                          "En cours",
                          "Fini",
                          "Abandonnee",
                          "Envie",
                        ];
                        _selectedValue = StatutList[index!];
                      },
                    ),
                    if (id == null)
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Card(
                          elevation:
                              4.0, // Ajoutez une élévation à la Card si vous le souhaitez
                          child: Column(children: [
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
                                SingleChildScrollView(
                                  child: SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      itemCount: _textControllers.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: TextField(
                                            controller: _textControllers[index],
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              labelText: 'Text $index',
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
                        elevation:
                            4.0, // Ajoutez une élévation à la Card si vous le souhaitez
                        child: Column(children: [
                          ExpansionTile(
                            title: Text("Genres"),

                            initiallyExpanded:
                                false, // Vous pouvez changer ceci selon vos besoins

                            children: [
                              ElevatedButton(
                                  onPressed: null, child: Text("Ajouter")),
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
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0.0),
                                        ),
                                        primary: _selections[index]
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
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
                            if (_controllerNom.text == null || note == null) {
                              // Affichez un message d'erreur et empêchez la création
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Veuillez remplir tous les champs requis')),
                              );
                              return; // Arrêtez ici si les champs requis sont null
                            }

                            if (imageBytes == null &&
                                selectedImageUrl != null) {
                              print(selectedImageUrl!);

                              bool success =
                                  await downloadImage(selectedImageUrl!);
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
                                nom:
                                    _controllerNom.text, // Name from TextField,
                                image:
                                    imageBytes, // Uint8List from the image picker
                                note: note!.toInt(),
                                statut: _selectedValue,
                                genres: _selectionsGenresSelected);

                            List<int> intList =
                                _textControllers.map((controller) {
                              int parsedValue = int.tryParse(controller.text) ??
                                  0; // Use 0 as a default if parsing fails
                              return parsedValue;
                            }).toList();

                            book.updateSaisonEpisode(intList);

                            if (id != null) {
                              book.id = id;
                            }
                            if (mediaParam != null) {
                              await bdMedia.updateMedia(book);
                            } else {
                              // Insert the book into the database
                              int idMedia = await bdMedia.insertMedia(book);
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
                            }
                            // Show a success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Media created successfully')),
                            );
                            Navigator.of(context).pop();
                          },
                          child: Text("Create"),
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

  //FONCTIONS
  Future<void> _loadImagesAndShowPopup() async {
    await _searchImages(_controllerNom.text);
    _showImagePopup(context);
  }

  Future<bool> downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final imageBytes2 = response.bodyBytes;
        imageBytes = Uint8List.fromList(imageBytes2);
        return true; // Image téléchargée avec succès
      } else {
        print(
            'Échec du téléchargement de l\'image. Statut HTTP : ${response.statusCode}');
        return false; // Échec du téléchargement de l'image
      }
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image : $e');
      return false; // Erreur lors du téléchargement de l'image
    }
  }

  Future<void> _searchImages(String searchTerm) async {
    final apiKey = 'AIzaSyCK0hAKBHu6fQhlKTOtBj2LbKNTuniLNmA';
    final cx = '40dc66ef904ad48c9';
    final apiUrl =
        'https://www.googleapis.com/customsearch/v1?q=$searchTerm&key=$apiKey&cx=$cx&num=10&searchType=image';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Récupérez le nombre total de résultats en tant qu'entier.
        final int totalResults =
            int.tryParse(responseData['searchInformation']['totalResults']) ??
                0;

        // Affichez le nombre total de résultats dans la console.
        print('Nombre total de résultats : $totalResults');

        // Récupérez les liens vers les images à partir de la réponse.
        final List<dynamic> items = responseData['items'];
        imageUrls = [];
        for (var item in items) {
          final imageUrl = item['link'];
          imageUrls.add(imageUrl);
          print(imageUrl);
        }
        setState(() {});
      } else {
        // Gérez les erreurs de l'API ici.
        print('Erreur de l\'API : ${response.statusCode}');
        // Affichez un message d'erreur à l'utilisateur.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de l\'API')),
        );
      }
    } catch (e) {
      // Gérez les erreurs de requête ici.
      print('Erreur de requête : $e');
      // Affichez un message d'erreur à l'utilisateur.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de requête')),
      );
    }
  }

  Future<void> openImagePicker() async {
    if (isImagePickerActive) {
      return; // Return if the image picker is already active
    }

    isImagePickerActive = true; // Mark the image picker as active
    try {
      final pickedImage = await picker.getImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        final imageBytes = await pickedImage.readAsBytes();
        setState(() {
          this.imageBytes = Uint8List.fromList(imageBytes);
          selectedImageUrl = null; // Réinitialisez selectedImageUrl à null
        });
      }
    } catch (e) {
      print('Error selecting image: $e');
    } finally {
      isImagePickerActive = false; // Mark the image picker as not active
    }
  }

  Future<void> fetchData() async {
    _selectionsGenres = await bdGenre.getGenresList(tableName, "");
    print(_selectionsGenres);
    // Utilisez genresList comme vous le souhaitez ici
  }

  void _showImagePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Images'),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imageUrls.isNotEmpty)
                  for (String imageUrl in imageUrls)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImageUrl = imageUrl;
                          imageBytes = null; // Réinitialisez imageBytes à null
                        });
                        Navigator.of(context)
                            .pop(); // Fermez la boîte de dialogue
                      },
                      child: Image.network(
                        imageUrl,
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return Text('Image not available');
                        },
                      ),
                    ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
