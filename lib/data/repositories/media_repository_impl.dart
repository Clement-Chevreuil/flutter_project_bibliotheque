// data/repositories/media_repository_impl.dart
import 'package:flutter_project_n1/domain/entities/media.dart';
import 'package:flutter_project_n1/domain/repositories/media_repository.dart';
import '../../data/models/media.dart';
import '../datasources/database_media.dart';

class MediaRepositoryImpl implements MediaRepository {
  final DatabaseMedia databaseMedia;

  MediaRepositoryImpl(this.databaseMedia);

  @override
  Future<int> insertMedia(Media media) async {
    return await databaseMedia.insertMedia(media);
  }

  @override
  Future<int?> updateMedia(Media media) async {
    return await databaseMedia.updateMedia(media);
  }

  @override
  Future<void> deleteMedia(Media media) async {
    await databaseMedia.deleteMedia(media);
  }
}
