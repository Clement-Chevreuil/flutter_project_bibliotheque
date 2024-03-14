import 'dart:typed_data';
import 'package:intl/intl.dart';

class Saison {

  int? id;
  int? id_media;
  String? media;
  String? nom;
  Uint8List? image; // Utilisez Uint8List pour stocker des données binaires
  int? note;
  String? statut;
  String? description;
  String? avis;
  DateTime? created_at; 
  DateTime? updated_at; 

  Saison({
    this.id,
    this.id_media,
    this.media,
    this.nom,
    this.image,
    this.note,
    this.statut,
    this.description,
    this.avis,
    this.created_at,
    this.updated_at,
  });

    Saison.withoutId({
    this.id_media,
    this.media,
    this.nom,
    this.image,
    this.note,
    this.statut,
    this.description,
    this.avis,
    this.created_at,
    this.updated_at,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_media': id_media,
      'media': media,
      'nom': nom,
      'image': image,
      'note': note,
      'statut': statut,
      'avis': avis,
      'description': description,
      'created_at': created_at != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(created_at!) : null,
      'updated_at': updated_at != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(updated_at!) : null,
    };
  }
}
