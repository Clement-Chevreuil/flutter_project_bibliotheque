import 'package:flutter_project_n1/data/models/saison.dart';

abstract class SaisonRepository {
  Future<int> insertSaison(Saison saison);
  Future<void> updateSaison(Saison saison);
  Future<void> deleteSaison(Saison saison);
  Future<Saison?> getSaison(int id);
  Future<List<Saison>> getAllSaisons(int idMedia, String table);
}
