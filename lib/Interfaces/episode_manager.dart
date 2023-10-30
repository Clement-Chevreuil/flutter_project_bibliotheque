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
import '../Database/database_episode.dart';
import '../Model/media.dart';
import '../Model/episode.dart';
import '../Logic/helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class EpisodeManager extends StatefulWidget {
  final Episode? episode;
  final int? idSaison;

  EpisodeManager({this.episode, this.idSaison});

  @override
  _EpisodeManagerState createState() =>
      _EpisodeManagerState(episode: episode, idSaison: idSaison);
}

class _EpisodeManagerState extends State<EpisodeManager> {
  final Episode? episode;
  final int? idSaison;

  final picker = ImagePicker();
  List<bool> _toggleValues = [false, false, false, false, false];
  final bdEpisode = DatabaseEpisode();

  String _selectedValue = "Fini";
  double? note = 0;
  int? id = null;
  Uint8List? imageBytes;

  List<bool> isSelected = List.generate(9, (index) => false);
  List<bool> _selections = [];
  bool isImagePickerActive = false;
  TextEditingController _controllerNom = TextEditingController(text: '');
  TextEditingController _controllerNote = TextEditingController(text: '');
  TextEditingController _avisController = TextEditingController(text: '');
  TextEditingController _descriptionController =
      TextEditingController(text: '');
  List<String> imageUrls = [];
  TextEditingController _textControllers = TextEditingController();

  bool isImageDialogOpen = false; // Ajoutez cette variable d'état

  late DatabaseInit _databaseInit;
  late DatabaseEpisode _databaseEpisode;
  String?
      selectedImageUrl; // Ajoutez cette variable pour stocker l'URL de l'image sélectionnée
  DatabaseHelper databaseHelper = new DatabaseHelper();
  _EpisodeManagerState({this.episode, this.idSaison});

  @override
  void initState() {
    super.initState();
    _databaseInit = DatabaseInit();

    if (episode != null) {
      _controllerNom = TextEditingController(text: episode!.nom);
      _selectedValue = episode!.statut != null ? episode!.statut! : "Fini";
      imageBytes = episode!.image;
      id = episode!.id;
      note = episode!.note != null ? episode!.note!.toDouble() : 0.0;
    }
    setState(() {});
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
                  databaseHelper
                      .openImagePicker(isImagePickerActive, picker)
                      .then((value) => setState(() {
                            this.imageBytes = Uint8List.fromList(value!);
                            selectedImageUrl =
                                null; // Réinitialisez selectedImageUrl à null
                          }));
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
                      initialRating: 0,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: TextField(
                        controller: _avisController,
                        decoration: InputDecoration(
                          labelText: 'Avis',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
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

                              imageBytes = await databaseHelper
                                  .downloadImage(selectedImageUrl!);
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

                            Episode book = Episode(
                              nom: _controllerNom.text,
                              image: imageBytes,
                              note: note!.toInt(),
                              avis: _avisController.text,
                              description: _descriptionController.text,
                              statut: _selectedValue,
                            );

                            if (id != null) {
                              book.id = id;
                            }
                            if (episode != null) {
                              await bdEpisode.update(book);
                            } else {
                              // Insert the book into the database
                              await bdEpisode.insert(book);
                            }
                            // Show a success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Episode created successfully')),
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
    await databaseHelper
        .searchImages(_controllerNom.text)
        .then((value) => setState(() {
              imageUrls = value!;
            }));
    _showImagePopup(context);
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
