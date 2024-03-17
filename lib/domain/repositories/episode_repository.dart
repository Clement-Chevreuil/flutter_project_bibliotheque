import 'package:flutter_project_n1/data/models/episode.dart';
import 'package:flutter_project_n1/data/repositories/local/episode_repository_impl.dart';

abstract class EpisodeRepository  {
  Future<void> addEpisode(Episode episode);
  Future<void> updateEpisode(Episode episode);
  Future<void> deleteEpisode(Episode episode);
  Future<Episode?> getEpisodeById(int id);
  Future<List<Episode>> getAllEpisodes(int idSeason);
}
