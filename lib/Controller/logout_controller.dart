import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class LogoutController extends GetxController {
  final storage = GetStorage();
  final dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.106:8000',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  var isLoading = false.obs;

  Future<void> logout() async {
    isLoading.value = true;

    try {
      final token = storage.read('access_token');
      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await dio.post('/api/logout');

      if (response.statusCode == 200) {
        await storage.remove('access_token');
        await storage.remove('user_data');
        _showMessage('تم تسجيل الخروج بنجاح');
        Get.offAllNamed('/login');
      } else {
        _showMessage('فشل تسجيل الخروج', isError: true);
      }
    } on DioException catch (e) {
      await storage.remove('access_token');
      await storage.remove('user_data');
      _showMessage('تم تسجيل الخروج', isError: false);
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    Get.snackbar(
      isError ? 'خطأ' : 'نجاح',
      msg,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
