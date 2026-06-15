import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'Service/theme_service.dart';
import 'View/splash_screen.dart';
import 'View/auth/owner_login_screen.dart';
import 'View/auth/register_screen.dart';
import 'View/auth/verify_account_screen.dart';
import 'View/auth/forgot_password_screen.dart';
import 'View/owner/owner_home_screen.dart';
import 'View/customer/customer_home_screen.dart';
import 'controller/login_controller.dart';
import 'controller/forgot_password_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.106:8000',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final storage = GetStorage();
        final token = storage.read('access_token');
        if (token != null && token.toString().isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  Get.put<Dio>(dio, permanent: true);
  Get.put<ThemeService>(ThemeService(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService theme = Get.find<ThemeService>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Haven Syria',
        theme: theme.lightTheme,
        darkTheme: theme.darkTheme,
        themeMode: theme.themeMode,
        initialRoute: '/splash',
        defaultTransition: Transition.fadeIn,
        getPages: [
          GetPage(
            name: '/splash',
            page: () => const SplashScreen(),
          ),
          GetPage(
            name: '/login',
            page: () => const LoginScreen(),
            // ✅ lazyPut مع fenix حتى يُعاد الإنشاء تلقائياً بعد الحذف
            binding: BindingsBuilder(() {
              Get.lazyPut<LoginController>(
                () => LoginController(),
                fenix: true,
              );
            }),
          ),
          GetPage(
            name: '/register',
            page: () => const RegisterScreen(),
          ),
          GetPage(
            name: '/verify',
            page: () => const VerifyAccountScreen(),
          ),
          GetPage(
            name: '/forgot-password',
            page: () => const ForgotPasswordScreen(),
            // ✅ lazyPut مع fenix
            binding: BindingsBuilder(() {
              Get.lazyPut<ForgotPasswordController>(
                () => ForgotPasswordController(),
                fenix: true,
              );
            }),
          ),
          GetPage(
            name: '/owner-home',
            page: () => const OwnerHomeScreen(),
          ),
          GetPage(
            name: '/customer-home',
            page: () => const CustomerHomeScreen(),
          ),
        ],
      ),
    );
  }
}
