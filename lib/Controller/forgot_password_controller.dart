import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:async';

class ForgotPasswordController extends GetxController {
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.106:8000',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  final RxBool loading = false.obs;
  final RxBool codeSent = false.obs;
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxInt timerSeconds = 60.obs;
  final RxBool canResend = false.obs;
  Timer? _timer;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void toggleNewPassword() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPassword() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void _startTimer() {
    _timer?.cancel();
    timerSeconds.value = 60;
    canResend.value = false;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (timerSeconds.value > 0) {
          timerSeconds.value--;
        } else {
          canResend.value = true;
          timer.cancel();
        }
      },
    );
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

      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        _showMessage('تم إرسال رمز التحقق إلى بريدك الإلكتروني');
        codeSent.value = true;
        _startTimer();
      } else {
        String errorMessage = response.data['message'] ?? 'فشل إرسال الرمز';
        _showMessage(errorMessage, isError: true);
      }
    } on DioException catch (e) {
      print('Error: ${e.message}');
      String errorMessage = 'خطأ في الاتصال بالخادم';
      if (e.response != null && e.response!.data != null) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      _showMessage(errorMessage, isError: true);
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
        Get.back(); // ✅ ارجع لصفحة Login بدلاً من offAllNamed
      } else {
        String error = response.data['message'] ?? 'فشل تغيير كلمة المرور';
        _showMessage(error, isError: true);
      }
    } on DioException catch (e) {
      _showMessage('خطأ في الاتصال بالخادم', isError: true);
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
    _timer?.cancel();

    // ✅ امسح النصوص أولاً
    emailController.clear();
    codeController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();

    // ✅ أخّر الـ dispose حتى تنتهي Flutter من الـ render cycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailController.dispose();
      codeController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    });

    super.onClose();
  }
}
