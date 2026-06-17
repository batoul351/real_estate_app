import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class ForgotPasswordController extends GetxController {
  final Dio dio = Get.find<Dio>(); // ✅ استخدام Dio من main

  final RxBool loading = false.obs;
  final RxBool codeSent = false.obs;
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxInt timerSeconds = 60.obs;
  final RxBool canResend = false.obs;

  late final TextEditingController emailController;
  late final TextEditingController codeController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    codeController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  void toggleNewPassword() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPassword() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void _startTimer() {
    timerSeconds.value = 60;
    canResend.value = false;

    Future.delayed(const Duration(seconds: 1), () {
      if (!isClosed) {
        if (timerSeconds.value > 0) {
          timerSeconds.value--;
          _startTimer();
        } else {
          canResend.value = true;
        }
      }
    });
  }

  Future<void> sendResetCode() async {
    if (emailController.text.isEmpty) {
      _showMessage('الرجاء إدخال البريد الإلكتروني', isError: true);
      return;
    }

    loading.value = true;

    try {
      final response = await dio.post('/api/forgot-password', data: {
        'email': emailController.text.trim(),
      });

      if (response.statusCode == 200) {
        _showMessage('تم إرسال رمز التحقق إلى بريدك الإلكتروني');
        codeSent.value = true;
        _startTimer();
      } else {
        _showMessage(response.data['message'] ?? 'فشل إرسال الرمز',
            isError: true);
      }
    } on DioException catch (e) {
      _showMessage(e.response?.data['message'] ?? 'خطأ في الاتصال',
          isError: true);
    } finally {
      loading.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (codeController.text.isEmpty) {
      _showMessage('الرجاء إدخال رمز التحقق', isError: true);
      return;
    }

    if (newPasswordController.text.isEmpty) {
      _showMessage('الرجاء إدخال كلمة المرور الجديدة', isError: true);
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showMessage('كلمة المرور غير متطابقة', isError: true);
      return;
    }

    if (newPasswordController.text.length < 6) {
      _showMessage('كلمة المرور يجب أن تكون 6 أحرف على الأقل', isError: true);
      return;
    }

    loading.value = true;

    try {
      final response = await dio.post('/api/reset-password', data: {
        'email': emailController.text.trim(),
        'code': codeController.text.trim(),
        'password': newPasswordController.text,
        'password_confirmation': confirmPasswordController.text,
      });

      if (response.statusCode == 200) {
        _showMessage('تم تغيير كلمة المرور بنجاح');
        Get.offAllNamed('/login');
      } else {
        _showMessage(response.data['message'] ?? 'فشل تغيير كلمة المرور',
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
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
