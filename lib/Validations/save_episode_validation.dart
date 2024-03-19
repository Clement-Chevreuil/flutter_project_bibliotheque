import 'package:flutter_project_n1/Exceptions/my_exceptions.dart';
import 'package:flutter_project_n1/Model/episode.dart';

class SaveEpisodeValidation {

  static void saveEpisodeValidation(Episode episode) {
    if (episode.nom == null || episode.nom!.isEmpty) {
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
