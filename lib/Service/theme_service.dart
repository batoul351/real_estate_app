import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  static ThemeService get to => Get.find();

  final GetStorage _storage = GetStorage();
  final RxBool isDark = false.obs;

  // 🎨 الألوان الموحّدة للتطبيق
  static const Color primary = Color(0xff1E3A8A); // كحلي
  static const Color accent = Color(0xff0F766E); // تركوازي

  // Light
  static const Color lightBg = Color(0xffEEF2F7); // أوف-وايت رمادي دافي
  static const Color lightSurface = Color(0xffFFFFFF);
  static const Color lightText = Color(0xff0F172A);

  // Dark (مو أسود، كحلي متوسط)
  static const Color darkBg = Color(0xff101828);
  static const Color darkSurface = Color(0xff1A2233);
  static const Color darkText = Color(0xffE6EAF2);

  @override
  void onInit() {
    super.onInit();
    final savedTheme = _storage.read('isDark');
    if (savedTheme != null) {
      isDark.value = savedTheme as bool;
    }
  }

  void toggleTheme() {
    isDark.value = !isDark.value;
    _storage.write('isDark', isDark.value);
  }

  ThemeMode get themeMode => isDark.value ? ThemeMode.dark : ThemeMode.light;

  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBg,
        fontFamily: 'Cairo',
        primaryColor: primary,
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: accent,
          surface: lightSurface,
          onSurface: lightText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: lightText),
          titleTextStyle: TextStyle(
            color: lightText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xffE3E8F0), // رمادي فاتح بدل الأبيض
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        fontFamily: 'Cairo',
        primaryColor: primary,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: accent,
          surface: darkSurface,
          onSurface: darkText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: darkText),
          titleTextStyle: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
}
