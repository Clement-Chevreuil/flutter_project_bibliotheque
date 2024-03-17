import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<bool> _selections = [];
  TextEditingController _avisController = TextEditingController(text: '');
  TextEditingController _descriptionController =
      TextEditingController(text: '');
  List<String> imageUrls = [];

  late DatabaseInit _databaseInit;
  FunctionHelper databaseHelper = new FunctionHelper();

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
      return CircularProgressIndicator();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Episode Manager'),
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
                      Uint8List? imageBytes = await interfaceHelper!.getImage();
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

                      if (imageBytes == null && selectedImageUrl != null) {
                        imageBytes = await databaseHelper
                            .downloadImage(selectedImageUrl!);
                      }

                      if (imageBytes != null) {
                        final imageSizeInBytes = imageBytes!.lengthInBytes;
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
                        final ByteData data =
                            await rootBundle.load('images/default_image.jpeg');
                        final List<int> bytes = data.buffer.asUint8List();
                        imageBytes = Uint8List.fromList(bytes);
                      }

                      Episode book = Episode(
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
                      if (episode != null) {
                        await bdEpisode.update(book);
                      } else {
                        await bdEpisode.insert(book);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Episode created successfully')),
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
      ),
    );
  }
}
