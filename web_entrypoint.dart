import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/Service/theme_service.dart';
import 'package:real_estate/View/splash_screen.dart';

void main() {
  Get.put(ThemeService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.to;

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.lightTheme,
        darkTheme: theme.darkTheme,
        themeMode: theme.themeMode,
        home: const SplashScreen(),
      );
    });
  }
}