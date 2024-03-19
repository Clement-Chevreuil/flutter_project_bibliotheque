import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Database/database_episode.dart';
import 'package:flutter_project_n1/Database/database_saison.dart';
import 'package:flutter_project_n1/Exceptions/my_exceptions.dart';
import 'package:flutter_project_n1/Model/episode.dart';
import 'package:flutter_project_n1/Model/saison.dart';


Future<void> saveSaisonGestion(Saison saison) async {
  final bdEpisode = DatabaseEpisode();
  final bdSaison = DatabaseSaison();

  if (saison.id != null) {
    await bdSaison.update(saison);
  }

  else {
    int idMedia = await bdSaison.insert(saison);
    if (idMedia == 0) {
      throw myException('Erreur lors de la création du média');
    }

    if (saison.id == null) {

      final ByteData data = await rootBundle.load('images/default_image.jpeg');
      final List<int> bytes =
      data.buffer.asUint8List();
      Uint8List imageBytesTest =
      Uint8List.fromList(bytes);


      for (int j = 0; j < saison.episode!.length; j++) {
        Episode episode = new Episode();
        episode.id_saison = saison.id;
        episode.nom = "Episode " + j.toString();
        episode.image = imageBytesTest;
        await bdEpisode.insert(episode);
      }
    }

  }
}
