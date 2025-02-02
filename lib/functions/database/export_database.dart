import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

Future<void> exportDatabase(BuildContext context) async {
  String myBDD = 'maBDD3.db';
  try {
    String sourceDBPath = p.join(await getDatabasesPath(), myBDD);
    File sourceFile = File(sourceDBPath);

    String downloadsPath = '';
    if (Platform.isAndroid) {
      downloadsPath = '/storage/emulated/0/Download';
    }

    String destinationPath = p.join(downloadsPath, 'exported_database.db');

    await sourceFile.copy(destinationPath);

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Database exported successfully')),
    );
  } catch (e) {
    return;
  }
}
