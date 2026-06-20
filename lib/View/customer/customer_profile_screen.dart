import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/profile_controller.dart';
import '../../controller/logout_controller.dart';
import 'edit_customer_profile_screen.dart';
import '../../View/owner/privacy_policy_screen.dart';
import '../../View/owner/about_us_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ جلب الـ Controllers
    final ProfileController profileController = Get.put(ProfileController());
    final LogoutController logoutController = Get.put(LogoutController());

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
        title: Text(
          "الملف الشخصي",
          style: GoogleFonts.cairo(color: text, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Obx(() => Column(
                children: [
                  const SizedBox(height: 15),

                  /// AVATAR
                  Container(
                    width: 110,
                    height: 110,
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
                    child:
                        const Icon(Icons.person, size: 55, color: Colors.white),
                  ),
                  const SizedBox(height: 18),

                  /// ✅ NAME (من API)
                  Text(
                    profileController.userName.value.isEmpty
                        ? "جاري التحميل..."
                        : profileController.userName.value,
                    style: GoogleFonts.cairo(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 4),

                  /// ✅ EMAIL (من API)
                  Text(
                    profileController.userEmail.value.isEmpty
                        ? "جاري التحميل..."
                        : profileController.userEmail.value,
                    style: GoogleFonts.cairo(color: sub, fontSize: 14),
                  ),
                  const SizedBox(height: 30),

                  /// ✅ EDIT BUTTON (زر تعديل الملف الشخصي)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditCustomerProfileScreen(),
                          ),
                        );
                        await profileController.fetchProfile();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "تعديل الملف الشخصي",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// ✅ PRIVACY POLICY BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.to(() => const PrivacyPolicyScreen());
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "سياسة الخصوصية",
                        style: GoogleFonts.cairo(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// ✅ ABOUT US BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.to(() => const AboutUsScreen());
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: accent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "من نحن",
                        style: GoogleFonts.cairo(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// ✅ LOGOUT BUTTON (زر تسجيل الخروج)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: logoutController.isLoading.value
                          ? null
                          : () async {
                              await logoutController.logout();
                            },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: logoutController.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "تسجيل الخروج",
                              style: GoogleFonts.cairo(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
