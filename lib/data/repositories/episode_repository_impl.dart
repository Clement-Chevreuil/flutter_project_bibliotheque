import 'package:flutter_project_n1/data/models/episode.dart';
import 'package:flutter_project_n1/domain/repositories/episode_repository.dart';

import '../datasources/database_episode.dart';

class EpisodeRepositoryImpl implements EpisodeRepository{
  final DatabaseEpisode _databaseEpisode;

  EpisodeRepositoryImpl(this._databaseEpisode);

  Future<void> addEpisode(Episode episode) async {
    await _databaseEpisode.insert(episode);
  }

  Future<void> updateEpisode(Episode episode) async {
    await _databaseEpisode.update(episode);
  }

  Future<void> deleteEpisode(Episode episode) async {
    await _databaseEpisode.delete(episode);
  }

  Future<Episode?> getEpisodeById(int id) async {
    return await _databaseEpisode.get(id);
  }

  Future<List<Episode>> getAllEpisodes(int idSeason) async {
    return await _databaseEpisode.getAll(idSeason);
  }
}
