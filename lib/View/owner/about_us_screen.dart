import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const primary = Color(0xff1E3A8A);
    const accent = Color(0xff0F766E);

    final bgCard = isDark ? const Color(0xff0D1224) : Colors.white;

    final textColor = isDark ? Colors.white : const Color(0xff0F172A);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("من نحن"),
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
              /// HEADER
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [primary, accent]),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  "مكتب الحسن للعقارات",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /// CONTENT
              Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(22),

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
مكتب الحسن للعقارات هو منصة متخصصة في إدارة وعرض العقارات بطريقة حديثة وسهلة وآمنة.

نهدف إلى تسهيل عملية التواصل بين مالك العقار والمكتب العقاري من خلال تجربة استخدام احترافية وسريعة.

يوفر التطبيق إمكانية إضافة العقارات، متابعة الطلبات، واستعراض حالة العقار بشكل مباشر.

رؤيتنا هي تقديم تجربة عقارية ذكية تساعد المستخدمين على إدارة عقاراتهم بسهولة وموثوقية.

نعمل دائماً على تطوير خدماتنا وتحسين جودة النظام لضمان أفضل تجربة ممكنة لجميع المستخدمين.
                  """,

                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    height: 2,
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
