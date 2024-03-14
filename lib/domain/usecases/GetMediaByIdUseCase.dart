
import '../entities/media.dart';
import '../repositories/media_repository.dart';

class GetMediaByIdUseCase {
  final MediaRepository _mediaRepository;

  GetMediaByIdUseCase(this._mediaRepository);

  Future<Media?> execute(int mediaId) async {
    try {
      // Appel du repository pour récupérer le média en fonction de son ID
      return await _mediaRepository.get(mediaId);
    } catch (e) {
      // Gestion des erreurs
      throw Exception('Erreur lors de la récupération du média: $e');
    }
  }
}
