import 'package:flutter/material.dart';
import 'package:flutter_project_n1/constants/app_colors.dart';
import 'package:flutter_project_n1/constants/app_consts.dart';

class AppThemeLight {
  static ThemeData buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateColor.resolveWith((states) {
            return AppColor.primaryLight1;
          }),
          shape: WidgetStateProperty.resolveWith((states) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConsts.standardRadius),
            );
          }),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColor.primaryLight1),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        labelStyle: const TextStyle(color: Colors.blue),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      textTheme: lightTextTheme,
      scaffoldBackgroundColor: AppColor.background,
    );
  }
}

TextTheme lightTextTheme = const TextTheme(
  displayLarge: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 57,
    fontWeight: FontWeight.bold,
    color: AppColor.primaryDark1, // Utilise primary_dark_1
  ),
  displayMedium: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 45,
    fontWeight: FontWeight.bold,
    color: AppColor.primaryDark2, // Utilise primary_dark_2
  ),
  displaySmall: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColor.primaryDark3, // Utilise primary_dark_3
  ),
  headlineLarge: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 32,
    fontWeight: FontWeight.w600, // Semi-bold
    color: AppColor.primaryDark4, // Utilise primary_dark_4
  ),
  headlineMedium: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColor.primaryDark5, // Utilise primary_dark_5
  ),
  headlineSmall: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColor.primaryDark6, // Utilise primary_dark_6
  ),
  titleLarge: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 22,
    fontWeight: FontWeight.w500, // Medium
    color: AppColor.primaryDark1, // Utilise primary_dark_1
  ),
  titleMedium: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColor.primaryDark2, // Utilise primary_dark_2
  ),
  titleSmall: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColor.primaryDark3, // Utilise primary_dark_3
  ),
  bodyLarge: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 16,
    fontWeight: FontWeight.normal, // Regular
    color: AppColor.primaryDark4, // Utilise primary_dark_4
  ),
  bodyMedium: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColor.primaryDark5, // Utilise primary_dark_5
  ),
  bodySmall: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColor.primaryDark6, // Utilise primary_dark_6
  ),
  labelLarge: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    color: AppColor.primaryLight6, // Utilise primary_light_6
  ),
  labelMedium: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColor.primaryLight5, // Utilise primary_light_5
  ),
  labelSmall: TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColor.primaryLight4, // Utilise primary_light_4
  ),
);
