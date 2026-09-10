import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/property_controller.dart';
import 'property_details_screen.dart';

class OwnerPropertiesScreen extends StatelessWidget {
  const OwnerPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PropertyController controller = Get.put(PropertyController());
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? const Color(0xffF8FAFC) : Colors.black87;
    const Color primary = Color(0xff1E3A8A);
    const Color accent = Color(0xff0F766E);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "عقاراتي",
          style:
              GoogleFonts.cairo(fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.properties.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.properties.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home_work_outlined,
                    size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text("لا توجد عقارات حالياً",
                    style: GoogleFonts.cairo(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchMyProperties(),
                  child: const Text("إعادة تحميل"),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchMyProperties,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.properties.length,
            itemBuilder: (context, index) {
              final property = controller.properties[index];
              final String status = property['approval_status'] ?? 'pending';
              final Color statusColor = status == 'accepted'
                  ? Colors.green
                  : (status == 'rejected' ? Colors.red : Colors.orange);
              final String statusText = status == 'accepted'
                  ? 'مقبول'
                  : (status == 'rejected' ? 'مرفوض' : 'قيد المراجعة');

              final String imageUrl = property['images'] != null &&
                      property['images'].isNotEmpty
                  ? '${controller.baseUrl}/storage/${property['images'][0]['image_path']}'
                  : '';

              return GestureDetector(
                onTap: () {
                  Get.to(() => PropertyDetailsScreen(property: property));
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 180,
                                  color: Colors.grey[300],
                                  child:
                                      const Icon(Icons.broken_image, size: 50),
                                ),
                              )
                            : Container(
                                height: 180,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported,
                                    size: 50),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    property['title'] ?? 'بدون عنوان',
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: GoogleFonts.cairo(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 18, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    property['region'] ?? 'موقع غير محدد',
                                    style:
                                        GoogleFonts.cairo(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${property['price_sp'] ?? 0} ل.س',
                              style: GoogleFonts.cairo(
                                color: accent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
