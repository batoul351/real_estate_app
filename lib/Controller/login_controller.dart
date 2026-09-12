import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final GetStorage storage = GetStorage();
  late final Dio dio;

  var loading = false.obs;
  var obscurePassword = true.obs;

  late final TextEditingController emailController;
  late final TextEditingController passController;

  @override
  void onInit() {
    super.onInit();

    emailController = TextEditingController();
    passController = TextEditingController();

    try {
      dio = Get.find<Dio>();
    } catch (e) {
      dio = Dio(BaseOptions(
        baseUrl: 'https://api-havensyria.softup.agency',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ));
    }

    final token = storage.read('access_token');
    if (token != null && token.toString().isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  void toggleObscure() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passController.text.trim().isEmpty) {
      _showMessage('الرجاء إدخال البريد الإلكتروني وكلمة المرور',
          isError: true);
      return;
    }

    loading.value = true;

    try {
      final response = await dio.post('/api/login', data: {
        'email': emailController.text.trim(),
        'password': passController.text.trim(),
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final String role = (data['user']?['role'] ?? '').toString();

        // ✅ نتحقق من الدور أولاً قبل ما نقرر شو الرسالة ووين نوجه
        if (role == 'owner') {
          await storage.write('access_token', data['access_token']);
          await storage.write('user_data', data['user']);
          dio.options.headers['Authorization'] =
              'Bearer ${data['access_token']}';

          _showMessage('تم تسجيل الدخول بنجاح');
          Get.offAllNamed('/owner-home');
        } else if (role == 'customer') {
          await storage.write('access_token', data['access_token']);
          await storage.write('user_data', data['user']);
          dio.options.headers['Authorization'] =
              'Bearer ${data['access_token']}';

          _showMessage('تم تسجيل الدخول بنجاح');
          Get.offAllNamed('/customer-home');
        } else if (role == 'admin' || role == 'partner') {
          // ❌ هذا الحساب ليس له واجهة داخل التطبيق، لا نخزّن التوكن ولا نعرض نجاح
          await storage.remove('access_token');
          await storage.remove('user_data');
          dio.options.headers.remove('Authorization');

          _showMessage(
            'هذا الحساب مخصص للوحة التحكم على الموقع، يرجى تسجيل الدخول من هناك',
            isError: true,
          );
        } else {
          // ❌ دور غير معروف بالكامل
          await storage.remove('access_token');
          await storage.remove('user_data');
          dio.options.headers.remove('Authorization');

          _showMessage('نوع الحساب غير مدعوم، تواصل مع الدعم', isError: true);
        }
      } else {
        _showMessage('فشل تسجيل الدخول، حاول مرة أخرى', isError: true);
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'خطأ في الاتصال، تحقق من الإنترنت')
          : 'خطأ في الاتصال، تحقق من الإنترنت';
      _showMessage(message, isError: true);
    } catch (e) {
      _showMessage('حدث خطأ غير متوقع، حاول مرة أخرى', isError: true);
    } finally {
      loading.value = false;
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (Get.context != null) {
      Get.snackbar(
        isError ? 'خطأ' : 'نجاح',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isError ? Colors.red : Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    // ✅ لا تتلف الـ Controllers هنا
    super.onClose();
  }
}
