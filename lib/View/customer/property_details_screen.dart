import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'property_data.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailsScreen({
    super.key,
    required this.property,
  });

  Future<void> makePhoneCall(String phone) async {
    final Uri url = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final bg =
        isDark ? const Color(0xff070B18) : const Color(0xffF6F7FB);

    final text =
        isDark ? Colors.white : const Color(0xff0F172A);

    final sub =
        isDark ? Colors.white70 : Colors.black54;

    const primary = Color(0xff1E3A8A);
    const accent = Color(0xff0F766E);

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: text),
      ),

      body: ListView(
        children: [

          /// IMAGES
          SizedBox(
            height: 300,

            child: PageView.builder(
              itemCount: property.images.length,

              itemBuilder: (_, index) {
                return Stack(
                  fit: StackFit.expand,

                  children: [

                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),

                      child: Image.network(
                        property.images[index],
                        fit: BoxFit.cover,
                      ),
                    ),

                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),

                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,

                          colors: [
                            Colors.black54,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                /// TITLE
                Text(
                  property.title,

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: text,
                  ),
                ),

                const SizedBox(height: 15),

                /// PRICE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    "${property.price} \$",

                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// CARD
                Container(
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white,

                    borderRadius: BorderRadius.circular(24),

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

                  child: Column(
                    children: [

                      Row(
                        children: [

                          const Icon(
                            Icons.location_on_rounded,
                            color: primary,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              property.city,

                              style: TextStyle(
                                color: sub,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [

                          const Icon(
                            Icons.home_work_rounded,
                            color: accent,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              property.type,

                              style: TextStyle(
                                color: sub,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// DESCRIPTION TITLE
                Text(
                  "تفاصيل العقار",

                  style: TextStyle(
                    color: text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                /// DESCRIPTION CARD
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white,

                    borderRadius: BorderRadius.circular(24),

                    border: Border.all(
                      color: isDark
                          ? Colors.white12
                          : Colors.black12,
                    ),
                  ),

                  child: Text(
                    property.description,

                    style: TextStyle(
                      color: sub,
                      height: 1.8,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                /// CALL BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      makePhoneCall(property.phone);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),

                    icon: const Icon(
                      Icons.phone_rounded,
                      color: Colors.white,
                    ),

                    label: Text(
                      "اتصال على ${property.phone}",

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}