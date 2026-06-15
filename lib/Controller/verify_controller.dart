import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class VerifyController extends GetxController {
  final storage = GetStorage();
  final dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.106:8000',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  var loading = false.obs;
  var email = ''.obs;
  var timerSeconds = 60.obs;
  var canResend = false.obs;

  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      email.value = Get.arguments['email'] ?? '';
    }
    _startTimer();
  }

  void _startTimer() {
    timerSeconds.value = 60;
    canResend.value = false;
    Future.delayed(const Duration(seconds: 1), () {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
        _startTimer();
      } else {
        canResend.value = true;
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
        _showMessage(response.data['message'] ?? 'رمز التحقق غير صحيح',
            isError: true);
      }
    } on DioException catch (e) {
      String errorMessage = 'خطأ في الاتصال بالخادم';
      if (e.response != null && e.response!.data != null) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      _showMessage(errorMessage, isError: true);
    } finally {
      loading.value = false;
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
        _startTimer();

        for (var controller in controllers) {
          controller.clear();
        }
        FocusScope.of(Get.context!).requestFocus(focusNodes[0]);
      } else {
        _showMessage('فشل إعادة الإرسال', isError: true);
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
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
