import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Database/database_init.dart';
import '../Database/database_saison.dart';
import '../Database/database_episode.dart';
import '../Model/saison.dart';
import '../Model/episode.dart';
import '../Logic/function_helper.dart';
import '../Logic/interface_helper.dart';

class SaisonManager extends StatefulWidget {
  final Saison? mediaParam;
  final String? tableName;

  SaisonManager({this.mediaParam, required this.tableName});

  @override
  _SaisonManagerState createState() =>
      _SaisonManagerState(mediaParam: mediaParam, tableName: tableName);
}

class _SaisonManagerState extends State<SaisonManager> {

  final Saison? mediaParam;
  final String? tableName;
  final bdSaison = DatabaseSaison();
  final bdEpisode = DatabaseEpisode();
  String _selectedValue = "Fini";
  double? note = 0;
  int? id = null;
  Uint8List? imageBytes;
  List<bool> isSelected = List.generate(9, (index) => false);
  bool isImagePickerActive = false;
  TextEditingController _controllerNom = TextEditingController(text: '');
  TextEditingController _avisController = TextEditingController(text: '');
  TextEditingController _descriptionController = TextEditingController(text: '');
  List<String> imageUrls = [];
  TextEditingController _textControllers = TextEditingController();
  bool isImageDialogOpen = false; 
  late DatabaseInit _databaseInit;
  bool isInitComplete = false;
  InterfaceHelper? interfaceHelper;
  String? selectedImageUrl;
  FunctionHelper databaseHelper = new FunctionHelper();
  _SaisonManagerState({this.mediaParam, this.tableName});

  @override
  void initState() {
    super.initState();
    _databaseInit = DatabaseInit();

    double note = 0.0;
    Uint8List? imageBytes;
    String? nom;
    if (mediaParam != null) {
      nom = mediaParam!.nom;
      //_selectedValue = mediaParam!.statut!;
      imageBytes = mediaParam!.image;
      id = mediaParam!.id;
      note = mediaParam!.note!.toDouble();
    }
    interfaceHelper = InterfaceHelper(
        nom: nom, note: note, statut: "Fini", image: imageBytes);
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
        title: Text('Saison Manager'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              interfaceHelper!,
              if (id == null)
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                            controller: _textControllers,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Enter a number between 1 and 100',
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
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: TextField(
                  controller: _avisController,
                  decoration: InputDecoration(
                    labelText: 'Avis',
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                       String? nom = await interfaceHelper!.getNom();
                        Uint8List? imageBytes =
                            await interfaceHelper!.getImage();
                        String? selectedImageUrl =
                            await interfaceHelper!.getImageLink();
                        double? note = await interfaceHelper!.getNote();
                        String? statut = await interfaceHelper!.getStatut();

                      if (nom == null ) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Veuillez remplir tous les champs requis')),
                        );
                        return; // Arrêtez ici si les champs requis sont null
                      }

                      if (imageBytes == null &&
                          selectedImageUrl != null) {
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

                      Saison book = Saison(
                        nom: nom,
                        image: imageBytes,
                        note: note!.toInt(),
                        avis: _avisController.text,
                        description: _descriptionController.text,
                        statut: statut,
                      );

                      if (id != null) {
                        book.id = id;
                      }
                      if (mediaParam != null) {
                        await bdSaison.update(book);
                      } else {
                        // Insert the book into the database
                        int idSaison = await bdSaison.insert(book);
                        if (id == null) {
                          final ByteData data = await rootBundle
                              .load('images/default_image.jpeg');
                          final List<int> bytes =
                              data.buffer.asUint8List();
                          Uint8List imageBytesTest =
                              Uint8List.fromList(bytes);
                          await bdSaison.insert(book);
                          for (int j = 0;
                              j < int.parse(_textControllers.text);
                              j++) {
                            Episode episode = new Episode();
                            episode.id_saison = idSaison;
                            episode.nom = "Episode " + j.toString();
                            episode.image = imageBytesTest;
                            await bdEpisode.insert(episode);
                          }
                        }
                      }
                      // Show a success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Saison created successfully')),
                      );
                      Navigator.of(context).pop();
                    },
                    child: id != null ? Text("Update") : Text("Create"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
