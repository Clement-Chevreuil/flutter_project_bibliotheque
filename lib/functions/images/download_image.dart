import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<Uint8List?> downloadImage(String imageUrl) async {
  Uint8List? imageBytes;
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final imageBytes2 = response.bodyBytes;
      imageBytes = Uint8List.fromList(imageBytes2);
      return imageBytes;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
