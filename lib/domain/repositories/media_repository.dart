

import '../../data/models/media.dart';

abstract class MediaRepository {
  Future<int> insertMedia(Media media);
  Future<int?> updateMedia(Media media);
  Future<void> deleteMedia(Media media);
}
