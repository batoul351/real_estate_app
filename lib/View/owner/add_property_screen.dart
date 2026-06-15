import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
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
  final priceUsdController = TextEditingController(); // ✅ جديد
  final descController = TextEditingController();
  final areaController = TextEditingController();
  final roomsController = TextEditingController();
  final floorController = TextEditingController();
  final regionController = TextEditingController();
  final addressController = TextEditingController(); // ✅ جديد

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

  Future<void> getLocation() async {
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
    Get.snackbar('نجاح', 'تم تحديد الموقع',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  Future<void> submitProperty() async {
    if (titleController.text.isEmpty) {
      Get.snackbar('تنبيه', 'الرجاء إدخال اسم العقار',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    // ✅ يجب إدخال سعر واحد على الأقل
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
      roomsCount: int.tryParse(roomsController.text) ?? 0,
      floorNumber: int.tryParse(floorController.text) ?? 0,
      officeId: selectedOfficeId!,
      images: images,
      isFurnished: isFurnished,
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
    final bg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff070B18)
        : const Color(0xffF6F7FB);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text("إضافة عقار",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        ),
        body: Obx(() => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 16),

                  _input("اسم العقار", titleController),
                  const SizedBox(height: 10),

                  // ✅ سعر بالليرة السورية
                  _input("السعر (ليرة سورية)", priceSpController, number: true),
                  const SizedBox(height: 10),

                  // ✅ سعر بالدولار - اختياري
                  _input("السعر (دولار) - اختياري", priceUsdController,
                      number: true),
                  const SizedBox(height: 10),

                  _input("المنطقة", regionController),
                  const SizedBox(height: 10),

                  // ✅ تفاصيل العنوان - اختياري
                  _input("تفاصيل العنوان - اختياري", addressController),
                  const SizedBox(height: 10),

                  _input("المساحة (م²)", areaController, number: true),
                  const SizedBox(height: 10),
                  _input("عدد الغرف", roomsController, number: true),
                  const SizedBox(height: 10),
                  _input("رقم الطابق", floorController, number: true),
                  const SizedBox(height: 10),
                  _input("الوصف", descController, max: 4),
                  const SizedBox(height: 20),

                  _section("نوع العقار"),
                  Wrap(
                    children: propertyTypes.entries
                        .map((e) => _chipProperty(e.key, e.value))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  _section("نوع العملية"),
                  Wrap(
                    children: offerTypes.entries
                        .map((e) => _chipOffer(e.key, e.value))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  if (offerType == 'rent') ...[
                    _section("فترة الإيجار"),
                    Wrap(
                      children: rentPeriods.entries
                          .map((e) => _chipRentPeriod(e.key, e.value))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  _section("حالة الفرش"),
                  Row(
                    children: [
                      Switch(
                        value: isFurnished,
                        activeColor: primary,
                        onChanged: (val) => setState(() => isFurnished = val),
                      ),
                      Text(
                        isFurnished ? "مفروش" : "غير مفروش",
                        style: GoogleFonts.cairo(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _section("المكتب العقاري"),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    hint: const Text("اختر المكتب العقاري"),
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
                  const SizedBox(height: 20),

                  _section("الصور"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _addImage(),
                      ...images
                          .asMap()
                          .entries
                          .map((e) => _buildImage(e.value, e.key)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _section("الموقع الجغرافي"),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationGps == null
                              ? "لم يتم تحديد الموقع"
                              : locationGps!,
                          style: GoogleFonts.cairo(),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: loadingLocation ? null : getLocation,
                          icon: const Icon(Icons.my_location),
                          label: Text(
                            loadingLocation ? "جاري..." : "تحديد الموقع",
                            style: GoogleFonts.cairo(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            )),
        bottomNavigationBar: _submit(),
      ),
    );
  }

  Widget _header() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primary, accent]),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          "أدخل بيانات عقارك بدقة",
          style: GoogleFonts.cairo(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );

  Widget _input(String h, TextEditingController c,
      {bool number = false, int max = 1}) {
    return TextField(
      controller: c,
      maxLines: max,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: h,
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(t, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      );

  Widget _chipProperty(String value, String label) {
    final active = propertyType == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => propertyType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: active ? primary : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              style: TextStyle(
                  color: active ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _chipOffer(String value, String label) {
    final active = offerType == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() {
          offerType = value;
          if (value == 'sale') rentPeriod = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: active ? accent : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              style: TextStyle(
                  color: active ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _chipRentPeriod(String value, String label) {
    final active = rentPeriod == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => rentPeriod = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: active ? primary : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              style: TextStyle(
                  color: active ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _addImage() => GestureDetector(
        onTap: pickImages,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add_a_photo),
        ),
      );

  Widget _buildImage(File file, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => removeImage(index),
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _submit() => Container(
        margin: const EdgeInsets.all(16),
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primary, accent]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              onPressed: controller.isLoading.value ? null : submitProperty,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white))
                  : Text("حفظ العقار",
                      style: GoogleFonts.cairo(color: Colors.white)),
            )),
      );
}
