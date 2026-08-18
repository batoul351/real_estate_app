import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class CustomerPropertyController extends GetxController {
  final storage = GetStorage();
  late final Dio dio;

  var isLoading = false.obs;
  var properties = <Map<String, dynamic>>[].obs;

  String get baseUrl => 'https://api-havensyria.softup.agency';

  @override
  void onInit() {
    super.onInit();
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    final token = storage.read('access_token');
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    fetchProperties();
  }

  // ✅ جلب العقارات
  Future<void> fetchProperties() async {
    isLoading.value = true;
    try {
      final response = await dio.get('/api/properties/browse');
      if (response.statusCode == 200) {
        properties.value =
            List<Map<String, dynamic>>.from(response.data['data']);
      }
    } on DioException catch (e) {
      print('Error fetching properties: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('Error fetching properties: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ جلب تفاصيل عقار كاملة (مستخدمة من PropertyDetailsScreen)
  Future<Map<String, dynamic>?> getPropertyDetails(int id) async {
    try {
      final response = await dio.get('/api/detailes/$id');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } on DioException catch (e) {
      print(
          'Error fetching property details: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      print('Error fetching property details: $e');
      return null;
    }
  }

  @override
  void onClose() {
    dio.close();
    super.onClose();
  }
}
