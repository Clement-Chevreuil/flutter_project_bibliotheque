import 'package:file_picker/file_picker.dart';
import 'package:flutter_project_n1/Database/database_init.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

Future replaceDatabase(DatabaseInit databaseInit) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      final file = File(result.files.single.path!);

      String sourceDBPath = p.join(await getDatabasesPath(), "maBDD2.db");
      File sourceFile = File(sourceDBPath);

      if (await sourceFile.exists()) {
        await sourceFile.delete();
      }

      databaseInit.closeDatabase();
      final appDirectory = await getDatabasesPath();
      final databasePath = '$appDirectory/maBDD3.db';
      await file.copy(databasePath);
      databaseInit.initDatabase("maBDD3.db");
      //loadMedia();

      return sourceFile.path;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
