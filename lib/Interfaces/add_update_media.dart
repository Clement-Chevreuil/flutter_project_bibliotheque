import 'dart:ffi';
import 'dart:typed_data';
import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../Database/database_media.dart';
import '../Model/media.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class AddUpdateBookScreen extends StatefulWidget {
  final Media? mediaParam;
  final String? tableName;

  AddUpdateBookScreen({this.mediaParam, required this.tableName});

  @override
  _AddUpdateBookScreenState createState() =>
      _AddUpdateBookScreenState(mediaParam: mediaParam, tableName: tableName);
}

class _AddUpdateBookScreenState extends State<AddUpdateBookScreen> {
  final Media? mediaParam;
  final String? tableName;

  final picker = ImagePicker();

  final bdMedia = DatabaseMedia("Series");

  String nom = "test";
  String _selectedValue = "Fini";
  int note = 0;
  Uint8List? imageBytes;

  bool _isRomanceChecked = false;
  bool _isSchoolChecked = false;
  bool _isActionChecked = false;
  bool _isIsekaiChecked = false;
  bool _isAdultChecked = false;
  bool isImagePickerActive =
      false; // Add this variable to track the image picker state
  List<String> genres = [];
  TextEditingController _controllerNom = TextEditingController(text: '');
  TextEditingController _controllerNote = TextEditingController(text: '');
  List<String> imageUrls = [];

  bool isImageDialogOpen = false; // Ajoutez cette variable d'état
  String?
      selectedImageUrl; // Ajoutez cette variable pour stocker l'URL de l'image sélectionnée

  _AddUpdateBookScreenState({this.mediaParam, this.tableName});

  @override
  void initState() {
    super.initState();
    if (tableName != null) {
      print(tableName);
    }

    bdMedia.changeTable(tableName!);
    if (mediaParam != null) {
      _controllerNom = TextEditingController(text: mediaParam!.nom);
      _controllerNote =
          TextEditingController(text: mediaParam!.note.toString());
      _selectedValue = mediaParam!.statut!;
      imageBytes = mediaParam!.image;

      if (mediaParam!.genres! != null) {
        for (String item in mediaParam!.genres!) {
          if (item == "Romance") {
            _isRomanceChecked = true;
          }
          if (item == "School") {
            _isSchoolChecked = true;
          }
          if (item == "Action") {
            _isActionChecked = true;
          }
          if (item == "Isekai") {
            _isIsekaiChecked = true;
          }
          if (item == "+18") {
            _isAdultChecked = true;
          }
        }
      }
    }
  }
    Future<void> _loadImagesAndShowPopup() async {
    // Effectuez la recherche d'images
    await _searchImages(_controllerNom.text);
    
    // Affichez la boîte de dialogue des images
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Create",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                  ),
                ),
                SizedBox(height: 20),
                Visibility(
                  visible: false, // Masque le champ texte "ID"
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "ID",
                    ),
                    enabled: false,
                    controller: TextEditingController(
                      text: mediaParam?.id.toString() ?? '',
                    ),
                  ),
                ),
                TextField(
                    decoration: InputDecoration(
                      hintText: "Name",
                    ),
                    onChanged: (value) {
                      setState(() {
                        nom =
                            value; // Update the nom variable with the entered value
                      });
                    },
                    controller: _controllerNom),
                TextField(
                    decoration: InputDecoration(
                      hintText: "Note",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        note = int.parse(
                            value); // Update the nom variable with the entered value
                      });
                    },
                    controller: _controllerNote),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Ouvrez la boîte de dialogue des images lorsque vous cliquez sur l'image
                    openImagePicker();
                  },
                  child: Container(
                    width: 200,
                    height: 300,
                    color: Colors.blue[100],
                    child: selectedImageUrl != null
                        ? Image.network(
                            selectedImageUrl!,
                            width: 200,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error');
                              return Text('Image not available');
                            },
                          )
                        : imageBytes != null
                            ? Image.memory(imageBytes!)
                            : Placeholder(),
                  ),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "Fini",
                        groupValue: _selectedValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                        },
                      ),
                      Text("Fini", style: TextStyle(color: Colors.white)),
                      Radio(
                        value: "En cours",
                        groupValue: _selectedValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                        },
                      ),
                      Text("En cours", style: TextStyle(color: Colors.white)),
                      Radio(
                        value: "Abandonnee",
                        groupValue: _selectedValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                        },
                      ),
                      Text("Abandonnee", style: TextStyle(color: Colors.white)),
                      Radio(
                        value: "Envie",
                        groupValue: _selectedValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                        },
                      ),
                      Text("Envie", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isRomanceChecked,
                        onChanged: (value) {
                          setState(() {
                            _isRomanceChecked = value!;
                          });
                        },
                      ),
                      Text("Romance"),
                      Checkbox(
                        value: _isSchoolChecked,
                        onChanged: (value) {
                          setState(() {
                            _isSchoolChecked = value!;
                          });
                        },
                      ),
                      Text("School"),
                      Checkbox(
                        value: _isActionChecked,
                        onChanged: (value) {
                          setState(() {
                            _isActionChecked = value!;
                          });
                        },
                      ),
                      Text("Action"),
                      Checkbox(
                        value: _isIsekaiChecked,
                        onChanged: (value) {
                          setState(() {
                            _isIsekaiChecked = value!;
                          });
                        },
                      ),
                      Text("Isekai"),
                      Checkbox(
                        value: _isAdultChecked,
                        onChanged: (value) {
                          setState(() {
                            _isAdultChecked = value!;
                          });
                        },
                      ),
                      Text("+18"),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      },
                      child: Text("Back"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _loadImagesAndShowPopup();
                      },
                      child: Text("Chercher image"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (nom == null || (imageBytes == null && selectedImageUrl == null) || note == null) {
                          // Affichez un message d'erreur et empêchez la création
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Veuillez remplir tous les champs requis')),
                          );
                          return; // Arrêtez ici si les champs requis sont null
                        }

                        List<String> selectedGenres = [];
                        // Add selected genres to the list
                        if (_isRomanceChecked) selectedGenres.add('Romance');
                        if (_isSchoolChecked) selectedGenres.add('School');
                        if (_isActionChecked) selectedGenres.add('Action');
                        if (_isIsekaiChecked) selectedGenres.add('Isekai');
                        if (_isAdultChecked) selectedGenres.add('+18');

                        if (imageBytes == null && selectedImageUrl != null) {
                          print(selectedImageUrl!);

                          bool success = await downloadImage(selectedImageUrl!);
                          if (success) {
                            print("hey1");
                          } else {
                            print("hey");
                          }
                        }

                        // Create a Media instance with the data from UI
                        Media book = Media(
                            nom: nom, // Name from TextField,
                            image:
                                imageBytes, // Uint8List from the image picker
                            note: note,
                            statut: _selectedValue,
                            genres: selectedGenres);

                        if (mediaParam != null) {
                          await bdMedia.updateMedia(book);
                        } else {
                          // Insert the book into the database
                          await bdMedia.insertMedia(book);
                        }

                        // Show a success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Media created successfully')),
                        );
                      },
                      child: Text("Create"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
