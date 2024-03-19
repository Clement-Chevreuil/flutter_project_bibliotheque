import 'package:flutter_project_n1/Exceptions/my_exceptions.dart';
import 'package:flutter_project_n1/Model/saison.dart';

class SaveSaisonValidation {

  static void saveSaisonValidation(Saison saison) {
    if (saison.nom == null || saison.nom!.isEmpty) {
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
