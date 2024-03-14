import 'package:flutter_project_n1/presentation/pages/home_page.dart';
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

    return MaterialApp(
      title: 'OFLINE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomePage(),
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