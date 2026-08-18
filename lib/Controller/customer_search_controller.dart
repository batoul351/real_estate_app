import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class CustomerSearchController extends GetxController {
  final storage = GetStorage();
  late final Dio dio;

  var isLoading = false.obs;
  var searchResults = <Map<String, dynamic>>[].obs;

  // ✅ فلاتر الباك فقط
  var selectedType = 'الكل'.obs;
  var selectedOfferType = 'الكل'.obs;
  var selectedRegion = ''.obs;

  // ✅ متغيرات السعر (قيم منطقية)
  var minPrice = 0.obs;
  var maxPrice = 100000000.obs; // ← 100 مليون
  var minPriceUsd = 0.obs;
  var maxPriceUsd = 100000.obs; // ← 100 ألف

  // ✅ جديد: هل المستخدم فعليًا حرّك سلايدر السعر؟
  var isPriceSpFilterActive = false.obs; // ← أضف هذا
  var isPriceUsdFilterActive = false.obs; // ← أضف هذا

  // ✅ القوائم المنسدلة
  var regionsList = <String>[].obs;
  var propertyTypesList = <String>[].obs;

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

    fetchStats();
    search();
  }

  // ✅ البحث والفلترة
  Future<void> search() async {
    if (isLoading.value) {
      print('⏳ Search already in progress, skipping...');
      return;
    }

    isLoading.value = true;
    try {
      final queryParams = <String, dynamic>{};

      // ========== 1. نوع العرض ==========
      if (selectedOfferType.value != 'الكل') {
        queryParams['offer_type'] = selectedOfferType.value;
      }

      // ========== 2. السعر بالليرة ==========
      if (isPriceSpFilterActive.value) {
        queryParams['min_price_sp'] = minPrice.value;
        queryParams['max_price_sp'] = maxPrice.value;
      }

      // ========== 3. السعر بالدولار ==========
      if (isPriceUsdFilterActive.value) {
        queryParams['min_price_usd'] = minPriceUsd.value;
        queryParams['max_price_usd'] = maxPriceUsd.value;
      }

      // ========== 4. المنطقة ==========
      if (selectedRegion.value.isNotEmpty && selectedRegion.value != 'الكل') {
        queryParams['region'] = selectedRegion.value;
      }

      // ========== 5. نوع العقار ==========
      if (selectedType.value != 'الكل') {
        queryParams['property_type'] = selectedType.value;
      }

      print('📤 Query Params: $queryParams');

      final response = await dio.get(
        '/api/properties/browse',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        print('📊 Total: ${response.data['meta']['total']}');
        print('📊 Filtered: ${response.data['stats']['filtered']}');

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
      print('📊 Fetching stats...');
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
        print(
            '✅ Stats loaded: ${regionsList.length} regions, ${propertyTypesList.length} types');
      }
    } catch (e) {
      print('❌ Error fetching stats: $e');
    }
  }

  // ✅ الدوال المساعدة
  void setPropertyType(String type) {
    if (selectedType.value == type) return;
    selectedType.value = type;
    search();
  }

  void setOfferType(String type) {
    if (selectedOfferType.value == type) return;
    selectedOfferType.value = type;
    search();
  }

  void setPriceRange(int min, int max) {
    // ✅ التأكد من أن القيم ضمن النطاق
    min = min.clamp(0, 100000000);
    max = max.clamp(0, 100000000);

    // ✅ التأكد من أن min <= max
    if (min > max) {
      final temp = min;
      min = max;
      max = temp;
    }

    if (minPrice.value == min && maxPrice.value == max) return;
    minPrice.value = min;
    maxPrice.value = max;
    isPriceSpFilterActive.value = true; // ← تفعيل الفلتر
    search();
  }

  void setPriceRangeUsd(int min, int max) {
    // ✅ التأكد من أن القيم ضمن النطاق
    min = min.clamp(0, 100000);
    max = max.clamp(0, 100000);

    // ✅ التأكد من أن min <= max
    if (min > max) {
      final temp = min;
      min = max;
      max = temp;
    }

    if (minPriceUsd.value == min && maxPriceUsd.value == max) return;
    minPriceUsd.value = min;
    maxPriceUsd.value = max;
    isPriceUsdFilterActive.value = true; // ← تفعيل الفلتر
    search();
  }

  void setSelectedRegion(String region) {
    if (selectedRegion.value == region) return;
    selectedRegion.value = region;
    search();
  }

  void resetFilters() {
    selectedType.value = 'الكل';
    selectedOfferType.value = 'الكل';
    selectedRegion.value = '';
    minPrice.value = 0;
    maxPrice.value = 100000000;
    minPriceUsd.value = 0;
    maxPriceUsd.value = 100000;
    isPriceSpFilterActive.value = false; // ← إلغاء تفعيل الفلتر
    isPriceUsdFilterActive.value = false; // ← إلغاء تفعيل الفلتر
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
