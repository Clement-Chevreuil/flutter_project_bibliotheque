// data/repositories/media_repository_impl.dart
import 'package:flutter_project_n1/data/datasources/local/media_data_source.dart';
import 'package:flutter_project_n1/data/models/media.dart';
import 'package:flutter_project_n1/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaDataSource _mediaDataSource;

  MediaRepositoryImpl(this._mediaDataSource);

  @override
  Future<int> insertMedia(Media media) async {
    return await _mediaDataSource.insertMedia(media);
  }

  @override
  Future<void> updateMedia(Media media) async {
    await _mediaDataSource.updateMedia(media);
  }

  @override
  Future<void> deleteMedia(Media media) async {
    await _mediaDataSource.deleteMedia(media);
  }
}
