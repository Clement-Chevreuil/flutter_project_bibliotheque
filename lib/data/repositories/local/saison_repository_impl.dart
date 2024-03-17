import 'package:flutter_project_n1/data/datasources/local/saison_data_source.dart';
import 'package:flutter_project_n1/data/models/saison.dart';
import 'package:flutter_project_n1/domain/repositories/saison_repository.dart';


class SaisonRepositoryImpl implements SaisonRepository{
  final SaisonDataSource _saisonDataSource;

  SaisonRepositoryImpl(this._saisonDataSource);

  Future<int> insertSaison(Saison saison) async {
    return await _saisonDataSource.insert(saison);
  }

  Future<void> updateSaison(Saison saison) async {
    await _saisonDataSource.update(saison);
  }

  Future<void> deleteSaison(Saison saison) async {
    await _saisonDataSource.delete(saison);
  }

  Future<Saison?> getSaison(int id) async {
    return await _saisonDataSource.get(id);
  }

  Future<List<Saison>> getAllSaisons(int idMedia, String table) async {
    return await _saisonDataSource.getAll(idMedia, table);
  }
}
