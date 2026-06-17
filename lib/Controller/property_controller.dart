import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';

class PropertyController extends GetxController {
  final storage = GetStorage();
  late final dio.Dio _dio;

  var isLoading = false.obs;
  var offices = <Map<String, dynamic>>[].obs;
  var properties = <Map<String, dynamic>>[].obs;

  // ✅ استخدم نفس الرابط المستخدم في main.dart
  String get baseUrl => 'http://192.168.1.24:8000'; // ✅ تم التعديل

  @override
  void onInit() {
    super.onInit();

    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ));

    final token = storage.read('access_token');
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }

    fetchOffices();
    fetchMyProperties();
  }

  Future<void> fetchOffices() async {
    try {
      final response = await _dio.get('/api/offices');
      if (response.statusCode == 200) {
        offices.value =
            List<Map<String, dynamic>>.from(response.data['offices']);
      }
    } catch (e) {
      print('Error fetching offices: $e');
    }
  }

  Future<void> fetchMyProperties() async {
    isLoading.value = true;
    try {
      final response = await _dio.get('/api/getproperties');
      if (response.statusCode == 200) {
        properties.value = List<Map<String, dynamic>>.from(
          response.data['properties'] ?? [],
        );
        if (properties.isNotEmpty) {
          print('📦 عدد العقارات: ${properties.length}');
          print('📦 أول عقار: ${properties.first}');
          print('🔑 المفاتيح: ${properties.first.keys}');
        }
      }
    } catch (e) {
      print('Error fetching properties: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addProperty({
    required String title,
    required String description,
    required String priceSp,
    required String priceUsd,
    required String propertyType,
    required String offerType,
    required String region,
    required int area,
    required int roomsCount,
    required int floorNumber,
    required String officeId,
    required List<File> images,
    required bool isFurnished,
    required String addressDetails,
    String? rentPeriod,
    String? locationGps,
  }) async {
    isLoading.value = true;

    try {
      final formData = dio.FormData.fromMap({
        'title': title,
        'description': description,
        'region': region,
        'property_type': propertyType,
        'offer_type': offerType,
        'area': area,
        'rooms_count': roomsCount,
        'floor_number': floorNumber,
        'office_id': officeId,
        'is_furnished': isFurnished ? 1 : 0,
        if (priceSp.isNotEmpty) 'price_sp': priceSp,
        if (priceUsd.isNotEmpty) 'price_usd': priceUsd,
        if (addressDetails.isNotEmpty) 'address_details': addressDetails,
        if (rentPeriod != null) 'rent_period': rentPeriod,
        if (locationGps != null) 'location_gps': locationGps,
      });

      for (var i = 0; i < images.length; i++) {
        final multipartFile = await dio.MultipartFile.fromFile(
          images[i].path,
          filename: 'image_$i.jpg',
        );
        formData.files.add(MapEntry('images[$i]', multipartFile));
      }

      final response = await _dio.post('/api/properties', data: formData);

      if (response.statusCode == 201) {
        _showMessage(response.data['message'] ?? 'تم إضافة العقار بنجاح',
            isError: false);
        await Future.delayed(const Duration(seconds: 1));
        await fetchMyProperties();
        return true;
      } else {
        _showMessage(response.data['message'] ?? 'فشل إضافة العقار',
            isError: true);
        return false;
      }
    } on dio.DioException catch (e) {
      _showMessage(_handleError(e), isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _handleError(dio.DioException e) {
    if (e.response != null && e.response!.data != null) {
      if (e.response!.data['errors'] != null) {
        return e.response!.data['errors'].values.first[0];
      } else {
        return e.response!.data['message'] ?? 'خطأ في الاتصال';
      }
    }
    return 'خطأ في الاتصال بالخادم';
  }

  void _showMessage(String msg, {required bool isError}) {
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
