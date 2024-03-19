import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;


  Future<void> exportDatabase(BuildContext context) async {
    String myBDD = 'maBDD3.db';
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
