import 'dart:ffi';
import 'dart:typed_data';
import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../Database/database_media.dart';
import '../Model/media.dart';


class AddUpdateBookScreen extends StatefulWidget 
{
  final Media? mediaParam;
  final String? tableName;
  
  AddUpdateBookScreen({this.mediaParam, required this.tableName});
  
  @override
  _AddUpdateBookScreenState createState() => _AddUpdateBookScreenState(mediaParam: mediaParam, tableName: tableName);
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
  bool isImagePickerActive = false; // Add this variable to track the image picker state
  List<String> genres = [];
  TextEditingController _controllerNom = TextEditingController(text: '');
  TextEditingController _controllerNote = TextEditingController(text: '');

  _AddUpdateBookScreenState({this.mediaParam, this.tableName});

    @override
  void initState() {
    super.initState();
    if(tableName != null)
    {
      print(tableName); 
    }
    bdMedia.changeTable(tableName!);
    if (mediaParam != null) {

      _controllerNom = TextEditingController(text:  mediaParam!.nom);
      _controllerNote = TextEditingController(text:  mediaParam!.note.toString());
      _selectedValue = mediaParam!.statut! ;
      imageBytes = mediaParam!.image;
      for (String item in mediaParam!.genres!) 
      {
        if(item == "Romance")
        {
          _isRomanceChecked = true;
        }
        if(item == "School")
        {
          _isSchoolChecked = true;
        }
        if(item == "Action")
        {
          _isActionChecked = true;
        }
        if(item == "Isekai")
        {
          _isIsekaiChecked = true;
        }
        if(item == "+18")
        {
          _isAdultChecked = true;
        }
      }
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
        });
      }
    } catch (e) {
      print('Error selecting image: $e');
    } finally {
      isImagePickerActive = false; // Mark the image picker as not active
    }
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
                TextField(
                  decoration: InputDecoration(
                    hintText: "ID",
                  ),
                  enabled: false,
                  controller: TextEditingController(text: mediaParam?.id.toString() ?? ''), // Set the initial text value
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Name",
                  ),
                  onChanged: (value) {
                    setState(() {
                      nom = value; // Update the nom variable with the entered value
                    });
                  },
                  controller : _controllerNom
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Note",
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      note = int.parse(value); // Update the nom variable with the entered value
                    });
                  },
                  controller : _controllerNote
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: openImagePicker,
                  child: Container(
                    width: 200,
                    height: 300,
                    color: Colors.blue[100],
                      child: imageBytes != null
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
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                          List<String> selectedGenres = [];  
                          // Add selected genres to the list
                          if (_isRomanceChecked) selectedGenres.add('Romance');
                          if (_isSchoolChecked) selectedGenres.add('School');
                          if (_isActionChecked) selectedGenres.add('Action');
                          if (_isIsekaiChecked) selectedGenres.add('Isekai');
                          if (_isAdultChecked) selectedGenres.add('+18');

                        // Create a Media instance with the data from UI
                        Media book = Media(
                          nom: nom,// Name from TextField,
                          image: imageBytes, // Uint8List from the image picker
                          note: note,
                          statut: _selectedValue,
                          genres: selectedGenres
                          
                        );

                        if(mediaParam != null)
                        {
                          await bdMedia.updateMedia(book);
                        }
                        else
                        {
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
