import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../controller/property_controller.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  late final PropertyController controller;

  final titleController = TextEditingController();
  final priceSpController = TextEditingController();
  final priceUsdController = TextEditingController();
  final descController = TextEditingController();
  final areaController = TextEditingController();
  final roomsController = TextEditingController();
  final floorController = TextEditingController();
  final regionController = TextEditingController();
  final addressController = TextEditingController();

  final picker = ImagePicker();
  List<File> images = [];

  String propertyType = "apartment";
  String offerType = "sale";
  String? selectedOfficeId;
  String? locationGps;
  String? rentPeriod;
  bool isFurnished = false;
  bool loadingLocation = false;

  final primary = const Color(0xff1E3A8A);
  final accent = const Color(0xff0F766E);

  final Map<String, String> propertyTypes = {
    'apartment': 'شقة',
    'villa': 'فيلا',
    'land': 'أرض',
    'farm': 'مزرعة',
    'shop': 'محل',
    'office': 'مكتب',
  };

  final Map<String, IconData> propertyTypeIcons = {
    'apartment': Icons.apartment_rounded,
    'villa': Icons.villa_rounded,
    'land': Icons.terrain_rounded,
    'farm': Icons.agriculture_rounded,
    'shop': Icons.storefront_rounded,
    'office': Icons.business_center_rounded,
  };

  final Map<String, String> offerTypes = {
    'sale': 'بيع',
    'rent': 'إيجار',
  };

  final Map<String, String> rentPeriods = {
    'daily': 'يومي',
    'weekly': 'أسبوعي',
    'monthly': 'شهري',
    'yearly': 'سنوي',
  };

  bool get _needsRoomsAndFloor =>
      propertyType != 'land' && propertyType != 'farm';

  bool get _needsFurnished =>
      propertyType == 'apartment' ||
      propertyType == 'villa' ||
      propertyType == 'office';

  bool get _needsFloorOnly => propertyType == 'shop';

  @override
  void initState() {
    super.initState();
    controller = Get.put(PropertyController());
  }

  @override
  void dispose() {
    titleController.dispose();
    priceSpController.dispose();
    priceUsdController.dispose();
    descController.dispose();
    areaController.dispose();
    roomsController.dispose();
    floorController.dispose();
    regionController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        images.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  // ✅ تحديد الموقع الحالي مباشرة (زر سريع)
  Future<void> getCurrentLocation() async {
    setState(() => loadingLocation = true);

    bool service = await Geolocator.isLocationServiceEnabled();
    if (!service) {
      Get.snackbar('تنبيه', 'الرجاء تفعيل خدمات الموقع',
          backgroundColor: Colors.orange, colorText: Colors.white);
      setState(() => loadingLocation = false);
      return;
    }

    LocationPermission perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied) {
      Get.snackbar('تنبيه', 'الرجاء السماح بتحديد الموقع',
          backgroundColor: Colors.orange, colorText: Colors.white);
      setState(() => loadingLocation = false);
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      locationGps = '${pos.latitude},${pos.longitude}';
      loadingLocation = false;
    });
    Get.snackbar('نجاح', 'تم تحديد موقعك الحالي',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  // ✅ جديد: فتح خريطة تفاعلية لاختيار أي موقع (قريب أو بعيد)
  Future<void> openMapPicker() async {
    LatLng? initial;
    if (locationGps != null) {
      final parts = locationGps!.split(',');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0]);
        final lng = double.tryParse(parts[1]);
        if (lat != null && lng != null) {
          initial = LatLng(lat, lng);
        }
      }
    }

    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialLocation: initial),
      ),
    );

    if (result != null) {
      setState(() {
        locationGps = '${result.latitude},${result.longitude}';
      });
    }
  }

  Future<void> submitProperty() async {
    if (titleController.text.isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء إدخال اسم العقار',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (priceSpController.text.isEmpty && priceUsdController.text.isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء إدخال السعر بالليرة أو بالدولار',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (regionController.text.isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء إدخال المنطقة',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (images.isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء إضافة صورة واحدة على الأقل',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (selectedOfficeId == null) {
      Get.snackbar('تنبيه', 'الرجاء اختيار المكتب العقاري',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (offerType == 'rent' && rentPeriod == null) {
      Get.snackbar('تنبيه', 'الرجاء اختيار فترة الإيجار',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final success = await controller.addProperty(
      title: titleController.text.trim(),
      description: descController.text.trim(),
      priceSp: priceSpController.text.trim(),
      priceUsd: priceUsdController.text.trim(),
      propertyType: propertyType,
      offerType: offerType,
      region: regionController.text.trim(),
      area: int.tryParse(areaController.text) ?? 0,
      roomsCount: _needsRoomsAndFloor && !_needsFloorOnly
          ? (int.tryParse(roomsController.text) ?? 0)
          : 0,
      floorNumber: (_needsRoomsAndFloor || _needsFloorOnly)
          ? (int.tryParse(floorController.text) ?? 0)
          : 0,
      officeId: selectedOfficeId!,
      images: images,
      isFurnished: _needsFurnished ? isFurnished : false,
      rentPeriod: offerType == 'rent' ? rentPeriod : null,
      locationGps: locationGps,
      addressDetails: addressController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB);
    final cardBg = isDark ? const Color(0xff111827) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xff0F172A);
    final sub = isDark ? Colors.white60 : Colors.black45;
    final fieldFill =
        isDark ? Colors.white.withOpacity(0.05) : const Color(0xffF1F5F9);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: text),
          title: Text("إضافة عقار",
              style: GoogleFonts.cairo(
                  color: text, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        body: Obx(() => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 20),

                  // ============================================
                  // ✅ نوع العقار بالبداية
                  // ============================================
                  _card(
                    isDark: isDark,
                    cardBg: cardBg,
                    text: text,
                    title: "نوع العقار",
                    icon: Icons.category_outlined,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: propertyTypes.entries
                            .map((e) => _chipProperty(e.key, e.value, isDark))
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _card(
                    isDark: isDark,
                    cardBg: cardBg,
                    text: text,
                    title: "المعلومات الأساسية",
                    icon: Icons.info_outline_rounded,
                    children: [
                      _input("اسم العقار", titleController,
                          fill: fieldFill,
                          text: text,
                          sub: sub,
                          icon: Icons.badge_outlined),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _input("السعر (ل.س)", priceSpController,
                                number: true,
                                fill: fieldFill,
                                text: text,
                                sub: sub,
                                icon: Icons.payments_outlined),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _input(
                                "السعر (\$) اختياري", priceUsdController,
                                number: true,
                                fill: fieldFill,
                                text: text,
                                sub: sub,
                                icon: Icons.attach_money_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _input("المنطقة", regionController,
                          fill: fieldFill,
                          text: text,
                          sub: sub,
                          icon: Icons.location_on_outlined),
                      const SizedBox(height: 12),
                      _input("تفاصيل العنوان - اختياري", addressController,
                          fill: fieldFill,
                          text: text,
                          sub: sub,
                          icon: Icons.map_outlined),
                      const SizedBox(height: 12),
                      _input("الوصف", descController,
                          max: 4,
                          fill: fieldFill,
                          text: text,
                          sub: sub,
                          icon: Icons.description_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _card(
                    isDark: isDark,
                    cardBg: cardBg,
                    text: text,
                    title: "نوع العملية",
                    icon: Icons.swap_horiz_rounded,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: offerTypes.entries
                            .map((e) => _chipOffer(e.key, e.value, isDark))
                            .toList(),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        child: offerType == 'rent'
                            ? Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("فترة الإيجار",
                                        style: GoogleFonts.cairo(
                                            color: sub,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: rentPeriods.entries
                                          .map((e) => _chipRentPeriod(
                                              e.key, e.value, isDark))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _card(
                    isDark: isDark,
                    cardBg: cardBg,
                    text: text,
                    title: "المواصفات",
                    icon: Icons.straighten_rounded,
                    children: [
                      _input("المساحة (م²)", areaController,
                          number: true,
                          fill: fieldFill,
                          text: text,
                          sub: sub,
                          icon: Icons.square_foot_rounded),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        child: (_needsRoomsAndFloor || _needsFloorOnly)
                            ? Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    if (_needsRoomsAndFloor &&
                                        !_needsFloorOnly) ...[
                                      Expanded(
                                        child: _input(
                                            "عدد الغرف", roomsController,
                                            number: true,
                                            fill: fieldFill,
                                            text: text,
                                            sub: sub,
                                            icon: Icons.bed_outlined),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: _input(
                                          "رقم الطابق", floorController,
                                          number: true,
                                          fill: fieldFill,
                                          text: text,
                                          sub: sub,
                                          icon: Icons.layers_outlined),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        child: _needsFurnished
                            ? Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: fieldFill,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.chair_outlined,
                                          color: sub, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          isFurnished ? "مفروش" : "غير مفروش",
                                          style: GoogleFonts.cairo(
                                              color: text, fontSize: 14),
                                        ),
                                      ),
                                      Switch(
                                        value: isFurnished,
                                        activeColor: primary,
                                        onChanged: (val) =>
                                            setState(() => isFurnished = val),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _card(
                    isDark: isDark,
                    cardBg: cardBg,
                    text: text,
                    title: "المكتب العقاري",
                    icon: Icons.corporate_fare_rounded,
                    children: [
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: fieldFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                        ),
                        dropdownColor: cardBg,
                        style: GoogleFonts.cairo(color: text),
                        hint: Text("اختر المكتب العقاري",
                            style: GoogleFonts.cairo(color: sub)),
                        value: selectedOfficeId,
                        items: controller.offices.map((office) {
                          return DropdownMenuItem<String>(
                            value: office['id'].toString(),
                            child: Text(office['name'] ?? 'مكتب عقاري'),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => selectedOfficeId = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _card(
                    isDark: isDark,
                    cardBg: cardBg,
                    text: text,
                    title: "الصور",
                    icon: Icons.photo_library_outlined,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _addImage(fieldFill, sub),
                          ...images
                              .asMap()
                              .entries
                              .map((e) => _buildImage(e.value, e.key)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ============================================
                  // ✅ الموقع الجغرافي: خريطة تفاعلية + موقع حالي
                  // ============================================
                  _card(
                    isDark: isDark,
                    cardBg: cardBg,
                    text: text,
                    title: "الموقع الجغرافي",
                    icon: Icons.pin_drop_outlined,
                    children: [
                      Row(
                        children: [
                          Icon(
                            locationGps == null
                                ? Icons.location_off_outlined
                                : Icons.check_circle_rounded,
                            color: locationGps == null ? sub : accent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              locationGps ?? "لم يتم تحديد الموقع بعد",
                              style: GoogleFonts.cairo(
                                  color: locationGps == null ? sub : text,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ✅ زر فتح الخريطة (يقدر يحدد أي مكان بالعالم)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: openMapPicker,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.map_rounded,
                              color: Colors.white),
                          label: Text(
                            "فتح الخريطة وتحديد الموقع",
                            style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ✅ زر تحديد الموقع الحالي (اختياري سريع)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              loadingLocation ? null : getCurrentLocation,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: loadingLocation
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: primary))
                              : Icon(Icons.my_location, color: primary),
                          label: Text(
                            loadingLocation
                                ? "جاري التحديد..."
                                : "استخدام موقعي الحالي",
                            style: GoogleFonts.cairo(
                                color: primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
        bottomNavigationBar: _submit(),
      ),
    );
  }

  Widget _header() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, accent],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add_home_work_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "أدخل بيانات عقارك بدقة",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _card({
    required bool isDark,
    required Color cardBg,
    required Color text,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primary),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.cairo(
                      color: text,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _input(
    String hint,
    TextEditingController c, {
    bool number = false,
    int max = 1,
    required Color fill,
    required Color text,
    required Color sub,
    IconData? icon,
  }) {
    return TextField(
      controller: c,
      maxLines: max,
      style: GoogleFonts.cairo(color: text, fontSize: 14),
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(color: sub, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, color: sub, size: 20) : null,
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _chipProperty(String value, String label, bool isDark) {
    final active = propertyType == value;
    return GestureDetector(
      onTap: () => setState(() {
        propertyType = value;
        if (value == 'land' || value == 'farm') {
          roomsController.clear();
          floorController.clear();
          isFurnished = false;
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? primary
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              propertyTypeIcons[value] ?? Icons.home_outlined,
              size: 16,
              color: active
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.cairo(
                    color: active
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _chipOffer(String value, String label, bool isDark) {
    final active = offerType == value;
    return GestureDetector(
      onTap: () => setState(() {
        offerType = value;
        if (value == 'sale') rentPeriod = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? accent
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: GoogleFonts.cairo(
                color: active
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _chipRentPeriod(String value, String label, bool isDark) {
    final active = rentPeriod == value;
    return GestureDetector(
      onTap: () => setState(() => rentPeriod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? primary
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: GoogleFonts.cairo(
                color: active
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 12.5,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _addImage(Color fill, Color sub) => GestureDetector(
        onTap: pickImages,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: sub.withOpacity(0.3), style: BorderStyle.solid),
          ),
          child: Icon(Icons.add_a_photo_outlined, color: sub),
        ),
      );

  Widget _buildImage(File file, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: () => removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _submit() => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primary, accent]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: controller.isLoading.value ? null : submitProperty,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: Colors.white),
                        const SizedBox(width: 8),
                        Text("حفظ العقار",
                            style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
            )),
      );
}

// ================================================================
// ✅ شاشة الخريطة التفاعلية لاختيار الموقع
// - تقدر تدبّس بأي مكان بالخريطة (قريب أو بعيد) لتحديد الموقع
// - فيها زر للانتقال لموقعك الحالي كنقطة بداية
// - فيها بحث بالتكبير/التصغير عادي بالخريطة (سحب وتكبير)
// ================================================================
class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final primary = const Color(0xff1E3A8A);
  final accent = const Color(0xff0F766E);

  late final MapController _mapController;
  LatLng? selectedPoint;
  bool locatingMe = false;

  // مركز افتراضي: سوريا (دمشق) إذا ما كان في موقع محدد مسبقاً
  static const LatLng _defaultCenter = LatLng(33.5138, 36.2765);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    selectedPoint = widget.initialLocation;
  }

  Future<void> _goToMyLocation() async {
    setState(() => locatingMe = true);
    try {
      bool service = await Geolocator.isLocationServiceEnabled();
      if (!service) {
        Get.snackbar('تنبيه', 'الرجاء تفعيل خدمات الموقع',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }
      LocationPermission perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        Get.snackbar('تنبيه', 'الرجاء السماح بتحديد الموقع',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final point = LatLng(pos.latitude, pos.longitude);
      setState(() => selectedPoint = point);
      _mapController.move(point, 15);
    } finally {
      setState(() => locatingMe = false);
    }
  }

  void _confirm() {
    if (selectedPoint == null) {
      Get.snackbar('تنبيه', 'الرجاء تحديد نقطة على الخريطة أولاً',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    Navigator.pop(context, selectedPoint);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB);
    final text = isDark ? Colors.white : const Color(0xff0F172A);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: text),
          title: Text("حدد موقع العقار",
              style: GoogleFonts.cairo(
                  color: text, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        body: Stack(
          children: [
            // ✅ الخريطة نفسها
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: selectedPoint ?? _defaultCenter,
                initialZoom: selectedPoint != null ? 15 : 7,
                onTap: (tapPosition, point) {
                  setState(() => selectedPoint = point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.havensyria.app',
                ),
                if (selectedPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedPoint!,
                        width: 46,
                        height: 46,
                        child: Icon(
                          Icons.location_on_rounded,
                          color: primary,
                          size: 46,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // ✅ تنويه بسيط بالأعلى
            Positioned(
              top: 12,
              right: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      (isDark ? Colors.black : Colors.white).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_rounded, color: primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "دبّس على أي مكان بالخريطة لتحديد موقع العقار",
                        style: GoogleFonts.cairo(color: text, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ زر الانتقال لموقعي الحالي (اختياري)
            Positioned(
              bottom: 100,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'my_location_btn',
                backgroundColor: Colors.white,
                onPressed: locatingMe ? null : _goToMyLocation,
                child: locatingMe
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: primary),
                      )
                    : Icon(Icons.my_location, color: primary),
              ),
            ),
          ],
        ),

        // ✅ شريط سفلي: إحداثيات + زر تأكيد
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff111827) : Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedPoint == null
                      ? "لم يتم اختيار نقطة بعد"
                      : "${selectedPoint!.latitude.toStringAsFixed(6)}, ${selectedPoint!.longitude.toStringAsFixed(6)}",
                  style: GoogleFonts.cairo(color: text, fontSize: 13),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text("تأكيد هذا الموقع",
                        style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
