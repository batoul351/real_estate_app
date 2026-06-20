import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/customer_favorites_controller.dart';
import '../../Service/theme_service.dart';
import 'property_details_screen.dart';

class CustomerFavoritesScreen extends StatelessWidget {
  const CustomerFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerFavoritesController controller =
        Get.find<CustomerFavoritesController>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB);
    final Color text = isDark ? Colors.white : const Color(0xff0F172A);
    final Color subText = isDark ? Colors.white70 : Colors.black54;
    final Color cardColor = isDark ? const Color(0xff111827) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'المفضلة',
          style: GoogleFonts.cairo(color: text, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.refreshFavorites(),
            icon: Icon(Icons.refresh, color: text),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.favorites.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? Colors.white : const Color(0xff1E3A8A),
            ),
          );
        }

        if (controller.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border,
                    size: 80,
                    color: isDark ? Colors.grey : Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'لا توجد عقارات في المفضلة',
                  style: GoogleFonts.cairo(color: subText),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshFavorites,
          color: const Color(0xff1E3A8A),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.favorites.length,
            itemBuilder: (context, index) {
              final favorite = controller.favorites[index];
              final property = favorite['property'] ?? {};
              final imageUrl = property['images'] != null &&
                      property['images'].isNotEmpty
                  ? '${controller.baseUrl}/storage/${property['images'][0]['image_path']}'
                  : '';

              return Card(
                color: cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Get.to(() => PropertyDetailsScreen(property: property));
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey,
                                  child: const Icon(Icons.broken_image),
                                ),
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey,
                                child: const Icon(Icons.home),
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property['title'] ?? 'بدون عنوان',
                                style: TextStyle(
                                  color: text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                property['region'] ?? '',
                                style: TextStyle(color: subText),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${property['price_sp'] ?? 0} ل.س',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff1E3A8A),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getPropertyTypeLabel(
                                          property['property_type'] ?? ''),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      await controller
                                          .removeFromFavorites(property['id']);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  String _getPropertyTypeLabel(String type) {
    const map = {
      'apartment': 'شقة',
      'villa': 'فيلا',
      'land': 'أرض',
      'farm': 'مزرعة',
      'shop': 'محل',
      'office': 'مكتب',
    };
    return map[type] ?? type;
  }
}
