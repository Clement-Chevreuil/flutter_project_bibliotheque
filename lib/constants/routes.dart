import 'package:flutter/material.dart';
import 'package:flutter_project_n1/interfaces/genres_view.dart';
import 'package:flutter_project_n1/interfaces/home_view.dart';
import 'package:flutter_project_n1/interfaces/media_create_view.dart';

class Routes {
  static const String home = '/home';
  static const String mediaCreate = '/media_create';
  static const String genres = '/genres';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case mediaCreate:
        return MaterialPageRoute(builder: (_) => const MediaCreateView());
      case genres:
        return MaterialPageRoute(builder: (_) => GenresView());
      default:
        return null;
    }
  }
}
