import 'database_media.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../Model/media.dart';


class DatabaseHelper {
  String myBDD = 'maBDD3.db';

  Future<void> exportDatabase(BuildContext context) async {
    try {
      // Get the source database file
      String sourceDBPath = p.join(await getDatabasesPath(), myBDD);
      File sourceFile = File(sourceDBPath);

      // Get the downloads directory on Android
      String downloadsPath = '';
      if (Platform.isAndroid) {
        downloadsPath = '/storage/emulated/0/Download';
      }

      // Create the destination file in the downloads directory
      String destinationPath = p.join(downloadsPath, 'exported_database.db');
      File destinationFile = File(destinationPath);

      // Copy the source database file to the destination
      await sourceFile.copy(destinationPath);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database exported successfully')),
      );
    } catch (e) {
      print('Error exporting database: $e');
    }
  }
  
}
