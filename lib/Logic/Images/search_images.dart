import 'package:http/http.dart' as http;
import 'dart:convert';


class SearchImages {

  Future<List<String>?> searchImages(String searchTerm) async {
    List<String> imageUrls;
    final apiKey = 'AIzaSyCK0hAKBHu6fQhlKTOtBj2LbKNTuniLNmA';
    final cx = '40dc66ef904ad48c9';
    final apiUrl =
        'https://www.googleapis.com/customsearch/v1?q=$searchTerm&key=$apiKey&cx=$cx&num=10&searchType=image';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Récupérez le nombre total de résultats en tant qu'entier.
        final int totalResults =
            int.tryParse(responseData['searchInformation']['totalResults']) ??
                0;

        // Affichez le nombre total de résultats dans la console.
        print('Nombre total de résultats : $totalResults');

        // Récupérez les liens vers les images à partir de la réponse.
        final List<dynamic> items = responseData['items'];
        imageUrls = [];
        for (var item in items) {
          final imageUrl = item['link'];
          imageUrls.add(imageUrl);
          print(imageUrl);
        }
        return imageUrls;

      } else {
        // Gérez les erreurs de l'API ici.
        print('Erreur de l\'API : ${response.statusCode}');
        // Affichez un message d'erreur à l'utilisateur.
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Erreur de l\'API')),
        // );
        return null;
      }
    } catch (e) {
      // Gérez les erreurs de requête ici.
      print('Erreur de requête : $e');
      // Affichez un message d'erreur à l'utilisateur.
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Erreur de requête')),
      // );
      return null;
    }
  }
}