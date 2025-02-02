import 'package:flutter_project_n1/constants/app_theme_light.dart';
import 'package:flutter_project_n1/constants/route.dart';
import 'package:flutter_project_n1/providers/media_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    requestStoragePermission();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MediaProvider>(create: (_) => MediaProvider()),
      ],
      child: MaterialApp(
        title: 'OFLINE',
        theme: AppThemeLight.buildLightTheme(),
        darkTheme: AppThemeLight.buildLightTheme(),
        themeMode: ThemeMode.system,
        initialRoute: Routes.home,
        onGenerateRoute: Routes.generateRoute,
      ),
    );
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      print("Permission accordée");
      // L'autorisation est accordée, vous pouvez maintenant effectuer des opérations de stockage
    } else if (status.isDenied) {
      print("Permission refusée");
      // L'utilisateur a refusé l'autorisation. Vous pouvez lui expliquer pourquoi cette autorisation est nécessaire et redemander.
    } else if (status.isPermanentlyDenied) {
      print("Permission définitivement refusée");
      // L'utilisateur a définitivement refusé l'autorisation. Vous pouvez l'inviter à ouvrir les paramètres de l'application pour activer manuellement l'autorisation.
    }
  }
}
