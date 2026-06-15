import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/forgot_password_controller.dart';
import '../../Service/theme_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller =
        Get.find<ForgotPasswordController>();

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
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [primary, accent]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Obx(() => Icon(
                        controller.codeSent.value
                            ? Icons.password_rounded
                            : Icons.lock_reset_rounded,
                        color: Colors.white,
                        size: 45,
                      )),
                ),
                const SizedBox(height: 18),

                Text(
                  "إعادة تعيين كلمة المرور",
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: text,
                  ),
                ),
                const SizedBox(height: 6),

                Obx(() => Text(
                      controller.codeSent.value
                          ? "أدخل الرمز وكلمة المرور الجديدة"
                          : "أدخل بريدك الإلكتروني",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 14, color: sub),
                    )),
                const SizedBox(height: 30),

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
                  child: Obx(() => Column(
                        children: [
                          if (!controller.codeSent.value) ...[
                            _field(
                              controller: controller.emailController,
                              hint: "البريد الإلكتروني",
                              icon: Icons.email_rounded,
                              isDark: isDark,
                              text: text,
                              sub: sub,
                            ),
                            const SizedBox(height: 20),
                            _button(
                              text: "إرسال الرمز",
                              loading: controller.loading.value,
                              onPressed: () async {
                                await controller.sendResetCode();
                              },
                              primary: primary,
                            ),
                          ],
                          if (controller.codeSent.value) ...[
                            _field(
                              controller: controller.codeController,
                              hint: "رمز التحقق",
                              icon: Icons.pin,
                              isDark: isDark,
                              text: text,
                              sub: sub,
                            ),
                            const SizedBox(height: 12),
                            _passwordField(
                              controller: controller.newPasswordController,
                              hint: "كلمة المرور الجديدة",
                              obscure: controller.obscureNewPassword,
                              onToggle: controller.toggleNewPassword,
                              isDark: isDark,
                              text: text,
                              sub: sub,
                            ),
                            const SizedBox(height: 12),
                            _passwordField(
                              controller: controller.confirmPasswordController,
                              hint: "تأكيد كلمة المرور",
                              obscure: controller.obscureConfirmPassword,
                              onToggle: controller.toggleConfirmPassword,
                              isDark: isDark,
                              text: text,
                              sub: sub,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: Obx(() => ElevatedButton(
                                    onPressed: controller.loading.value
                                        ? null
                                        : () async {
                                            await controller.resetPassword();
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: controller.loading.value
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            "تغيير كلمة المرور",
                                            style: GoogleFonts.cairo(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  )),
                            ),
                            const SizedBox(height: 10),
                            Obx(() => Text(
                                  controller.canResend.value
                                      ? "لم يصلك رمز؟ أعد المحاولة"
                                      : "إعادة الإرسال بعد ${controller.timerSeconds.value} ثانية",
                                  style: GoogleFonts.cairo(
                                      color: sub, fontSize: 13),
                                )),
                            Obx(() => TextButton(
                                  onPressed: controller.canResend.value
                                      ? () async {
                                          await controller.sendResetCode();
                                        }
                                      : null,
                                  child: Text(
                                    "إعادة إرسال الرمز",
                                    style: GoogleFonts.cairo(
                                      color: controller.canResend.value
                                          ? accent
                                          : sub,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )),
                          ],
                        ],
                      )),
                ),
                const SizedBox(height: 18),

                // ✅ Get.back() بدلاً من Get.offAllNamed
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    "العودة لتسجيل الدخول",
                    style: GoogleFonts.cairo(color: sub),
                  ),
                ),
              ],
            ),
          ),
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
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required RxBool obscure,
    required VoidCallback onToggle,
    required bool isDark,
    required Color text,
    required Color sub,
  }) {
    return Obx(() => TextField(
          controller: controller,
          obscureText: obscure.value,
          style: TextStyle(color: text),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_rounded, color: sub),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                  obscure.value ? Icons.visibility_off : Icons.visibility,
                  color: sub),
            ),
            hintText: hint,
            hintStyle: TextStyle(color: sub),
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.05)
                : const Color(0xffF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ));
  }

  Widget _button({
    required String text,
    required bool loading,
    required VoidCallback onPressed,
    required Color primary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                text,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
