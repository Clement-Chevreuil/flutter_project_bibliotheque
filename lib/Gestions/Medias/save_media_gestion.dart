import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Database/database_episode.dart';
import 'package:flutter_project_n1/Database/database_media.dart';
import 'package:flutter_project_n1/Database/database_saison.dart';
import 'package:flutter_project_n1/Exceptions/add_media_exceptions.dart';
import 'package:flutter_project_n1/Model/episode.dart';
import 'package:flutter_project_n1/Model/media.dart';
import 'package:flutter_project_n1/Model/saison.dart';

class SaveMediaGestion
{
  static Future<void> saveMediaGestion(Media media) async {
    final bdMedia = DatabaseMedia("Series");
    final bdEpisode = DatabaseEpisode();
    final bdSaison = DatabaseSaison();


    if (media.id != null) {
      int? verif = await bdMedia.updateMedia(media);
      if (verif == 0) {
        throw AddMediaException('Erreur lors de la création du média');
      }
    }

    else {
      int idMedia = await bdMedia.insertMedia(media);
      if (idMedia == 0) {
        throw AddMediaException('Erreur lors de la création du média');
      }

      if (media.id == null) {
        List<int> idSaison = [];

        final ByteData data = await rootBundle.load('images/default_image.jpeg');
        final List<int> bytes =
        data.buffer.asUint8List();
        Uint8List imageBytesTest =
        Uint8List.fromList(bytes);

        for (int i = 1; i < media.saison_episode!.length + 1; i++) {
          Saison saison = new Saison();
          saison.id_media = idMedia;
          saison.nom = "Saison " + i.toString();
          saison.image = imageBytesTest;
          saison.media = media.table;
          int idSaison = await bdSaison.insert(saison);

          for (int j = 0; j < media.saison_episode![i - 1]; j++) {
            Episode episode = new Episode();
            episode.id_saison = idSaison;
            episode.nom = "Episode " + j.toString();
            episode.image = imageBytesTest;
            await bdEpisode.insert(episode);
          }
        }
      }
    }
  }
}