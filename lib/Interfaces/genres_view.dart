import 'package:flutter/material.dart';
import 'package:flutter_project_n1/Database/database_genre.dart';
import 'package:flutter_project_n1/enums/categories_enum.dart';
import 'package:flutter_project_n1/interfaces/widgets/modal_create_genre.dart';
import 'package:flutter_project_n1/models/genre.dart';
import 'package:flutter_project_n1/providers/genre_provider.dart';
import 'package:getwidget/getwidget.dart';
import 'package:provider/provider.dart';
import '/Database/database_init.dart';

class GenresView extends StatefulWidget {
  GenresView({super.key});

  @override
  State<GenresView> createState() => _GenresViewState();
}

class _GenresViewState extends State<GenresView> {
  bool isAdvancedSearchVisible = false;
  int? idUpdate;
  late String? mediaParam1;
  final TextEditingController _controllerNom = TextEditingController();
  final TextEditingController _controllerGenre = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    DatabaseInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddGenreDialog(context, null);
        },
        mini: true,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      //extendBody: true,
      appBar: AppBar(
        title: const Text('Genres'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, "update");
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Wrap(
            spacing: 0.0,
            runSpacing: 0.0,
            children: CategoriesEnum.values.asMap().entries.map((entry) {
              int index = entry.value.index;
              String item = entry.value.name;
              return Container(
                width: 100.0,
                height: 40.0,
                margin: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<GenreProvider>().updateMediaIndex(entry.value);
                  },
                  child: Text(
                    item,
                    style: TextStyle(
                      color: context.read<GenreProvider>().mediaIndex == index ? Colors.white : Colors.black,
                      fontSize: 11.0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: Column(
              children: [
                for (Genre genre in context.read<GenreProvider>().genres)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0), // Espace autour de la Card
                    child: Card(
                      elevation: 8.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0), // Espace à l'intérieur de la Card
                        child: Row(
                          children: [
                            // Informations sur le livre à droite
                            Expanded(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Titre du livre aligné verticalement avec les autres informations
                                        GFTypography(
                                          text: genre.nom ?? '',
                                          type: GFTypographyType.typo5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Boutons légèrement décalés vers la gauche

                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                idUpdate = genre.id;
                                _controllerGenre.text = genre.nom!;
                                _showAddGenreDialog(context, genre.id); // Affiche la popup
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                context.read<GenreProvider>().deleteGenre(genre);
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Genre supprimé')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGenreDialog(BuildContext context, int? idUpdate) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AddGenreDialog(
          context: context,
          idUpdate: idUpdate,
        );
      },
    );
  }
}
