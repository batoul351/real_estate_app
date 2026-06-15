import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerNotificationsScreen extends StatelessWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg =
        isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB);

    final text =
        isDark ? Colors.white : const Color(0xff0F172A);

    final sub =
        isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Text(
          "الإشعارات",
          style: GoogleFonts.cairo(
            color: text,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: IconThemeData(
          color: text,
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          _notificationCard(
            isDark: isDark,
            text: text,
            sub: sub,
            iconColor: Colors.blue,
            title: "تم إضافة عقار جديد",
            subtitle: "شقة جديدة في دمشق",
          ),

          const SizedBox(height: 12),

          _notificationCard(
            isDark: isDark,
            text: text,
            sub: sub,
            iconColor: Colors.green,
            title: "انخفاض سعر عقار",
            subtitle: "فيلا في ريف دمشق",
          ),
        ],
      ),
    );
  }

  Widget _notificationCard({
    required bool isDark,
    required Color text,
    required Color sub,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white,

        borderRadius: BorderRadius.circular(20),

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
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: ListTile(
        contentPadding: EdgeInsets.zero,

        leading: Icon(
          Icons.notifications,
          color: iconColor,
          size: 30,
        ),

        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: text,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: GoogleFonts.cairo(
            color: sub,
          ),
        ),
      ),
    );
  }
}