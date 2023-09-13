import 'dart:typed_data';

class Media {
  int? id;
  String? nom;
  Uint8List? image; // Utilisez Uint8List pour stocker des données binaires
  int? note;
  String? statut;
  List<String>? genres;

  Media({
    this.id,
    this.nom,
    this.image,
    this.note,
    this.statut,
    this.genres,
  });

  Media.withoutID({
    this.nom,
    this.image,
    this.note,
    this.statut,
    this.genres,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'image': image,
      'note': note,
      'statut': statut,
      'genres': genres?.join(', ') ?? "",
    };
  }
}
