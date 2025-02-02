import 'package:flutter/material.dart';
import 'package:flutter_project_n1/interfaces/home_page.dart';

class Routes {
  static const String home = '/home';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      default:
        return null;
    }
  }
}
