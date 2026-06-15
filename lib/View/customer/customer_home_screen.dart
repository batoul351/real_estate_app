import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'customer_home_tab.dart';
import 'customer_properties_screen.dart';
import 'customer_favorites_screen.dart';
import 'customer_profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() =>
      _CustomerHomeScreenState();
}

class _CustomerHomeScreenState
    extends State<CustomerHomeScreen> {

  int index = 0;

  final pages = const [
    CustomerHomeTab(),
    CustomerPropertiesScreen(),
    CustomerFavoritesScreen(),
    CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final bg = isDark
        ? const Color(0xff070B18)
        : const Color(0xffF6F7FB);

    final text = isDark
        ? Colors.white
        : const Color(0xff0F172A);

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,

        iconTheme: IconThemeData(
          color: text,
        ),

        title: Text(
          "Real Estate",

          style: GoogleFonts.cairo(
            color: text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 16,
            ),

            child: Icon(
              Icons.notifications_none_rounded,
              color: text,
            ),
          ),
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(
          milliseconds: 300,
        ),
        child: pages[index],
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),

        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.white,

          borderRadius:
              BorderRadius.circular(25),

          border: Border.all(
            color: isDark
                ? Colors.white12
                : Colors.black12,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                isDark ? 0.20 : 0.06,
              ),

              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,

          children: [

            _item(
              Icons.home_rounded,
              0,
            ),

            _item(
              Icons.home_work_rounded,
              1,
            ),

            _item(
              Icons.favorite_rounded,
              2,
            ),

            _item(
              Icons.person_rounded,
              3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    int i,
  ) {

    final active = index == i;

    return GestureDetector(
      onTap: () {
        setState(() {
          index = i;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 250,
        ),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: active
              ? const Color(0xff1E3A8A)
              : Colors.transparent,

          borderRadius:
              BorderRadius.circular(14),
        ),

        child: Icon(
          icon,

          color: active
              ? Colors.white
              : Colors.grey,

          size: active ? 28 : 24,
        ),
      ),
    );
  }
}