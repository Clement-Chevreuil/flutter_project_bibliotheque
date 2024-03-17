// domain/repositories/media_repository.dart
import 'package:flutter_project_n1/data/models/media.dart';

abstract class MediaRepository {
  Future<int> insertMedia(Media media);
  Future<void> updateMedia(Media media);
  Future<void> deleteMedia(Media media);
}
