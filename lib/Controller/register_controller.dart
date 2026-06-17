import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class RegisterController extends GetxController {
  final storage = GetStorage();
  final Dio dio = Get.find<Dio>(); // ✅ استخدام Dio من main

  var loading = false.obs;
  var obscurePassword = true.obs;
  var obscureConfirm = true.obs;
  var selectedRole = 'owner'.obs;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController passController;
  late final TextEditingController confirmController;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    passController = TextEditingController();
    confirmController = TextEditingController();
  }

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
        Get.toNamed('/verify',
            arguments: {'email': emailController.text.trim()});
      } else {
        _showMessage(response.data['message'] ?? 'فشل إنشاء الحساب',
            isError: true);
      }
    } on DioException catch (e) {
      _showMessage(e.response?.data['message'] ?? 'خطأ في الاتصال',
          isError: true);
    } finally {
      if (!isClosed) loading.value = false;
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (Get.context != null) {
      Get.snackbar(
        isError ? 'خطأ' : 'نجاح',
        msg,
        backgroundColor: isError ? Colors.red : Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
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
