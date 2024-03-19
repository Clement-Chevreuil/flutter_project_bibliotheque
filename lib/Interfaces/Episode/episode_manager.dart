import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Database/database_episode.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:flutter_project_n1/Exceptions/my_exceptions.dart';
import 'package:flutter_project_n1/Gestions/save_episode_gestion.dart';
import 'package:flutter_project_n1/Logic/Images/url_picture_gestionnary.dart';
import 'package:flutter_project_n1/Logic/Interfaces/interface_helper.dart';
import 'package:flutter_project_n1/Model/episode.dart';
import 'package:flutter_project_n1/Validations/save_episode_validation.dart';
import 'package:image_picker/image_picker.dart';

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
  final bdEpisode = DatabaseEpisode();
  int? id = null;
  Uint8List? imageBytes;
  TextEditingController _avisController = TextEditingController(text: '');
  TextEditingController _descriptionController =
      TextEditingController(text: '');
  List<String> imageUrls = [];

  late DatabaseInit _databaseInit;

  _EpisodeManagerState({this.episode, this.idSaison});

  bool isInitComplete = false;

  @override
  void initState() {
    super.initState();
    _databaseInit = DatabaseInit();

    double note = 0.0;
    Uint8List? imageBytes;
    String? nom;
    if (episode != null) {
      nom = episode!.nom;
      //statut = episode!.statut != null ? episode!.statut! : "Fini";
      imageBytes = episode!.image;
      id = episode!.id;
      note = episode!.note != null ? episode!.note!.toDouble() : 0.0;
    }
    interfaceHelper = InterfaceHelper(
        nom: nom, note: note, statut: "Fini", image: imageBytes);
    isInitComplete = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitComplete) {
      return const CircularProgressIndicator();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Episode Manager'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                      double noteInterface = await interfaceHelper!.getNote();

                      Episode episode = Episode(
                        image: await interfaceHelper!.getImage(),
                        nom: await interfaceHelper!.getNom(),
                        note:  noteInterface.toInt(),
                        statut: await interfaceHelper!.getStatut(),
                        selectedImageUrl: await interfaceHelper!.getImageLink(),

                      );

                      try
                      {
                        SaveEpisodeValidation.saveEpisodeValidation(episode);
                        episode.image = await urlPictureGestionnary(episode.image, episode.selectedImageUrl, context);
                        saveEpisodeGestion(episode);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Episode created successfully')),
                        );

                        Navigator.pop(context, episode);
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
                      };


                      Navigator.of(context).pop();
                    },
                    child: const Text("Create"),
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
