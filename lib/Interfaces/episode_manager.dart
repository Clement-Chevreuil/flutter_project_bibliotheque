import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../Database/database_init.dart';
import '../Database/database_episode.dart';
import '../Model/episode.dart';
import '../Logic/helper.dart';
import '../Logic/interface_helper.dart';

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
   InterfaceHelper? interfaceHelper;
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
    bool isInitComplete = false;

  @override
  void initState() {
    super.initState();
    _databaseInit = DatabaseInit();

    String? nom; 
    if (episode != null) {
      nom = episode!.nom;
      _selectedValue = episode!.statut != null ? episode!.statut! : "Fini";
      imageBytes = episode!.image;
      id = episode!.id;
      note = episode!.note != null ? episode!.note!.toDouble() : 0.0;
    }
    interfaceHelper = InterfaceHelper(nom: nom, note: note, statut: "Fini", image: imageBytes);
    isInitComplete = true;
    setState(() {});
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
        title: Text('Menu Example'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
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
                        // ElevatedButton(
                        //   onPressed: () async {
                        //     if (_controllerNom.text == null || note == null) {
                        //       // Affichez un message d'erreur et empêchez la création
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         SnackBar(
                        //             content: Text(
                        //                 'Veuillez remplir tous les champs requis')),
                        //       );
                        //       return; // Arrêtez ici si les champs requis sont null
                        //     }

                        //     if (imageBytes == null &&
                        //         selectedImageUrl != null) {
                        //       print(selectedImageUrl!);

                        //       imageBytes = await databaseHelper
                        //           .downloadImage(selectedImageUrl!);
                        //     }

                        //     if (imageBytes != null) {
                        //       final imageSizeInBytes =
                        //           imageBytes!.lengthInBytes;
                        //       final imageSizeInKB = imageSizeInBytes / 1024;
                        //       final imageSizeInMB = imageSizeInKB / 1024;

                        //       if (imageSizeInMB > 2) {
                        //         ScaffoldMessenger.of(context).showSnackBar(
                        //           SnackBar(
                        //               content: Text(
                        //                   'La taille est trop Grande veuillez choisir une image plus petite.')),
                        //         );
                        //         return;
                        //       }
                        //     } else {
                        //       final ByteData data = await rootBundle
                        //           .load('images/default_image.jpeg');
                        //       final List<int> bytes = data.buffer.asUint8List();
                        //       imageBytes = Uint8List.fromList(bytes);
                        //     }

                        //     Episode book = Episode(
                        //       nom: _controllerNom.text,
                        //       image: imageBytes,
                        //       note: note!.toInt(),
                        //       avis: _avisController.text,
                        //       description: _descriptionController.text,
                        //       statut: _selectedValue,
                        //     );

                        //     if (id != null) {
                        //       book.id = id;
                        //     }
                        //     if (episode != null) {
                        //       await bdEpisode.update(book);
                        //     } else {
                        //       // Insert the book into the database
                        //       await bdEpisode.insert(book);
                        //     }
                        //     // Show a success message
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(
                        //           content:
                        //               Text('Episode created successfully')),
                        //     );
                        //     Navigator.of(context).pop();
                        //   },
                        //   child: Text("Create"),
                        // ),
                      ],
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
