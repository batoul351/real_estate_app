import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/verify_controller.dart';
import '../../Service/theme_service.dart';

class VerifyAccountScreen extends StatelessWidget {
  const VerifyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VerifyController controller = Get.put(VerifyController());

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
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
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
                  child: const Icon(Icons.mark_email_read_rounded,
                      color: Colors.white, size: 55),
                ),
                const SizedBox(height: 25),
                Text("تحقق من حسابك",
                    style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: text)),
                const SizedBox(height: 10),
                Text("أدخل رمز التحقق المكون من 6 أرقام",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 14, color: sub)),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                      6,
                      (index) => SizedBox(
                            width: 48,
                            height: 55,
                            child: TextField(
                              controller: controller.controllers[index],
                              focusNode: controller.focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: text),
                              onChanged: (value) =>
                                  controller.nextField(index, value),
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: isDark
                                            ? Colors.white12
                                            : Colors.black12)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: isDark
                                            ? Colors.white12
                                            : Colors.black12)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: primary, width: 1.5)),
                              ),
                            ),
                          )),
                ),
                const SizedBox(height: 20),
                Obx(() => Text(
                      controller.canResend.value
                          ? "لم يصلك رمز؟ أعد المحاولة"
                          : "إعادة الإرسال بعد ${controller.timerSeconds.value} ثانية",
                      style: GoogleFonts.cairo(color: sub, fontSize: 13),
                    )),
                const SizedBox(height: 10),
                Obx(() => TextButton(
                      onPressed: controller.canResend.value
                          ? () async {
                              await controller.resendCode();
                            }
                          : null,
                      child: Text("إعادة إرسال الرمز",
                          style: GoogleFonts.cairo(
                              color: controller.canResend.value ? accent : sub,
                              fontWeight: FontWeight.w500)),
                    )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.loading.value
                            ? null
                            : () async {
                                await controller.verifyEmail();
                              },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16))),
                        child: controller.loading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text("تأكيد الحساب",
                                style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
