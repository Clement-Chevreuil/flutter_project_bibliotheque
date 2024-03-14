import 'dart:typed_data';

class Media {
  int? id;
  String? nom;
  Uint8List? image;
  int? note;
  String? statut;
  List<String>? genres;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<int> saisonEpisode = [];

  Media({
    this.id,
    this.nom,
    this.image,
    this.note,
    this.statut,
    this.genres,
    this.createdAt,
    this.updatedAt,
  });

  void updateSaisonEpisode(List<int> saisonEpisode) {
    this.saisonEpisode = saisonEpisode;
  }
}
