class Genre {
  int? id;
  String? nom;
  String? media; // Utilisez Uint8List pour stocker des données binaires

  Genre({
    this.id,
    this.nom,
    this.media,
  });

  Genre.withoutID({
    this.nom,
    this.media,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'media': media,
    };
  }
}
