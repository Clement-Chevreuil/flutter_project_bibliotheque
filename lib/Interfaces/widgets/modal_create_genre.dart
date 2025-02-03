import 'package:flutter/material.dart';
import 'package:flutter_project_n1/models/genre.dart';
import 'package:flutter_project_n1/providers/genre_provider.dart';
import 'package:provider/provider.dart';

class AddGenreDialog extends StatelessWidget {
  final BuildContext context;
  final TextEditingController _controllerGenre = TextEditingController();
  final int? idUpdate;
  final bdGenres;
  final _formKey = GlobalKey<FormState>();

  AddGenreDialog({
    super.key,
    required this.context,
    this.idUpdate,
    this.bdGenres,
  });

  Future<void> submit() async {
    Genre newGenre = Genre();
    newGenre.nom = _controllerGenre.text;
    newGenre.id = idUpdate;

    _controllerGenre.text = "";
    context.read<GenreProvider>().saveGenre(newGenre);
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop(); // Ferme la popup
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Entrez les informations du genre",
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _controllerGenre,
              decoration: const InputDecoration(
                hintText: "Nom du genre",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom de genre';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  await submit();
                }
              },
              child: idUpdate != null ? const Text("Update") : const Text("Ajouter"),
            ),
          ],
        ),
      ),
    );
  }
}
