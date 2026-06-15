import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final GetStorage storage = GetStorage();
  final Dio dio = Get.find<Dio>();

  var loading = false.obs;
  var obscurePassword = true.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
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

        await storage.write('access_token', data['access_token']);
        await storage.write('user_data', data['user']);

        dio.options.headers['Authorization'] = 'Bearer ${data['access_token']}';

        _showMessage('تم تسجيل الدخول بنجاح');

        final String role = data['user']['role'].toString();

        switch (role) {
          case 'owner':
            Get.offAllNamed('/owner-home');
            break;
          case 'customer':
            Get.offAllNamed('/customer-home'); // ✅ customer يروح لشاشته
            break;
          case 'partner':
            Get.offAllNamed('/owner-home');
            break;
          case 'admin':
            Get.offAllNamed('/owner-home');
            break;
          default:
            _showMessage('دور المستخدم غير معروف: $role', isError: true);
        }
      } else {
        _showMessage(response.data['message'] ?? 'فشل تسجيل الدخول',
            isError: true);
      }
    } on DioException catch (e) {
      String errorMessage = 'خطأ في الاتصال بالخادم';
      if (e.response != null && e.response!.data != null) {
        if (e.response!.data is Map && e.response!.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        }
      }
      _showMessage(errorMessage, isError: true);
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      loading.value = false;
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    Get.snackbar(
      isError ? 'خطأ' : 'نجاح',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    emailController.clear();
    passController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailController.dispose();
      passController.dispose();
    });
    super.onClose();
  }
}
