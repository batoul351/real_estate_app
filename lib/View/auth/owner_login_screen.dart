import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/login_controller.dart';
import '../../Service/theme_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();
    final ThemeService themeService = Get.find<ThemeService>();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB);
    final Color text = isDark ? Colors.white : const Color(0xff0F172A);
    final Color sub = isDark ? Colors.white70 : Colors.black54;
    const Color primary = Color(0xff1E3A8A);
    const Color accent = Color(0xff0F766E);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: text),
          onPressed: () => themeService.toggleTheme(),
        ),
        title: Text(
          "تسجيل الدخول",
          style: GoogleFonts.cairo(color: text, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
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
                  child: const Icon(Icons.home_work_rounded,
                      color: Colors.white, size: 45),
                ),
                const SizedBox(height: 18),
                Text("مرحباً بعودتك",
                    style: GoogleFonts.cairo(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: text)),
                const SizedBox(height: 6),
                Text("سجّل الدخول للوصول إلى حسابك",
                    style: GoogleFonts.cairo(fontSize: 14, color: sub)),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color:
                        isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: controller.emailController,
                        style: TextStyle(color: text),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email_rounded, color: sub),
                          hintText: "البريد الإلكتروني",
                          hintStyle: TextStyle(color: sub),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withOpacity(0.05)
                              : const Color(0xffF1F5F9),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => TextField(
                            controller: controller.passController,
                            obscureText: controller.obscurePassword.value,
                            style: TextStyle(color: text),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_rounded, color: sub),
                              suffixIcon: IconButton(
                                onPressed: controller.toggleObscure,
                                icon: Icon(
                                    controller.obscurePassword.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: sub),
                              ),
                              hintText: "كلمة المرور",
                              hintStyle: TextStyle(color: sub),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : const Color(0xffF1F5F9),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none),
                            ),
                          )),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed('/forgot-password'),
                          child: Text("نسيت كلمة المرور؟",
                              style: GoogleFonts.cairo(color: sub)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.loading.value
                                  ? null
                                  : () async {
                                      await controller.login();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: controller.loading.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : Text("تسجيل الدخول",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("ليس لديك حساب؟ ",
                        style: GoogleFonts.cairo(color: sub)),
                    TextButton(
                      onPressed: () => Get.toNamed('/register'),
                      child: Text("إنشاء حساب",
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
}
