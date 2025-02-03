import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_project_n1/constants/routes.dart';
import 'package:flutter_project_n1/enums/status_enum.dart';
import 'package:flutter_project_n1/models/genre.dart';
import 'package:flutter_project_n1/providers/genre_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MediaCreateView extends StatefulWidget {
  const MediaCreateView({super.key});

  @override
  State<MediaCreateView> createState() => _MediaCreateViewState();
}

class _MediaCreateViewState extends State<MediaCreateView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  XFile? _image;
  String name = "";
  int rate = 1;
  StatusEnum status = StatusEnum.envie;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Create'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_image != null) Image.file(File(_image!.path)),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(labelText: 'Enter text'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                RatingBar.builder(
                  minRating: 0,
                  itemSize: 46,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.black,
                  ),
                  updateOnDrag: true,
                  onRatingUpdate: (rating) => setState(() {
                    // note = rating;
                    // updateNote(note!);
                  }),
                  initialRating: 0,
                ),
                ToggleSwitch(
                  minWidth: 40.0,
                  minHeight: 40.0,
                  cornerRadius: 5.0,
                  inactiveFgColor: Colors.white,
                  activeBgColors: const [
                    [Colors.white54],
                    [Colors.white54],
                    [Colors.white54],
                    [Colors.white54],
                  ],
                  initialLabelIndex: status.index,
                  totalSwitches: 4,
                  customIcons: const [
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
                    status = StatusEnum.values[index!];
                  },
                ),
                ExpansionTile(
                  title: Row(
                    // Centre les éléments horizontalement
                    children: [
                      const Text(
                        'Genre :',
                      ),
                      Container(
                        transform: Matrix4.translationValues(0, -6.0, 0), // Translation vers le haut
                        child: IconButton(
                          onPressed: () async {
                            Navigator.of(context).pushNamed(Routes.genres);
                          }, // Remplacez null par votre fonction onPressed
                          icon: const Icon(Icons.settings),
                        ),
                      ),
                    ],
                  ),
                  initiallyExpanded: false,
                  children: [
                    Wrap(
                      spacing: 0.0,
                      runSpacing: 0.0,
                      children: [
                        for (Genre genre in context.read<GenreProvider>().genres)
                          Container(
                            width: 100.0,
                            height: 40.0,
                            margin: const EdgeInsets.all(2.0),
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<GenreProvider>().toggleGenresSelected(genre.id!);
                              },
                              child: Text(
                                genre.nom!,
                                style: TextStyle(
                                  color: context.read<GenreProvider>().genreIdsSelected.contains(genre.id!) ? Colors.white : Colors.black,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    )
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
