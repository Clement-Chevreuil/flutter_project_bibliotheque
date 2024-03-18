import 'package:flutter_project_n1/Exceptions/add_media_exceptions.dart';
import 'package:flutter_project_n1/Model/media.dart';

class AddMediaValidation {

  static void addMediaValidation(Media media) {
    if (media.nom == null || media.nom!.isEmpty) {
      throw AddMediaException('Please fill in all fields');
    }
  }

  static String? validateNom(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    return null;
  }

  static String? validateImage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }
}
