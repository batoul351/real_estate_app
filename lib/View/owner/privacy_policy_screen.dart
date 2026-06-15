import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primary = const Color(0xff1E3A8A);
    final accent = const Color(0xff0F766E);

    final bgCard = isDark ? const Color(0xff0D1224) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);
    final subText = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("سياسة الخصوصية"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Directionality(
        textDirection: TextDirection.rtl,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// HEADER CARD
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary, accent]),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  "سياسة الخصوصية",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// CONTENT CARD
              Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: Text(
                  """
نحن نحترم خصوصيتك بشكل كامل.

• نقوم بجمع بيانات أساسية فقط مثل الاسم ورقم الهاتف والبريد الإلكتروني وذلك بهدف تحسين تجربة المستخدم داخل التطبيق.

• لا نقوم بمشاركة أي بيانات شخصية مع أي جهة خارجية تحت أي ظرف، إلا في حال وجود طلب قانوني رسمي.

• يتم تخزين جميع البيانات داخل أنظمة آمنة ومشفرة لضمان أعلى مستوى من الحماية.

• يمكن للمستخدم تعديل أو حذف بياناته في أي وقت من خلال إعدادات الحساب داخل التطبيق.

• باستخدامك لهذا التطبيق فإنك توافق على جميع بنود سياسة الخصوصية المذكورة أعلاه.

نحن نعمل باستمرار على تحسين مستوى الأمان والخصوصية لضمان أفضل تجربة ممكنة لك.
                  """,

                  style: GoogleFonts.cairo(
                    fontSize: 18, // 🔥 تكبير النص بشكل واضح
                    height: 2.0, // تباعد مريح جداً للقراءة
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

