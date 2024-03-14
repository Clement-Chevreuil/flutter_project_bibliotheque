class Genre {
  int? id;
  String? nom;
  String? media;

  Genre({
    this.id,
    this.nom,
    this.media,
  });

  Genre.withoutID({
    this.nom,
    this.media,
  });
}
