import 'package:intl/intl.dart';

class Utilisateur {
  int? id;
  DateTime? createdAt;
  DateTime? updatedAt;

  Utilisateur({
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'created_at': createdAt != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(createdAt!) : null,
      'updated_at': updatedAt != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(updatedAt!) : null,
    };
  }
}
