import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeService extends GetxController {
  static ThemeService get to => Get.find();

  final isDark = true.obs;

  void toggleTheme() {
    isDark.value = !isDark.value;
  }

  ThemeMode get themeMode => isDark.value ? ThemeMode.dark : ThemeMode.light;

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xfff6f7fb),
    fontFamily: 'Cairo',
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xff070b18),
    fontFamily: 'Cairo',
  );
}
