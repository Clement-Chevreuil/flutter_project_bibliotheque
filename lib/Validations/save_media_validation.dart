import 'package:flutter_project_n1/exeptions/my_exceptions.dart';
import 'package:flutter_project_n1/models/media.dart';

class SaveMediaValidation {
  static void saveMediaValidation(Media media) {
    if (media.nom == null || media.nom!.isEmpty) {
      throw myException('Please fill in all fields');
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
