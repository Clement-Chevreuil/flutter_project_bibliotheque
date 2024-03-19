import 'package:flutter/services.dart';
import 'package:flutter_project_n1/Database/database_episode.dart';
import 'package:flutter_project_n1/Database/database_media.dart';
import 'package:flutter_project_n1/Database/database_saison.dart';
import 'package:flutter_project_n1/Model/episode.dart';
import 'package:flutter_project_n1/Model/media.dart';
import 'package:flutter_project_n1/Model/saison.dart';


Future<void> saveEpisodeGestion(Episode episode) async {
  final bdEpisode = DatabaseEpisode();


  if (episode.id != null) {
    await bdEpisode.update(episode);
  }

  else {
    await bdEpisode.insert(episode);
  }
}
