import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class CustomerFavoritesController extends GetxController {
  final storage = GetStorage();
  late final Dio dio;

  var isLoading = false.obs;
  var favorites = <Map<String, dynamic>>[].obs;
  var favoriteIds = <int>[].obs;

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

    fetchFavorites();
  }

  // ✅ جلب المفضلة
  Future<void> fetchFavorites() async {
    isLoading.value = true;
    try {
      final response = await dio.get('/api/favorites');
      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(response.data['data']);

        // 🛡️ نتجاهل أي عنصر العقار فيه null (محذوف من السيرفر) لمنع الكراش
        favorites.value = data.where((f) => f['property'] != null).toList();

        favoriteIds.value =
            favorites.map((f) => f['property']['id'] as int).toList();
      }
    } on DioException catch (e) {
      print('Error fetching favorites: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('Error fetching favorites: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ إضافة إلى المفضلة — برجع Map فيها success + message عشان تنعرض بالواجهة
  Future<Map<String, dynamic>> addToFavorites(int propertyId) async {
    try {
      final response = await dio.post('/api/favorites', data: {
        'property_id': propertyId,
      });

      if (response.statusCode == 200) {
        await fetchFavorites();
        return {
          'success': true,
          'message': response.data['message'] ?? 'تم الحفظ بنجاح',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'تعذرت إضافة العقار للمفضلة',
      };
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'حدث خطأ غير متوقع')
          : 'تعذر الاتصال بالسيرفر، تأكد من اتصالك بالإنترنت';
      print('Error adding to favorites: $message');
      return {'success': false, 'message': message};
    } catch (e) {
      print('Error adding to favorites: $e');
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  // ✅ حذف من المفضلة — برجع Map فيها success + message
  Future<Map<String, dynamic>> removeFromFavorites(int propertyId) async {
    try {
      final response = await dio.delete('/api/favorites/$propertyId');

      if (response.statusCode == 200) {
        await fetchFavorites();
        return {
          'success': true,
          'message': response.data['message'] ?? 'تم الحذف بنجاح',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'تعذر حذف العقار من المفضلة',
      };
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'حدث خطأ غير متوقع')
          : 'تعذر الاتصال بالسيرفر، تأكد من اتصالك بالإنترنت';
      print('Error removing from favorites: $message');
      return {'success': false, 'message': message};
    } catch (e) {
      print('Error removing from favorites: $e');
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  // ✅ التحقق من المفضلة
  bool isFavorite(int propertyId) {
    return favoriteIds.contains(propertyId);
  }

  // ✅ تحديث يدوي
  Future<void> refreshFavorites() async {
    await fetchFavorites();
  }

  @override
  void onClose() {
    dio.close();
    super.onClose();
  }
}
