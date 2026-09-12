import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'welcome_screen.dart';
import '../View/owner/owner_home_screen.dart';
import '../View/customer/customer_home_screen.dart';
// أضف import للـ ThemeService حسب مساره عندك:
// import '../Services/theme_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _checkAuthAndNavigate();
    });
  }

  void _checkAuthAndNavigate() {
    final storage = GetStorage();
    final token = storage.read('access_token');
    final userData = storage.read('user_data');

    if (token != null && token.toString().isNotEmpty && userData != null) {
      final String role = userData['role'].toString();
      if (role == 'owner') {
        Get.off(() => const OwnerHomeScreen());
      } else if (role == 'customer') {
        Get.off(() => const CustomerHomeScreen());
      } else {
        Get.off(() => const WelcomeScreen());
      }
    } else {
      Get.off(() => const WelcomeScreen());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 🎨 نفس ألوان ThemeService
    const Color primary = Color(0xff1E3A8A);
    const Color accent = Color(0xff0F766E);

    final Color bg = isDark ? const Color(0xff101828) : const Color(0xffEEF2F7);
    final Color text =
        isDark ? const Color(0xffE6EAF2) : const Color(0xff0F172A);
    final Color sub =
        isDark ? const Color(0xff9AA4B8) : const Color(0xff64748B);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primary, accent],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.45 : 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo1.png',
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.location_city_rounded,
                            color: Colors.white,
                            size: 70,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Haven Syria',
                  style: GoogleFonts.cairo(
                    color: text,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'بيع • شراء • إيجار',
                  style: GoogleFonts.cairo(
                    color: sub,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 60),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: isDark ? Colors.white : primary,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'جاري التحميل...',
                  style: GoogleFonts.cairo(color: sub, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
