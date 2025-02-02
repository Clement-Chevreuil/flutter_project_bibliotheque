import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>?> searchImages(String searchTerm) async {
  List<String> imageUrls;
  await dotenv.load();
  String? apiKey = dotenv.env['GOOGLE_API_KEY'];
  const cx = '40dc66ef904ad48c9';
  final apiUrl = 'https://www.googleapis.com/customsearch/v1?q=$searchTerm&key=$apiKey&cx=$cx&num=10&searchType=image';
  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> items = responseData['items'];
      imageUrls = [];
      for (var item in items) {
        final imageUrl = item['link'];
        imageUrls.add(imageUrl);
      }
      return imageUrls;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
