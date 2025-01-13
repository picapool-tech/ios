import 'package:flutter/material.dart';

ThemeData appTheme = ThemeData(
  // Define colors based on the theme
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFFF8D41), // Primary
    secondary: Color(0xFF6E6CDF), // Secondary
    surface: Color(0xFFFFFFFF), // Base White for cards/surfaces
    onPrimary: Color(0xFFFFFFFF), // Text/icons on primary
    onSecondary: Color(0xFFFFFFFF), // Text/icons on secondary
    onSurface: Color(0xFF222222), // Text/icons on white
    error: Color(0xFFFF4C51), // Error
    onError: Color(0xFFFFFFFF), // Text/icons on error
  ),

  // Primary colors
  primaryColor: const Color(0xFFFF8D41), // Primary
  secondaryHeaderColor: const Color(0xFF6E6CDF), // Secondary

  // Backgrounds
  scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Base White
  cardColor: const Color(0xFFFFFFFF), // Cards with Base White

  // Buttons
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFFFF8D41), // Button background
    disabledColor: Color(0xFF8A8D93), // Disabled button
    textTheme: ButtonTextTheme.primary, // Text color for buttons
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF8D41), // Button color
      foregroundColor: const Color(0xFFFFFFFF), // Text/icons on button
      disabledBackgroundColor: const Color(0xFF8A8D93), // Disabled button
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),

  // Text
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
        fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
    titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
    bodyLarge: TextStyle(fontSize: 14, color: Color(0xFF222222)),
    bodyMedium: TextStyle(
      fontSize: 12,
      color: Colors.black,
    ), // Disabled or secondary text
  ),

  // AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFF8D41), // Primary
    titleTextStyle: TextStyle(
        color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.bold),
    iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
  ),

  // Alerts (Snackbars, Dialogs, etc.)
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFFFF4C51), // Error
    contentTextStyle: TextStyle(color: Color(0xFFFFFFFF)),
  ),

  // Input Fields
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFFFFFFF),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF8A8D93)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFFF8D41)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFFF4C51)),
    ),
  ),
);
