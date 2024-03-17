import 'dart:typed_data';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../function/function_helper.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

class InterfaceHelper extends StatefulWidget {
  String? nom;
  double? note;
  String? statut;
  Uint8List? image;
  String? imageLink;

  InterfaceHelper({
    this.nom,
    this.note,
    this.statut,
    this.image,
  });

  @override
  _InterfaceHelperState createState() => _InterfaceHelperState(
        nom: nom,
        note: note,
        statut: statut,
        imageBytes: image,
      );

  Future<String> getNom() async {
    return nom!;
  }

  Future<double> getNote() async {
    return note!;
  }

  Future<String> getStatut() async {
    return statut!;
  }

  Future<Uint8List?> getImage() async {
    if (image != null) {
      return image!;
    } else {
      return null;
    }
  }

  Future<String?> getImageLink() async {
    if (imageLink != null) {
      return imageLink!;
    } else {
      return null;
    }
  }
}

class _InterfaceHelperState extends State<InterfaceHelper> {
  String? nom;
  String? statut;
  double? note = 0.0;
  Uint8List? imageBytes;
  List<List<dynamic>> _filmsData = [];
  List<String> _suggestions = [];


  _InterfaceHelperState({this.nom, this.note, this.statut, this.imageBytes});
  TextEditingController _controllerNom = TextEditingController(text: '');
  String _selectedValue = "Fini";

  FunctionHelper help = new FunctionHelper();
  bool isImagePickerActive = false;
  final picker = ImagePicker();
  String? selectedImageUrl;
  List<String> imageUrls = [];
  int initialIndexToggle = 0;

  @override
  void initState() {
    super.initState();
    _loadFilmsData();
    print(nom);
    _controllerNom = TextEditingController(text: nom);

    if(statut == "En cours")
    {
      initialIndexToggle = 0;
    }
    if(statut == "Fini")
    {
      initialIndexToggle = 1;
    }
     if(statut == "Abandonnee")
     {
      initialIndexToggle = 2;
     }
    if(statut == "Envie")
    {
      initialIndexToggle = 3;
    }
    setState(() {
      
    });
    print(initialIndexToggle);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            help
                .openImagePicker(isImagePickerActive, picker)
                .then((value) => setState(() {
                      this.imageBytes = Uint8List.fromList(value!);
                      selectedImageUrl =
                          null; // Réinitialisez selectedImageUrl à null
                      updateImage(imageBytes!);
                    }));
            ;
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
          color: Colors.blue,
          margin: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(children: [
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
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
                            onChanged: (value) => updateNom(value),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 200, // Taille fixe souhaitée
                            child: ListView.builder(
                              itemCount: _suggestions.length,
                              itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => onSuggestionClicked(_suggestions[index]),
                                child: ListTile(
                                  title: Text(_suggestions[index]),
                                ),
                              );
                              },
                            ),
                          ),

                        ],
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
                  updateNote(note!);
                }),
                initialRating: note!,
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
                      initialLabelIndex: initialIndexToggle,
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
                        print(_selectedValue);
                        updateStatut(_selectedValue);
                      },
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  //FONCTIONS
  Future<void> _loadImagesAndShowPopup() async {
    await help.searchImages(_controllerNom.text).then((value) => setState(() {
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
                          updateImageLink(selectedImageUrl!);
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

  void updateNom(String newNom) {
    setState(() {
      widget.nom = newNom;
      _suggestions = _filmsData
          .where((film) =>
          film[0].toString().toLowerCase().startsWith(newNom.toLowerCase()))
          .map((film) => film[0].toString())
          .toList();
    });
  }

  void updateNote(double newNote) {
    setState(() {
      widget.note = newNote;
    });
  }

  void updateStatut(String newStatut) {
    
      widget.statut = newStatut;
    
  }

  void updateImage(Uint8List newImage) {
    setState(() {
      widget.image = newImage;
      widget.imageLink = null;
    });
  }

  void updateImageLink(String newImage) {
    setState(() {
      widget.imageLink = newImage;
      widget.image = null;
    });
  }

  Future<void> _loadFilmsData() async {
    final String raw = await rootBundle.loadString('data/donnees.csv');
    List<List<dynamic>> parsed = CsvToListConverter().convert(raw);
    setState(() {
      _filmsData = parsed;
    });
    print(_filmsData);
    print("hey");
  }

  void onSuggestionClicked(String suggestion) {
    setState(() {
      _controllerNom.text = suggestion;
      updateNom(suggestion);
    });
  }

}
