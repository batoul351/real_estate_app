import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class RegisterController extends GetxController {
  final storage = GetStorage();
  final dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.106:8000',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  var loading = false.obs;
  var obscurePassword = true.obs;
  var obscureConfirm = true.obs;
  var selectedRole = 'owner'.obs;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmController = TextEditingController();

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleObscureConfirm() {
    obscureConfirm.value = !obscureConfirm.value;
  }

  void setRole(String role) {
    selectedRole.value = role;
  }

  Future<void> register() async {
    if (nameController.text.isEmpty) {
      _showMessage('الرجاء إدخال الاسم الكامل', isError: true);
      return;
    }
    if (phoneController.text.isEmpty) {
      _showMessage('الرجاء إدخال رقم الجوال', isError: true);
      return;
    }
    if (emailController.text.isEmpty) {
      _showMessage('الرجاء إدخال البريد الإلكتروني', isError: true);
      return;
    }
    if (passController.text.isEmpty) {
      _showMessage('الرجاء إدخال كلمة المرور', isError: true);
      return;
    }
    if (passController.text != confirmController.text) {
      _showMessage('كلمة المرور غير متطابقة', isError: true);
      return;
    }
    if (passController.text.length < 6) {
      _showMessage('كلمة المرور يجب أن تكون 6 أحرف على الأقل', isError: true);
      return;
    }

    loading.value = true;

    try {
      final response = await dio.post('/api/register', data: {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'role': selectedRole.value,
        'password': passController.text,
      });

      if (response.statusCode == 201) {
        _showMessage('تم إنشاء الحساب بنجاح. يرجى التحقق من بريدك الإلكتروني.');
        Get.toNamed('/verify', arguments: {
          'email': emailController.text.trim(),
        });
      } else {
        String errorMessage = response.data['message'] ?? 'فشل إنشاء الحساب';
        _showMessage(errorMessage, isError: true);
      }
    } on DioException catch (e) {
      String errorMessage = 'خطأ في الاتصال بالخادم';
      if (e.response != null && e.response!.data != null) {
        if (e.response!.data['errors'] != null) {
          errorMessage = e.response!.data['errors'].values.first[0];
        } else {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        }
      }
      _showMessage(errorMessage, isError: true);
    } finally {
      loading.value = false;
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    Get.snackbar(
      isError ? 'خطأ' : 'نجاح',
      msg,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}
