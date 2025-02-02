import 'package:flutter_project_n1/Database/database_media.dart';
import 'package:flutter_project_n1/exeptions/my_exceptions.dart';
import 'package:flutter_project_n1/models/media.dart';

Future<void> saveMediaGestion(Media media) async {
  final bdMedia = DatabaseMedia("Series");

  if (media.id != null) {
    int? verif = await bdMedia.updateMedia(media);
    if (verif == 0) {
      throw MyException('Erreur lors de la création du média');
    }
  } else {
    int idMedia = await bdMedia.insertMedia(media);
    if (idMedia == 0) {
      throw MyException('Erreur lors de la création du média');
    }
  }
}
