import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class VerifyController extends GetxController {
  final storage = GetStorage();
  final Dio dio = Get.find<Dio>(); // ✅ استخدام Dio من main

  var loading = false.obs;
  var email = ''.obs;
  var timerSeconds = 60.obs;
  var canResend = false.obs;

  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;

  @override
  void onInit() {
    super.onInit();

    controllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());

    if (Get.arguments != null) {
      email.value = Get.arguments['email'] ?? '';
    }
    _startTimer();
  }

  void _startTimer() {
    timerSeconds.value = 60;
    canResend.value = false;
    _runTimer();
  }

  void _runTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!isClosed) {
        if (timerSeconds.value > 0) {
          timerSeconds.value--;
          _runTimer();
        } else {
          canResend.value = true;
        }
      }
    });
  }

  void nextField(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(Get.context!).requestFocus(focusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(Get.context!).requestFocus(focusNodes[index - 1]);
    }
  }

  String getOtpCode() {
    String code = '';
    for (var controller in controllers) {
      code += controller.text;
    }
    return code;
  }

  Future<void> verifyEmail() async {
    String code = getOtpCode();

    if (code.length != 6) {
      _showMessage('الرجاء إدخال رمز التحقق كاملاً', isError: true);
      return;
    }

    if (email.value.isEmpty) {
      _showMessage('البريد الإلكتروني غير موجود', isError: true);
      return;
    }

    loading.value = true;

    try {
      final response = await dio.post('/api/verify-email', data: {
        'email': email.value,
        'code': code,
      });

      if (response.statusCode == 200) {
        final data = response.data;

        await storage.write('access_token', data['access_token']);
        await storage.write('user_data', data['user']);

        dio.options.headers['Authorization'] = 'Bearer ${data['access_token']}';

        _showMessage('تم تفعيل الحساب بنجاح');

        final String role = data['user']['role'];
        if (role == 'owner') {
          Get.offAllNamed('/owner-home');
        } else {
          Get.offAllNamed('/owner-home');
        }
      } else {
        _showMessage(response.data['message'] ?? 'رمز التحقق غير صحيح',
            isError: true);
      }
    } on DioException catch (e) {
      _showMessage(e.response?.data['message'] ?? 'خطأ في الاتصال',
          isError: true);
    } finally {
      if (!isClosed) loading.value = false;
    }
  }

  Future<void> resendCode() async {
    if (!canResend.value) {
      _showMessage('الرجاء الانتظار ${timerSeconds.value} ثانية',
          isError: true);
      return;
    }

    if (email.value.isEmpty) return;

    loading.value = true;

    try {
      final response = await dio.post('/api/forgot-password', data: {
        'email': email.value,
      });

      if (response.statusCode == 200) {
        _showMessage('تم إعادة إرسال رمز التحقق');
        timerSeconds.value = 60;
        canResend.value = false;
        _runTimer();

        for (var controller in controllers) {
          controller.clear();
        }
        if (Get.context != null) {
          FocusScope.of(Get.context!).requestFocus(focusNodes[0]);
        }
      } else {
        _showMessage('فشل إعادة الإرسال', isError: true);
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
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
