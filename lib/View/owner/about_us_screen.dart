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
                  "Haven Syria 🏡",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 24,
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
Haven Syria منصة عقارية ذكية ومتخصصة في إدارة وعرض العقارات بطريقة حديثة وسهلة وآمنة.

🎯 هدفنا:
تسهيل عملية التواصل بين مالك العقار والمكتب العقاري، وأيضاً بين العميل (الزبون) والمكتب العقاري، من خلال تجربة استخدام احترافية وسريعة.

👤 للزبون (العميل):
• تصفح العقارات المتاحة بسهولة
• البحث والفلترة حسب المنطقة والسعر والنوع
• إضافة العقارات إلى المفضلة لمتابعتها
• التواصل المباشر مع المكاتب العقارية

🏠 لمالك العقار:
• إضافة عقاراته بسهولة
• متابعة حالة الطلبات لحظة بلحظة
• استعراض حالة العقار بشكل مباشر

📋 ميزات التطبيق:
• واجهة بسيطة وسهلة الاستخدام
• بحث متقدم وفلترة ذكية
• صور عالية الجودة للعقارات
• إشعارات فورية بحالة الطلبات
• حفظ العقارات المفضلة

🌟 رؤيتنا:
تقديم تجربة عقارية ذكية تساعد الجميع (مالكي العقارات، العملاء، والمكاتب العقارية) على إدارة عقاراتهم بسهولة وموثوقية في سوريا.

🤝 نعمل دائماً على تطوير خدماتنا وتحسين جودة النظام لضمان أفضل تجربة ممكنة لجميع المستخدمين.
                  """,
                  style: GoogleFonts.cairo(
                    fontSize: 17,
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
