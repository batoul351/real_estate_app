import 'package:flutter/material.dart';

import 'home_tab.dart';
import 'owner_properties_screen.dart';
import 'owner_notifications_screen.dart';
import 'owner_profile_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int index = 0;

  final pages = const [
    HomeTab(),
    OwnerPropertiesScreen(),
    OwnerNotificationsScreen(),
    OwnerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB);

    const primary = Color(0xff1E3A8A);
    const accent = Color(0xff0F766E);

    return Scaffold(
      backgroundColor: bg,

      /// APP BAR (Minimal & clean)
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),

      /// BODY (ONLY PAGES — no extra clutter)
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[index],
      ),

      /// MODERN BOTTOM NAV (clean professional style)
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),

        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,

          borderRadius: BorderRadius.circular(25),

          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [
            _item(Icons.dashboard_rounded, 0),
            _item(Icons.home_work_rounded, 1),
            _item(Icons.notifications_rounded, 2),
            _item(Icons.person_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, int i) {
    final active = index == i;

    return GestureDetector(
      onTap: () => setState(() => index = i),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        padding: const EdgeInsets.all(10),

        decoration: BoxDecoration(
          color: active ? const Color(0xff1E3A8A) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),

        child: Icon(
          icon,
          color: active ? Colors.white : Colors.grey,
          size: active ? 28 : 24,
        ),
      ),
    );
  }
}

