import 'package:intl/intl.dart';

class Utilisateur {

  int? id;
  int? episode;
  int? saison;
  DateTime? created_at; 
  DateTime? updated_at; 

  Utilisateur({
    this.id,
    this.episode,
    this.saison,
    this.created_at,
    this.updated_at,
  });

  Map<String, dynamic> toMap() {
    return {
      'episode': episode,
      'saison': saison,
      'created_at': created_at != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(created_at!) : null,
      'updated_at': updated_at != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(updated_at!) : null,
    };
  }
}
