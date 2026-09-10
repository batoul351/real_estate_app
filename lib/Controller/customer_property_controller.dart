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

  // ✅ جلب جميع العقارات (للمالك/الشريك) أو عرض العقارات (للزبون)
  Future<void> fetchProperties() async {
    isLoading.value = true;
    try {
      final user = storage.read('user');
      final String? role = user != null ? user['role'] : null;

      // ✅ إذا كان المستخدم شريكاً أو مالكاً، استخدم /getproperties
      // وإلا استخدم /properties/browse للزبائن
      final bool isPartnerOrOwner = role == 'partner' || role == 'owner';

      final String endpoint =
          isPartnerOrOwner ? '/api/getproperties' : '/api/properties/browse';

      // ✅ التعديل الأساسي: إرسال per_page كبير حتى ما ترجع صفحة واحدة بس
      final Map<String, dynamic>? queryParams =
          isPartnerOrOwner ? null : {'per_page': 1000};

      print('📤 جلب العقارات من: $endpoint');
      print('👤 دور المستخدم: $role');
      print('📤 Query Params: $queryParams');

      final response = await dio.get(endpoint, queryParameters: queryParams);

      if (response.statusCode == 200) {
        // ✅ معالجة مختلفة حسب الـ API
        List<dynamic> data;
        if (isPartnerOrOwner) {
          // /getproperties يعيد properties
          data = response.data['properties'] ?? [];
        } else {
          // /properties/browse يعيد data
          data = response.data['data'] ?? [];
        }

        properties.value = List<Map<String, dynamic>>.from(data);

        // ✅ طباعة تشخيصية: العدد الكلي من الباك اند مقابل العدد المرجّع فعلياً
        final total = response.data['meta']?['total'] ??
            response.data['total'] ??
            'غير متوفر';
        print('📊 Total من الباك اند: $total');
        print('✅ تم جلب ${properties.length} عقار بهاد الطلب');

        // ✅ طباعة حالة العقارات للتأكد
        for (var p in properties) {
          print(
              '📌 ${p['title']} - الحالة: ${p['approval_status'] ?? 'غير محددة'}');
        }
      }
    } on DioException catch (e) {
      print('❌ Error fetching properties: ${e.response?.data ?? e.message}');
      // ✅ إذا فشل /getproperties، حاول /properties/browse
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
        print('🔄 محاولة جلب من /properties/browse...');
        try {
          final response = await dio.get(
            '/api/properties/browse',
            queryParameters: {'per_page': 1000},
          );
          if (response.statusCode == 200) {
            properties.value =
                List<Map<String, dynamic>>.from(response.data['data'] ?? []);
            print('✅ تم جلب ${properties.length} عقار من /properties/browse');
          }
        } catch (e2) {
          print('❌ فشل جلب العقارات: $e2');
        }
      }
    } catch (e) {
      print('❌ Error fetching properties: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ تحديث القائمة
  Future<void> refreshProperties() async {
    await fetchProperties();
  }

  // ✅ جلب تفاصيل عقار كاملة
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
