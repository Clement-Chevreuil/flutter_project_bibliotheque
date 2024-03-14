import 'dart:typed_data';

class Episode {
  int? id;
  int? saisonId;
  String? nom;
  Uint8List? image;
  int? note;
  String? statut;
  String? description;
  String? avis;
  DateTime? createdAt;
  DateTime? updatedAt;

  Episode({
    this.id,
    this.saisonId,
    this.nom,
    this.image,
    this.note,
    this.statut,
    this.description,
    this.avis,
    this.createdAt,
    this.updatedAt,
  });
}
