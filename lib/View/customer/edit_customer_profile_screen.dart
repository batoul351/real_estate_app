import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controller/profile_controller.dart';

class EditCustomerProfileScreen extends StatefulWidget {
  const EditCustomerProfileScreen({super.key});

  @override
  State<EditCustomerProfileScreen> createState() =>
      _EditCustomerProfileScreenState();
}

class _EditCustomerProfileScreenState extends State<EditCustomerProfileScreen> {
  final ProfileController profileController = Get.find<ProfileController>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;

  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // ✅ تهيئة الـ Controllers بقيم من ProfileController
    nameController =
        TextEditingController(text: profileController.userName.value);
    emailController =
        TextEditingController(text: profileController.userEmail.value);
    phoneController =
        TextEditingController(text: profileController.userPhone.value);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    try {
      final image =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image == null) return;
      setState(() => selectedImage = File(image.path));
    } catch (e) {
      debugPrint("Image Picker Error: $e");
    }
  }

  Future<void> saveProfile() async {
    await profileController.updateProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB);
    final Color text = isDark ? Colors.white : const Color(0xff0F172A);
    final Color sub = isDark ? Colors.white70 : Colors.black54;
    const Color primary = Color(0xff1E3A8A);
    const Color accent = Color(0xff0F766E);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("تعديل الملف الشخصي",
            style: TextStyle(color: text, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// AVATAR
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [primary, accent]),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 25,
                        offset: const Offset(0, 10)),
                  ],
                ),
                child: ClipOval(
                  child: selectedImage != null
                      ? Image.file(selectedImage!, fit: BoxFit.cover)
                      : const Icon(Icons.add_a_photo,
                          size: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),

            /// CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border:
                    Border.all(color: isDark ? Colors.white12 : Colors.black12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _field(
                      controller: nameController,
                      hint: "الاسم الكامل",
                      icon: Icons.person,
                      isDark: isDark,
                      text: text,
                      sub: sub),
                  const SizedBox(height: 14),
                  _field(
                      controller: emailController,
                      hint: "البريد الإلكتروني",
                      icon: Icons.email_rounded,
                      isDark: isDark,
                      text: text,
                      sub: sub),
                  const SizedBox(height: 14),
                  _field(
                      controller: phoneController,
                      hint: "رقم الجوال",
                      icon: Icons.phone,
                      isDark: isDark,
                      text: text,
                      sub: sub),
                  const SizedBox(height: 25),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: profileController.isUpdating.value
                              ? null
                              : saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: profileController.isUpdating.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text("حفظ التغييرات",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color text,
    required Color sub,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: text),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: sub),
        hintText: hint,
        hintStyle: TextStyle(color: sub),
        filled: true,
        fillColor:
            isDark ? Colors.white.withOpacity(0.05) : const Color(0xffF1F5F9),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
      ),
    );
  }
}
