import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Database/database_episode.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:flutter_project_n1/Database/database_saison.dart';
import 'package:flutter_project_n1/Exceptions/my_exceptions.dart';
import 'package:flutter_project_n1/Gestions/save_saison_gestion.dart';
import 'package:flutter_project_n1/Logic/Images/url_picture_gestionnary.dart';
import 'package:flutter_project_n1/Logic/Interfaces/interface_helper.dart';
import 'package:flutter_project_n1/Model/saison.dart';
import 'package:flutter_project_n1/Validations/save_saison_validation.dart';

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
  TextEditingController _avisController = TextEditingController(text: '');
  TextEditingController _descriptionController = TextEditingController(text: '');
  List<String> imageUrls = [];
  TextEditingController _textControllers = TextEditingController();
  bool isImageDialogOpen = false; 
  late DatabaseInit _databaseInit;
  bool isInitComplete = false;
  InterfaceHelper? interfaceHelper;
  String? selectedImageUrl;
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
        title: const Text('Saison Manager'),
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
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation:
                        4.0, // Ajoutez une élévation à la Card si vous le souhaitez
                    child: Column(children: [
                      ExpansionTile(
                        title: const Text("Saison - Episodes"),
                        initiallyExpanded:
                            false, // Vous pouvez changer ceci selon vos besoins

                        children: [
                          TextField(
                            controller: _textControllers,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Enter a number between 1 and 100',
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
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: TextField(
                  controller: _avisController,
                  decoration: const InputDecoration(
                    labelText: 'Avis',
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      double? note = await interfaceHelper!.getNote();
                      Saison saison = Saison(
                        nom: await interfaceHelper!.getNom(),
                        image: await interfaceHelper!.getImage(),
                        selectedImageUrl: await interfaceHelper!.getImageLink(),
                        note: note.toInt(),
                          statut: await interfaceHelper!.getStatut(),
                      );


                      try
                      {
                        SaveSaisonValidation.saveSaisonValidation(saison);
                        saison.image = await urlPictureGestionnary(saison.image, saison.selectedImageUrl, context);
                        saveSaisonGestion(saison);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Saison created successfully')),
                        );
                        Navigator.pop(context, saison);

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

                      Navigator.of(context).pop();
                    },
                    child: id != null ? const Text("Update") : const Text("Create"),
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
