import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/notification_controller.dart';
import '../../Service/theme_service.dart';

class OwnerNotificationsScreen extends StatelessWidget {
  const OwnerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());
    final ThemeService themeService = Get.find<ThemeService>();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final Color subColor = isDark ? Colors.white70 : Colors.black54;
    final Color cardBg = isDark ? Colors.white.withOpacity(0.05) : Colors.white;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
              color: textColor),
          onPressed: () => themeService.toggleTheme(),
        ),
        title: Text(
          "الإشعارات",
          style:
              GoogleFonts.cairo(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: textColor),
            tooltip: 'تحديد الكل كمقروء',
            onPressed: () => controller.markAllNotificationsAsRead(),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchNotifications(),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: Text(
                "لا توجد إشعارات حالياً",
                style: GoogleFonts.cairo(color: subColor, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.notifications[index];

              return GestureDetector(
                onTap: () {
                  controller.markAsRead(item.id, index);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: item.isRead ? cardBg.withOpacity(0.5) : cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: item.isRead
                        ? null
                        : Border.all(
                            color:
                                _getStatusColor(item.status).withOpacity(0.4),
                            width: 1.5,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ دائرة الحالة
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // ✅ المحتوى
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ العنوان
                            Text(
                              item.title,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: item.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // ✅ الرسالة
                            Text(
                              item.subtitle,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: subColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // ✅ التاريخ
                            Text(
                              item.dateHuman,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ✅ أيقونة الحالة
                      Icon(
                        item.isRead
                            ? Icons.notifications_none_outlined
                            : Icons.notifications_active_outlined,
                        color: _getStatusColor(item.status),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green.shade400;
      case "pending":
        return Colors.orange.shade400;
      case "rejected":
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}
