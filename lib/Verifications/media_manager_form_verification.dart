import 'package:flutter_project_n1/Model/media.dart';

class MediaManagerFormVerification {

  bool VerificationMedia(Media media) {
    // Validation des données
    if (media == null) {
      return false; // Les champs ne doivent pas être vides
    }
    return true;
  }
}
