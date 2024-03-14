import 'dart:typed_data';

class Saison {
  int? id;
  int? idMedia;
  String? media;
  String? nom;
  Uint8List? image;
  int? note;
  String? statut;
  String? description;
  String? avis;
  DateTime? createdAt;
  DateTime? updatedAt;

  Saison({
    this.id,
    this.idMedia,
    this.media,
    this.nom,
    this.image,
    this.note,
    this.statut,
    this.description,
    this.avis,
    this.createdAt,
    this.updatedAt,
  });

  Saison.withoutId({
    this.idMedia,
    this.media,
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
