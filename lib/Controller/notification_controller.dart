import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../model/owner_notification_model.dart';

class NotificationController extends GetxController {
  // جلب نسخة الـ Dio الجاهزة من الـ main
  final Dio _dio = Get.find<Dio>();

  var notifications = <OwnerNotificationModel>[].obs;
  var isLoading = false.obs;
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  // دالة جلب الإشعارات من السيرفر
  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      // الرابط يضاف تلقائياً للـ BaseUrl الموجود في الـ main
      final response = await _dio.get('/api/notifications');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List rawData = response.data['data'];
        notifications.assignAll(
          rawData.map((json) => OwnerNotificationModel.fromJson(json)).toList(),
        );
        // تحديث عداد الإشعارات غير المقروءة من قيمة السيرفر
        unreadCount.value = response.data['unread_count'] ?? 0;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل الإشعارات: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // دالة تحويل إشعار واحد لمقروء
  Future<void> markAsRead(String notificationId, int index) async {
    // إذا كان مقروءاً مسبقاً لا داعي لإرسال طلب للسيرفر
    if (notifications[index].isRead) return;

    try {
      final response =
          await _dio.put('/api/notifications/$notificationId/read');
      if (response.statusCode == 200) {
        // تحديث الحالة محلياً فوراً لسرعة الاستجابة في الـ UI
        notifications[index] = OwnerNotificationModel(
          id: notifications[index].id,
          isRead: true,
          title: notifications[index].title,
          subtitle: notifications[index].subtitle,
          status: notifications[index].status,
          dateHuman: notifications[index].dateHuman,
        );
        if (unreadCount.value > 0) unreadCount.value--;
      }
    } catch (e) {
      print("خطأ أثناء تحديث الإشعار: $e");
    }
  }

  // دالة تحويل جميع الإشعارات لمقروءة مرة واحدة
  Future<void> markAllNotificationsAsRead() async {
    if (unreadCount.value == 0) return;
    try {
      final response = await _dio.put('/api/notifications/read-all');
      if (response.statusCode == 200) {
        // تحديث القائمة بالكامل محلياً
        for (int i = 0; i < notifications.length; i++) {
          if (!notifications[i].isRead) {
            notifications[i] = OwnerNotificationModel(
              id: notifications[i].id,
              isRead: true,
              title: notifications[i].title,
              subtitle: notifications[i].subtitle,
              status: notifications[i].status,
              dateHuman: notifications[i].dateHuman,
            );
          }
        }
        unreadCount.value = 0;
        Get.snackbar('نجاح', 'تم تحديد جميع الإشعارات كمقروءة');
      }
    } catch (e) {
      print("خطأ أثناء تحديث الكل: $e");
    }
  }
}
