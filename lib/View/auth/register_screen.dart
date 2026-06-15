// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/register_controller.dart';
import '../../Service/theme_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final RegisterController controller;

  final primary = const Color(0xff1E3A8A);
  final accent = const Color(0xff0F766E);

  @override
  void initState() {
    super.initState();
    controller = Get.put(RegisterController());

    // استقبال الدور من arguments
    if (Get.arguments != null && Get.arguments['role'] != null) {
      controller.setRole(Get.arguments['role']);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.find<ThemeService>();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB);
    final Color text = isDark ? Colors.white : const Color(0xff0F172A);
    final Color sub = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: text,
          ),
          onPressed: () {
            themeService.toggleTheme();
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                /// ICON
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [primary, accent]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_add_alt_rounded,
                      color: Colors.white, size: 45),
                ),
                const SizedBox(height: 18),

                /// عنوان
                Text(
                  "إنشاء حساب جديد",
                  style: GoogleFonts.cairo(
                      fontSize: 26, fontWeight: FontWeight.bold, color: text),
                ),
                const SizedBox(height: 6),
                Text(
                  "أدخل بياناتك لإنشاء حسابك",
                  style: GoogleFonts.cairo(fontSize: 14, color: sub),
                ),
                const SizedBox(height: 30),

                /// الفورم
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color:
                        isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12),
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
                        controller: controller.nameController,
                        icon: Icons.person_rounded,
                        hint: "الاسم الكامل",
                        isDark: isDark,
                        text: text,
                        sub: sub,
                      ),
                      const SizedBox(height: 12),

                      _field(
                        controller: controller.phoneController,
                        icon: Icons.phone_rounded,
                        hint: "رقم الجوال",
                        isDark: isDark,
                        text: text,
                        sub: sub,
                      ),
                      const SizedBox(height: 12),

                      _field(
                        controller: controller.emailController,
                        icon: Icons.email_rounded,
                        hint: "البريد الإلكتروني",
                        isDark: isDark,
                        text: text,
                        sub: sub,
                      ),
                      const SizedBox(height: 12),

                      Obx(() => _passwordField(
                            controller: controller.passController,
                            hint: "كلمة المرور",
                            obscure: controller.obscurePassword.value,
                            onToggle: controller.toggleObscurePassword,
                            isDark: isDark,
                            text: text,
                            sub: sub,
                          )),
                      const SizedBox(height: 12),

                      Obx(() => _passwordField(
                            controller: controller.confirmController,
                            hint: "تأكيد كلمة المرور",
                            obscure: controller.obscureConfirm.value,
                            onToggle: controller.toggleObscureConfirm,
                            isDark: isDark,
                            text: text,
                            sub: sub,
                          )),
                      const SizedBox(height: 18),

                      /// اختيار الدور (نوع المستخدم)
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => RadioListTile<String>(
                                  title: Text("مالك عقار",
                                      style: GoogleFonts.cairo(color: text)),
                                  value: 'owner',
                                  groupValue: controller.selectedRole.value,
                                  onChanged: (value) =>
                                      controller.setRole(value!),
                                  activeColor: primary,
                                  contentPadding: EdgeInsets.zero,
                                )),
                          ),
                          Expanded(
                            child: Obx(() => RadioListTile<String>(
                                  title: Text("عميل",
                                      style: GoogleFonts.cairo(color: text)),
                                  value: 'customer',
                                  groupValue: controller.selectedRole.value,
                                  onChanged: (value) =>
                                      controller.setRole(value!),
                                  activeColor: primary,
                                  contentPadding: EdgeInsets.zero,
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      /// زر إنشاء الحساب
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.loading.value
                                  ? null
                                  : () async {
                                      await controller.register();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: controller.loading.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : Text("إنشاء الحساب",
                                      style: GoogleFonts.cairo(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                /// تسجيل الدخول
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("لديك حساب؟ ", style: GoogleFonts.cairo(color: sub)),
                    TextButton(
                      onPressed: () => Get.offAllNamed('/login'),
                      child: Text("تسجيل الدخول",
                          style: GoogleFonts.cairo(
                              color: text, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// TEXT FIELD
  Widget _field({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
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
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// PASSWORD FIELD
  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required bool isDark,
    required Color text,
    required Color sub,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: text),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_rounded, color: sub),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
              color: sub),
        ),
        hintText: hint,
        hintStyle: TextStyle(color: sub),
        filled: true,
        fillColor:
            isDark ? Colors.white.withOpacity(0.05) : const Color(0xffF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
