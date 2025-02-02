import 'dart:typed_data';
import 'package:intl/intl.dart';

class Media {
  int? id;
  String? nom;
  Uint8List? image; // Utilisez Uint8List pour stocker des données binaires
  int? note;
  String? statut;
  List<String>? genres;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? table;
  String? selectedImageUrl;

  Media({
    this.id,
    this.nom,
    this.image,
    this.note,
    this.statut,
    this.genres,
    this.createdAt,
    this.updatedAt,
    this.selectedImageUrl,
    this.table,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'image': image,
      'note': note,
      'statut': statut,
      'genres': genres?.join(', ') ?? "",
      'created_at': createdAt != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(createdAt!) : null,
      'updated_at': updatedAt != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(updatedAt!) : null,
    };
  }
}
