import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primary = const Color(0xff1E3A8A);
    final accent = const Color(0xff0F766E);

    final bgCard = isDark ? const Color(0xff0D1224) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0F172A);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("شروط الاستخدام"),
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
                  "شروط الاستخدام",
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
باستخدامك لهذا التطبيق فإنك توافق على الشروط التالية:

• يجب إدخال بيانات صحيحة ودقيقة عند استخدام التطبيق.

• يُمنع استخدام التطبيق لأي غرض غير قانوني أو مخالف للأنظمة.

• المستخدم مسؤول بشكل كامل عن جميع المحتويات التي يقوم بإضافتها.

• تحتفظ إدارة التطبيق بحق حذف أو تعديل أي محتوى مخالف دون إشعار مسبق.

• يحق للإدارة إيقاف أو تعليق أي حساب مخالف للشروط.

• التطبيق يعمل كوسيط تقني فقط ولا يتحمل مسؤولية أي اتفاقات خارجية بين المستخدمين.

• قد يتم تحديث هذه الشروط في أي وقت، واستمرار استخدام التطبيق يعني الموافقة على التحديثات.

باستخدامك للتطبيق فإنك تقر بأنك قرأت وفهمت ووافقت على جميع الشروط المذكورة.
                  """,

                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    height: 2.0,
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

