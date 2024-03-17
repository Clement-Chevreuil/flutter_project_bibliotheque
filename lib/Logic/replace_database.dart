import 'package:file_picker/file_picker.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class ReplaceDatabse
{
  static Future replaceDatabase(DatabaseInit databaseInit) async {
    try {
      // Sélectionner un fichier depuis l'appareil
      FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null) {
        // Récupérer le fichier sélectionné
        final file = File(result.files.single.path!);

        String sourceDBPath = p.join(await getDatabasesPath(), "maBDD2.db");
        File sourceFile = File(sourceDBPath);

        // Supprimer l'ancien fichier de base de données s'il existe
        if (await sourceFile.exists()) {
          await sourceFile.delete();
        }

        databaseInit.closeDatabase();
        final appDirectory = await getDatabasesPath();
        final databasePath =
            '${appDirectory}/maBDD3.db'; // Changement de nom ici
        await file.copy(databasePath);
        databaseInit.initDatabase("maBDD3.db");
        //loadMedia();

        return sourceFile.path;
      } else {
        // L'utilisateur a annulé la sélection du fichier
        return null;
      }
    } catch (e) {
      print(e);
      // Gérer l'erreur de remplacement du fichier de base de données
      return null;
    }
  }
}

