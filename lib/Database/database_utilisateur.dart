import 'package:flutter_project_n1/Model/utilisateur.dart';

import '../Model/media.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_init.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

class DatabaseUtilisateur {
  DatabaseUtilisateur();

  static Database? _database;
  final dbProvider = DatabaseInit.database;

  //CRUD


}
