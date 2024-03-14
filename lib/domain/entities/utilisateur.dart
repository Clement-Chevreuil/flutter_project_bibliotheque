import 'package:intl/intl.dart';

class Utilisateur {
  int? id;
  int? episode;
  int? saison;
  DateTime? createdAt;
  DateTime? updatedAt;

  Utilisateur({
    this.id,
    this.episode,
    this.saison,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'episode': episode,
      'saison': saison,
      'created_at': createdAt != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(createdAt!) : null,
      'updated_at': updatedAt != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(updatedAt!) : null,
    };
  }
}
