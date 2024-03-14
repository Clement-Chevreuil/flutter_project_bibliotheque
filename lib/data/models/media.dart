import 'dart:typed_data';
import 'package:intl/intl.dart';

class Media {
  int? id;
  String? nom;
  Uint8List? image; // Utilisez Uint8List pour stocker des données binaires
  int? note;
  String? statut;
  List<String>? genres;
  DateTime? created_at; 
  DateTime? updated_at; 

  List<int> saison_episode = [];

  Media({
    this.id,
    this.nom,
    this.image,
    this.note,
    this.statut,
    this.genres,
    this.created_at,
    this.updated_at,
  });

  void updateSaisonEpisode(List<int> saison_episode) 
  {
    this.saison_episode = saison_episode; 
  }

  

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'image': image,
      'note': note,
      'statut': statut,
      'genres': genres?.join(', ') ?? "",
      'created_at': created_at != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(created_at!) : null,
      'updated_at': updated_at != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(updated_at!) : null,
    };
  }
}
