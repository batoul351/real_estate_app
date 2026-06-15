import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../View/auth/register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController pageController = PageController();
  int currentPage = 0;
  late Timer autoSlider;

  final List<Map<String, String>> pages = [
    {
      "title": "اكتشف عقارات دمشق",
      "desc": "أفضل الشقق والفلل والمكاتب العقارية ضمن تجربة حديثة وفاخرة",
    },
    {
      "title": "ابحث بسهولة",
      "desc": "فلترة ذكية حسب المنطقة والسعر ونوع العقار مع تفاصيل كاملة",
    },
    {
      "title": "تواصل مباشرة",
      "desc": "تواصل مع المكاتب العقارية عبر الاتصال أو الواتساب بسهولة",
    },
  ];

  @override
  void initState() {
    super.initState();

    autoSlider = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (currentPage < pages.length - 1) {
        currentPage++;
        pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    autoSlider.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xff1E3A8A);
    const Color accent = Color(0xff0F766E);
    const Color darkBg = Color(0xff030614); // ✅ أغمق بكثير (أسود مائل للأزرق)

    return Scaffold(
      backgroundColor: darkBg,
      body: PageView.builder(
        controller: pageController,
        onPageChanged: (value) {
          setState(() {
            currentPage = value;
          });
        },
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              /// خلفية متدرجة داكنة جداً
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary.withOpacity(0.7),
                      accent.withOpacity(0.6),
                      darkBg,
                      darkBg,
                    ],
                  ),
                ),
              ),

              /// زخارف داكنة جداً
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                top: -30,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                right: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                bottom: -50,
                left: -50,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.015),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                bottom: 80,
                right: -20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              /// المحتوى الرئيسي
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 25,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Skip Button
                      Align(
                        alignment: Alignment.topRight,
                        child: currentPage != pages.length - 1
                            ? TextButton(
                                onPressed: () {
                                  pageController.animateToPage(
                                    currentPage + 1,
                                    duration: const Duration(milliseconds: 700),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                  child: Text(
                                    "تخطي",
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ),
                      const Spacer(),

                      /// Icon
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 95,
                              height: 95,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primary, accent],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_city_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),

                      /// Title
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Text(
                                pages[index]['title']!,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 15,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      /// Description
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 15 * (1 - value)),
                              child: Text(
                                pages[index]['desc']!,
                                style: GoogleFonts.cairo(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const Spacer(),

                      /// Page Indicator
                      Row(
                        children: List.generate(pages.length, (dotIndex) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            margin: const EdgeInsets.only(right: 8),
                            width: currentPage == dotIndex ? 35 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: currentPage == dotIndex
                                  ? accent
                                  : Colors.white12,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),

                      /// Start Button
                      if (currentPage == pages.length - 1)
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, double value, child) {
                            return Transform.scale(
                              scale: value,
                              child: SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.off(() => const RegisterScreen());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    elevation: 10,
                                    shadowColor: primary.withOpacity(0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    "ابدأ الآن",
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
