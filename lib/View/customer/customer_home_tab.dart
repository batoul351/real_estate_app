import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/customer_property_controller.dart';
import '../../controller/customer_favorites_controller.dart';
import 'property_details_screen.dart';

class CustomerHomeTab extends StatelessWidget {
  const CustomerHomeTab({super.key});

  // ============================================================
  // ✅ يحل مشكلة تكرار الدومين بروابط الصور (404)
  // ============================================================
  String _resolveImageUrl(String rawUrl, String baseUrl) {
    if (rawUrl.isEmpty) return '';

    // الحالة 1: الرابط كامل
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }

    // الحالة 2: مسار نسبي
    String cleanPath = rawUrl;
    if (!cleanPath.startsWith('/')) {
      cleanPath = '/$cleanPath';
    }
    if (!cleanPath.startsWith('/storage/')) {
      cleanPath = '/storage$cleanPath';
    }

    String cleanBaseUrl = baseUrl;
    if (cleanBaseUrl.endsWith('/')) {
      cleanBaseUrl = cleanBaseUrl.substring(0, cleanBaseUrl.length - 1);
    }

    return '$cleanBaseUrl$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final CustomerPropertyController propertyController =
        Get.find<CustomerPropertyController>();
    final CustomerFavoritesController favoritesController =
        Get.find<CustomerFavoritesController>();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB);
    final Color text = isDark ? Colors.white : const Color(0xff0F172A);
    final Color subText = isDark ? Colors.white70 : Colors.black54;
    final Color cardColor = isDark ? const Color(0xff111827) : Colors.white;
    const Color primary = Color(0xff1E3A8A);
    const Color accent = Color(0xff0F766E);

    return Scaffold(
      backgroundColor: bg,
      body: Obx(() {
        if (propertyController.isLoading.value &&
            propertyController.properties.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? Colors.white : primary,
            ),
          );
        }

        if (propertyController.properties.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_work_outlined,
                    size: 80,
                    color: isDark ? Colors.grey : Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'مرحباً بك في Haven Syria',
                  style: GoogleFonts.cairo(
                    color: text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'لا توجد عقارات متاحة حالياً',
                  style: GoogleFonts.cairo(color: subText),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    propertyController.fetchProperties();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إعادة تحميل',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: propertyController.fetchProperties,
          color: primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: propertyController.properties.length,
            itemBuilder: (context, index) {
              final property = propertyController.properties[index];

              // ✅ استخدام الدالة المساعدة
              final rawImage =
                  property['images'] != null && property['images'].isNotEmpty
                      ? (property['images'][0]['url'] ?? '').toString()
                      : '';
              final imageUrl =
                  _resolveImageUrl(rawImage, propertyController.baseUrl);

              final bool isFav = favoritesController.isFavorite(property['id']);

              return GestureDetector(
                onTap: () {
                  Get.to(() => PropertyDetailsScreen(property: property));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ الصورة
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 180,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
                                  height: 180,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Container(
                                height: 180,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      // ✅ المعلومات
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    property['title'] ?? 'بدون عنوان',
                                    style: GoogleFonts.cairo(
                                      color: text,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    if (isFav) {
                                      await favoritesController
                                          .removeFromFavorites(property['id']);
                                    } else {
                                      await favoritesController
                                          .addToFavorites(property['id']);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // ✅ المنطقة
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: subText,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    property['region'] ?? '',
                                    style: GoogleFonts.cairo(
                                      color: subText,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // ✅ السعر والمساحة والغرف
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${property['price_sp'] ?? 0} ل.س',
                                    style: GoogleFonts.cairo(
                                      color: accent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (property['area'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${property['area']} م²',
                                      style: GoogleFonts.cairo(
                                        color: primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                if (property['rooms_count'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.bed_outlined,
                                          size: 14,
                                          color: subText,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${property['rooms_count']}',
                                          style: GoogleFonts.cairo(
                                            color: subText,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // ✅ زر عرض التفاصيل
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'عرض التفاصيل',
                                  style: GoogleFonts.cairo(
                                    color: primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
