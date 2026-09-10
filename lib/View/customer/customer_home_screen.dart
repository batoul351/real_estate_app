import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/customer_property_controller.dart';
import '../../controller/customer_favorites_controller.dart';
import '../../controller/customer_search_controller.dart';
import '../../Service/theme_service.dart';
import 'customer_home_tab.dart';
import 'customer_properties_screen.dart';
import 'customer_favorites_screen.dart';
import 'customer_profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    // ✅ تسجيل جميع الـ Controllers
    if (!Get.isRegistered<CustomerPropertyController>()) {
      Get.put<CustomerPropertyController>(
        CustomerPropertyController(),
        permanent: true,
      );
    }
    if (!Get.isRegistered<CustomerFavoritesController>()) {
      Get.put<CustomerFavoritesController>(
        CustomerFavoritesController(),
        permanent: true,
      );
    }
    if (!Get.isRegistered<CustomerSearchController>()) {
      Get.put<CustomerSearchController>(
        CustomerSearchController(),
        permanent: true,
      );
    }

    // ✅ جلب البيانات بعد بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<CustomerPropertyController>();
      controller.fetchProperties();
    });

    pages = const [
      CustomerHomeTab(),
      CustomerPropertiesScreen(),
      CustomerFavoritesScreen(),
      CustomerProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.find<ThemeService>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB);
    final Color text = isDark ? Colors.white : const Color(0xff0F172A);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: text),
        leading: IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: text,
          ),
          onPressed: () => themeService.toggleTheme(),
        ),
        title: Text(
          "Haven Syria",
          style: GoogleFonts.cairo(
            color: text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
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
            _buildNavItem(Icons.home_rounded, 0, isDark),
            _buildNavItem(Icons.home_work_rounded, 1, isDark),
            _buildNavItem(Icons.favorite_rounded, 2, isDark),
            _buildNavItem(Icons.person_rounded, 3, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, bool isDark) {
    final bool isActive = currentIndex == index;
    const Color primary = Color(0xff1E3A8A);

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: isActive
              ? Colors.white
              : (isDark ? Colors.grey : Colors.grey.shade600),
          size: isActive ? 28 : 24,
        ),
      ),
    );
  }
}
