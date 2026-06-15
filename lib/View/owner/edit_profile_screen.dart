// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controller/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ✅ جلب الـ Controller الموجود بالفعل (بدون إنشاء جديد)
  late final ProfileController profileController;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  File? profileImage;
  bool loading = false;
  final picker = ImagePicker();

  final primary = const Color(0xff1E3A8A);
  final accent = const Color(0xff0F766E);

  @override
  void initState() {
    super.initState();
    // ✅ الحصول على الـ Controller الموجود (لأنه تم إنشاؤه في OwnerProfileScreen)
    profileController = Get.find<ProfileController>();

    // ✅ ملء الحقول بالبيانات الحالية
    nameController.text = profileController.userName.value;
    emailController.text = profileController.userEmail.value;
    phoneController.text = profileController.userPhone.value;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> pickProfile() async {
    final img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        profileImage = File(img.path);
      });
    }
  }

  Future<void> saveProfile() async {
    setState(() => loading = true);

    // ✅ استدعاء دالة التحديث من ProfileController
    await profileController.updateProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
    );

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color inputColor =
        isDark ? Colors.white.withOpacity(0.05) : const Color(0xffF1F5F9);
    final Color textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final Color subText = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("تعديل البيانات"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// PROFILE IMAGE
            GestureDetector(
              onTap: pickProfile,
              child: Container(
                width: 115,
                height: 115,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [primary, accent]),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: profileImage != null
                    ? ClipOval(
                        child: Image.file(profileImage!, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.person, color: Colors.white, size: 55),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "اضغط لتغيير الصورة الشخصية",
              style: TextStyle(color: subText, fontSize: 14),
            ),
            const SizedBox(height: 30),

            /// NAME FIELD
            _input(
              nameController,
              "الاسم الكامل",
              Icons.person_outline_rounded,
              inputColor,
              textColor,
              subText,
            ),
            const SizedBox(height: 14),

            /// EMAIL FIELD
            _input(
              emailController,
              "البريد الإلكتروني",
              Icons.email_outlined,
              inputColor,
              textColor,
              subText,
            ),
            const SizedBox(height: 14),

            /// PHONE FIELD
            _input(
              phoneController,
              "رقم الجوال",
              Icons.phone_outlined,
              inputColor,
              textColor,
              subText,
            ),
            const SizedBox(height: 35),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Obx(() => DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [primary, accent]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: (loading || profileController.isUpdating.value)
                          ? null
                          : saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: (loading || profileController.isUpdating.value)
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "حفظ التغييرات",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String hint,
    IconData icon,
    Color fill,
    Color text,
    Color sub,
  ) {
    return TextField(
      controller: controller,
      style: TextStyle(color: text),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: sub),
        hintText: hint,
        hintStyle: TextStyle(color: sub),
        filled: true,
        fillColor: fill,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
