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
      return;
    } else if (status.isDenied) {
      return;
    } else if (status.isPermanentlyDenied) {
      return;
    }
  }
}
