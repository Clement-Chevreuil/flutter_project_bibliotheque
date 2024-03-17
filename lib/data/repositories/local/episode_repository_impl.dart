import 'package:flutter_project_n1/data/datasources/local/episode_data_source.dart';
import 'package:flutter_project_n1/data/models/episode.dart';
import 'package:flutter_project_n1/domain/repositories/episode_repository.dart';


class EpisodeRepositoryImpl implements EpisodeRepository{
  final EpisodeDataSource _episodeDataSource;

  EpisodeRepositoryImpl(this._episodeDataSource);

  Future<void> addEpisode(Episode episode) async {
    await _episodeDataSource.insert(episode);
  }

  Future<void> updateEpisode(Episode episode) async {
    await _episodeDataSource.update(episode);
  }

  Future<void> deleteEpisode(Episode episode) async {
    await _episodeDataSource.delete(episode);
  }

  Future<Episode?> getEpisodeById(int id) async {
    return await _episodeDataSource.get(id);
  }

  Future<List<Episode>> getAllEpisodes(int idSeason) async {
    return await _episodeDataSource.getAll(idSeason);
  }
}
