import 'package:flutter_project_n1/domain/repositories/saison_repository.dart';

import '../datasources/database_saison.dart';
import '../models/saison.dart';

class SaisonRepositoryImpl implements SaisonRepository{
  final DatabaseSaison databaseSaison;

  SaisonRepositoryImpl(this.databaseSaison);

  Future<int> insertSaison(Saison saison) async {
    return await databaseSaison.insert(saison);
  }

  Future<void> updateSaison(Saison saison) async {
    await databaseSaison.update(saison);
  }

  Future<void> deleteSaison(Saison saison) async {
    await databaseSaison.delete(saison);
  }

  Future<Saison?> getSaison(int id) async {
    return await databaseSaison.get(id);
  }

  Future<List<Saison>> getAllSaisons(int idMedia, String table) async {
    return await databaseSaison.getAll(idMedia, table);
  }
}
