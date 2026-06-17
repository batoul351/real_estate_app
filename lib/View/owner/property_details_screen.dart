import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../controller/property_controller.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    print('📦 جميع المفاتيح: ${widget.property.keys}');
    print('📦 البيانات كاملة: ${widget.property}');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PropertyController controller = Get.find<PropertyController>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final Color subColor = isDark ? Colors.white70 : Colors.black54;
    const Color primary = Color(0xff1E3A8A);

    final property = widget.property;

    // ✅ استخراج البيانات بشكل صحيح مع String? بدل String
    final String title = property['title'] ?? 'بدون عنوان';
    final String description = property['description'] ?? '';
    final String region = property['region'] ?? 'غير محدد';
    final String address = property['address_details'] ?? '';
    final String status = property['approval_status'] ?? 'pending';
    final String propertyStatus = property['status'] ?? 'available';
    final String propertyType = property['property_type'] ?? '';
    final String offerType = property['offer_type'] ?? '';
    final List images = property['images'] ?? [];

    // ✅ القيم القابلة للإخفاء — String? بدل String مع fallback '0'
    final String? priceSp =
        property['price_sp'] != null ? '${property['price_sp']} ل.س' : null;

    final String? priceUsd =
        property['price_usd'] != null ? '\$${property['price_usd']}' : null;

    final String? area =
        property['area'] != null ? '${property['area']} م²' : null;

    final String? rooms = property['rooms_count']?.toString();

    final String? floor = property['floor_number']?.toString();

    final String? locationGps = (property['location_gps'] != null &&
            property['location_gps'].toString().isNotEmpty)
        ? property['location_gps'].toString()
        : null;

    final String? rentPeriod = property['rent_period'] != null
        ? _getRentPeriod(property['rent_period'])
        : null;

    final String? isFurnished = property['is_furnished'] != null
        ? (property['is_furnished'] == true ||
                property['is_furnished'] == 1 ||
                property['is_furnished'] == '1'
            ? 'مفروش'
            : 'غير مفروش')
        : null;

    // ألوان حالة الطلب
    final Color statusColor = status == 'accepted'
        ? Colors.green
        : (status == 'rejected' ? Colors.red : Colors.orange);
    final String statusText = status == 'accepted'
        ? 'مقبول'
        : (status == 'rejected' ? 'مرفوض' : 'قيد المراجعة');

    // ألوان حالة العقار
    final Color propertyStatusColor = propertyStatus == 'available'
        ? Colors.green
        : (propertyStatus == 'sold' ? Colors.red : Colors.orange);
    final String propertyStatusText = propertyStatus == 'available'
        ? 'متاح'
        : (propertyStatus == 'sold' ? 'مباع' : 'مؤجر');

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style:
              GoogleFonts.cairo(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ صور العقار
            if (images.isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final imagePath = images[index]['image_path'] ?? '';
                            final imageUrl =
                                '${controller.baseUrl}/storage/$imagePath';
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder: (_, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[300],
                                  child:
                                      const Icon(Icons.broken_image, size: 50),
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: images.length,
                              effect: ExpandingDotsEffect(
                                dotHeight: 8,
                                dotWidth: 8,
                                expansionFactor: 3,
                                spacing: 6,
                                activeDotColor: primary,
                                dotColor: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1}/${images.length}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.image_not_supported, size: 50),
              ),

            const SizedBox(height: 20),

            // ✅ بادجات الحالة
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _statusChip('حالة الطلب: $statusText', statusColor),
                _statusChip('الحالة: $propertyStatusText', propertyStatusColor),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ العنوان
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),

            // ✅ المنطقة والعنوان
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.location_on, size: 18, color: subColor),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    region + (address.isNotEmpty ? ' - $address' : ''),
                    style: GoogleFonts.cairo(color: subColor, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ معلومات العقار
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: Column(
                children: [
                  // ✅ هذه الحقول دائماً تظهر إذا كانت القيمة موجودة
                  _buildInfoRow('نوع العقار', _getPropertyType(propertyType),
                      isDark: isDark),
                  _buildInfoRow('نوع العملية', _getOfferType(offerType),
                      isDark: isDark),
                  _buildInfoRow('السعر (ليرة)', priceSp, isDark: isDark),
                  _buildInfoRow('السعر (دولار)', priceUsd, isDark: isDark),
                  _buildInfoRow('المساحة', area, isDark: isDark),
                  _buildInfoRow('عدد الغرف', rooms, isDark: isDark),
                  _buildInfoRow('رقم الطابق', floor, isDark: isDark),
                  _buildInfoRow('التأثيث', isFurnished, isDark: isDark),
                  if (offerType == 'rent')
                    _buildInfoRow('مدة الإيجار', rentPeriod, isDark: isDark),
                  _buildInfoRow('الموقع الجغرافي', locationGps, isDark: isDark),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ الوصف
            if (description.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الوصف',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.cairo(
                        color: subColor,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ✅ الدالة المصلحة — String? بدل String لكشف null بشكل صحيح
  Widget _buildInfoRow(String label, String? value, {required bool isDark}) {
    // إخفاء الصف إذا كانت القيمة null أو فارغة أو 'null' نصياً
    if (value == null || value.trim().isEmpty || value == 'null') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xff0F172A),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getPropertyType(String type) {
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

  String _getOfferType(String type) {
    const map = {
      'sale': 'بيع',
      'rent': 'إيجار',
    };
    return map[type] ?? type;
  }

  String _getRentPeriod(String period) {
    const map = {
      'daily': 'يومي',
      'weekly': 'أسبوعي',
      'monthly': 'شهري',
      'yearly': 'سنوي',
    };
    return map[period] ?? period;
  }
}
