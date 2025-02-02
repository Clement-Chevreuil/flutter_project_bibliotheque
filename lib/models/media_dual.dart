import 'dart:typed_data';

class MediaDual {
  String? nom;
  String? nom2;

  int? note;
  int? note2;

  String? statut;
  String? statut2;

  Uint8List? image; // Utilisez Uint8List pour stocker des données binaires

  MediaDual({
    this.nom,
    this.nom2,
    this.note,
    this.note2,
    this.statut,
    this.statut2,
    this.image,
  });

   Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'nom2': nom2,
      'note': note,
      'note2': note2,
      'statut': statut,
      'statut2': statut2,
      'image': image,
    };
  }
}
