import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class ProfileController extends GetxController {
  final storage = GetStorage();
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api-havensyria.softup.agency',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  var isLoading = false.obs;
  var isUpdating = false.obs;

  // بيانات المستخدم
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhone = ''.obs;
  var userRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // إضافة التوكن من التخزين
    final token = storage.read('access_token');
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    fetchProfile();
  }

  // جلب بيانات البروفايل من API
  Future<void> fetchProfile() async {
    isLoading.value = true;

    try {
      final response = await dio.get('/api/profile');

      if (response.statusCode == 200) {
        final user = response.data['user'];

        userName.value = user['name'] ?? '';
        userEmail.value = user['email'] ?? '';
        userPhone.value = user['phone_number'] ?? '';
        userRole.value = user['role'] ?? '';

        // حفظ في التخزين المحلي
        await storage.write('user_data', user);
      } else {
        _showMessage('فشل تحميل البيانات', isError: true);
      }
    } on DioException catch (e) {
      _showMessage('خطأ في الاتصال', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // تحديث بيانات البروفايل
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    isUpdating.value = true;

    try {
      final response = await dio.put('/api/profile', data: {
        'name': name,
        'email': email,
        'phone_number': phone,
      });

      if (response.statusCode == 200) {
        final user = response.data['user'];

        userName.value = user['name'] ?? '';
        userEmail.value = user['email'] ?? '';
        userPhone.value = user['phone_number'] ?? '';

        await storage.write('user_data', user);

        _showMessage('تم تحديث البيانات بنجاح');
        Get.back(); // العودة للشاشة السابقة
      } else {
        _showMessage('فشل تحديث البيانات', isError: true);
      }
    } on DioException catch (e) {
      String error = 'خطأ في الاتصال';
      if (e.response != null && e.response!.data != null) {
        if (e.response!.data['errors'] != null) {
          error = e.response!.data['errors'].values.first[0];
        } else {
          error = e.response!.data['message'] ?? error;
        }
      }
      _showMessage(error, isError: true);
    } finally {
      isUpdating.value = false;
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
}
