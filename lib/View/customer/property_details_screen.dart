import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../controller/customer_property_controller.dart';

class PropertyDetailsScreen extends StatefulWidget {
  // ✅ نقبل property كقيمة أولية (للعرض الفوري بدون انتظار)، لازم تحتوي على الأقل على 'id'
  final Map<String, dynamic> property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  late Map<String, dynamic> property;
  bool _isLoadingFullDetails = true;

  @override
  void initState() {
    super.initState();
    property = widget.property;
    _loadFullDetails();
  }

  // ✅ نجيب التفاصيل الكاملة من /api/detailes/{id} لأنه بيانات الكروت (browse) مختصرة وناقصة
  Future<void> _loadFullDetails() async {
    final id = property['id'];
    if (id == null) {
      setState(() => _isLoadingFullDetails = false);
      return;
    }

    try {
      final controller = Get.find<CustomerPropertyController>();
      final fullDetails = await controller.getPropertyDetails(id as int);

      if (fullDetails != null && mounted) {
        setState(() {
          property = {...property, ...fullDetails};
        });
      }
    } catch (e) {
      print('Error loading full property details: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingFullDetails = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openMap(double lat, double lng) async {
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  // ============================================================
  // ✅ الإصلاح: يحل مشكلة تكرار الدومين بروابط الصور (404)
  // بعض السجلات بالباك اند مخزّن فيها رابط كامل جاهز (https://...)
  // وبعضها مخزّن فيها مسار نسبي فقط (properties/x.png).
  // قبل هيك كان الكود يحط baseUrl/storage/ فوق أي قيمة، حتى لو
  // كانت أصلاً رابط كامل، فكان يصير دومين مكرر داخل دومين -> 404.
  // ============================================================
  String _resolveImageUrl(String rawUrl, String baseUrl) {
    if (rawUrl.isEmpty) return '';

    // الحالة 1: الباك اند رجّع رابط كامل جاهز أصلاً
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }

    // الحالة 2: مسار نسبي فقط -> لازم نضيف الدومين + /storage/
    final cleanPath = rawUrl.startsWith('/') ? rawUrl.substring(1) : rawUrl;
    return '$baseUrl/storage/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final CustomerPropertyController controller =
        Get.find<CustomerPropertyController>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final Color subColor = isDark ? Colors.white70 : Colors.black54;
    const Color primary = Color(0xff1E3A8A);

    final String title = property['title'] ?? 'بدون عنوان';
    final String description = property['description'] ?? '';
    final String region = property['region'] ?? 'غير محدد';
    final String address = property['address_details'] ?? '';
    final String status = property['approval_status'] ?? 'accepted';
    final String propertyStatus = property['status'] ?? 'available';
    final String propertyType = property['property_type'] ?? '';
    final String offerType = property['offer_type'] ?? '';
    final List images = property['images'] ?? [];
    final office = property['office'];
    final String phone = office?['phone'] ?? '';

    final String? priceSp =
        property['price_sp'] != null ? '${property['price_sp']} ل.س' : null;
    final String? priceUsd =
        property['price_usd'] != null ? '\$${property['price_usd']}' : null;
    final String? area =
        property['area'] != null ? '${property['area']} م²' : null;
    final String? rooms = property['rooms_count']?.toString();
    final String? floor = property['floor_number']?.toString();
    final String? isFurnished = property['is_furnished'] != null
        ? (property['is_furnished'] == true ||
                property['is_furnished'] == 1 ||
                property['is_furnished'] == '1'
            ? 'مفروش'
            : 'غير مفروش')
        : null;
    final String? rentPeriod = property['rent_period'] != null
        ? _getRentPeriod(property['rent_period'])
        : null;

    double? lat;
    double? lng;

    if (property['location_gps'] != null) {
      final gpsData = property['location_gps'];
      if (gpsData is Map) {
        lat = double.tryParse(gpsData['lat']?.toString() ?? '');
        lng = double.tryParse(gpsData['lng']?.toString() ?? '');
      } else {
        final gps = gpsData.toString();
        if (gps.contains(',')) {
          final coords = gps.split(',');
          lat = double.tryParse(coords[0].trim());
          lng = double.tryParse(coords[1].trim());
        }
      }
    }

    final Color statusColor = status == 'accepted'
        ? Colors.green
        : (status == 'rejected' ? Colors.red : Colors.orange);
    final String statusText = status == 'accepted'
        ? 'مقبول'
        : (status == 'rejected' ? 'مرفوض' : 'قيد المراجعة');

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
        actions: [
          if (_isLoadingFullDetails)
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            final rawImagePath = (images[index]['url'] ??
                                    images[index]['image_path'] ??
                                    '')
                                .toString();
                            // ✅ الإصلاح مطبّق هون بدل التركيب اليدوي القديم
                            final imageUrl = _resolveImageUrl(
                                rawImagePath, controller.baseUrl);
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      loadingBuilder:
                                          (_, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      },
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image,
                                            size: 50),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                          Icons.image_not_supported,
                                          size: 50),
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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _statusChip('حالة الطلب: $statusText', statusColor),
                _statusChip('الحالة: $propertyStatusText', propertyStatusColor),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
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
                ],
              ),
            ),
            const SizedBox(height: 16),
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
            if (lat != null && lng != null) ...[
              const SizedBox(height: 16),
              Text(
                'الموقع على الخريطة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _openMap(lat!, lng!),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(lat!, lng!),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('property'),
                          position: LatLng(lat!, lng!),
                          infoWindow: InfoWindow(
                            title: title,
                            snippet: region,
                          ),
                        ),
                      },
                      zoomControlsEnabled: true,
                      myLocationEnabled: false,
                      scrollGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اضغط على الخريطة لفتحها في تطبيق الخرائط',
                style: GoogleFonts.cairo(
                  color: subColor,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (phone.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(phone),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.phone_rounded, color: Colors.white),
                  label: Text(
                    'اتصال على $phone',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, {required bool isDark}) {
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
