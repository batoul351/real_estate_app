import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class CustomerSearchController extends GetxController {
  final storage = GetStorage();
  late final Dio dio;

  var isLoading = false.obs;
  var searchResults = <Map<String, dynamic>>[].obs;

  // ✅ فلاتر الباك فقط
  var selectedType = 'الكل'.obs; // property_type
  var selectedOfferType = 'الكل'.obs; // offer_type
  var selectedRegion = ''.obs; // region
  var minPrice = 0.obs; // min_price_sp
  var maxPrice = 1000000000.obs; // max_price_sp

  // ✅ متغيرات السعر بالدولار
  var minPriceUsd = 0.obs; // min_price_usd
  var maxPriceUsd = 100000.obs; // max_price_usd

  // ✅ القوائم المنسدلة
  var regionsList = <String>[].obs;
  var propertyTypesList = <String>[].obs;

  String get baseUrl => 'http://192.168.1.24:8000';

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

    fetchStats();
    search();
  }

  // ✅ البحث والفلترة
  Future<void> search() async {
    isLoading.value = true;
    try {
      final queryParams = <String, dynamic>{};

      // ========== 1. نوع العرض (offer_type) ==========
      if (selectedOfferType.value != 'الكل') {
        queryParams['offer_type'] = selectedOfferType.value;
      }

      // ========== 2. السعر بالليرة (min_price_sp / max_price_sp) ==========
      if (minPrice.value > 0) {
        queryParams['min_price_sp'] = minPrice.value;
      }
      if (maxPrice.value < 1000000000) {
        queryParams['max_price_sp'] = maxPrice.value;
      }

      // ========== 3. السعر بالدولار (min_price_usd / max_price_usd) ==========
      if (minPriceUsd.value > 0) {
        queryParams['min_price_usd'] = minPriceUsd.value;
      }
      if (maxPriceUsd.value < 100000) {
        queryParams['max_price_usd'] = maxPriceUsd.value;
      }

      // ========== 4. المنطقة (region) ==========
      if (selectedRegion.value.isNotEmpty && selectedRegion.value != 'الكل') {
        queryParams['region'] = selectedRegion.value;
      }

      // ========== 5. نوع العقار (property_type) ==========
      if (selectedType.value != 'الكل') {
        queryParams['property_type'] = selectedType.value;
      }

      print('📤 Query Params: $queryParams');

      final response = await dio.get(
        '/api/properties/browse',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        searchResults.value =
            List<Map<String, dynamic>>.from(response.data['data']);
        print('✅ تم العثور على ${searchResults.length} عقار');
      }
    } on DioException catch (e) {
      print('❌ Error searching: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('❌ Error searching: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ جلب الإحصائيات
  Future<void> fetchStats() async {
    try {
      final response = await dio.get('/api/properties/browse?per_page=1');
      if (response.statusCode == 200) {
        final stats = response.data['stats'];
        regionsList.value = List<String>.from(stats['regions'] ?? []);
        propertyTypesList.value =
            List<String>.from(stats['property_types'] ?? []);

        if (!regionsList.contains('الكل')) {
          regionsList.insert(0, 'الكل');
        }
        if (!propertyTypesList.contains('الكل')) {
          propertyTypesList.insert(0, 'الكل');
        }
      }
    } catch (e) {
      print('❌ Error fetching stats: $e');
    }
  }

  // ✅ الدوال المساعدة
  void setPropertyType(String type) {
    selectedType.value = type;
    search();
  }

  void setOfferType(String type) {
    selectedOfferType.value = type;
    search();
  }

  void setPriceRange(int min, int max) {
    minPrice.value = min;
    maxPrice.value = max;
    search();
  }

  // ✅ دالة السعر بالدولار
  void setPriceRangeUsd(int min, int max) {
    minPriceUsd.value = min;
    maxPriceUsd.value = max;
    search();
  }

  void setSelectedRegion(String region) {
    selectedRegion.value = region;
    search();
  }

  void resetFilters() {
    selectedType.value = 'الكل';
    selectedOfferType.value = 'الكل';
    selectedRegion.value = '';
    minPrice.value = 0;
    maxPrice.value = 1000000000;
    minPriceUsd.value = 0;
    maxPriceUsd.value = 100000;
    search();
  }

  Future<void> refreshSearch() async {
    await search();
  }

  @override
  void onClose() {
    dio.close();
    super.onClose();
  }
}
