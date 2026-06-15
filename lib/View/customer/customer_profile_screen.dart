import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/profile_controller.dart';
import '../../controller/logout_controller.dart';
import 'edit_customer_profile_screen.dart';
import 'customer_favorites_screen.dart';
import 'customer_properties_screen.dart';
import 'property_data.dart';

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

                  /// CARD INFO
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.20 : 0.06),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        /// ✅ PHONE (من API)
                        _item(
                          icon: Icons.phone,
                          title: profileController.userPhone.value.isEmpty
                              ? "جاري التحميل..."
                              : profileController.userPhone.value,
                          text: text,
                          sub: sub,
                        ),
                        _item(
                          icon: Icons.favorite_rounded,
                          title: "المفضلة (${favoriteProperties.length})",
                          text: text,
                          sub: sub,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const CustomerFavoritesScreen()),
                            ).then((_) {
                              // تحديث عند العودة
                            });
                          },
                        ),
                        _item(
                          icon: Icons.home_work_rounded,
                          title: "العقارات (${properties.length})",
                          text: text,
                          sub: sub,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const CustomerPropertiesScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// STATS
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.20 : 0.06),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              "${favoriteProperties.length}",
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text("المفضلة",
                                style: GoogleFonts.cairo(color: sub)),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "${properties.length}",
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                            Text("العقارات",
                                style: GoogleFonts.cairo(color: sub)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// ✅ EDIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const EditCustomerProfileScreen()),
                        );
                        await profileController
                            .fetchProfile(); // تحديث البيانات
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        "تعديل الملف الشخصي",
                        style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// ✅ LOGOUT BUTTON
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
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: logoutController.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.red, strokeWidth: 2),
                            )
                          : Text(
                              "تسجيل الخروج",
                              style: GoogleFonts.cairo(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required Color text,
    required Color sub,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xff1E3A8A)),
      title: Text(title,
          style: GoogleFonts.cairo(color: text, fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: sub),
      onTap: onTap,
    );
  }
}
