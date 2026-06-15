import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'property_data.dart';
import 'property_details_screen.dart';

class CustomerFavoritesScreen extends StatefulWidget {
  const CustomerFavoritesScreen({super.key});

  @override
  State<CustomerFavoritesScreen> createState() =>
      _CustomerFavoritesScreenState();
}

class _CustomerFavoritesScreenState
    extends State<CustomerFavoritesScreen> {

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final bg = isDark
        ? const Color(0xff070B18)
        : const Color(0xffF6F7FB);

    final text = isDark
        ? Colors.white
        : const Color(0xff0F172A);

    final sub = isDark
        ? Colors.white70
        : Colors.black54;

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        iconTheme: IconThemeData(color: text),

        title: Text(
          "المفضلة",
          style: GoogleFonts.cairo(
            color: text,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: favoriteProperties.isEmpty

          ? Center(
              child: Text(
                "لا يوجد عقارات بالمفضلة",
                style: GoogleFonts.cairo(
                  color: sub,
                  fontSize: 16,
                ),
              ),
            )

          : ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: favoriteProperties.length,

              itemBuilder: (context, index) {

                final property =
                    favoriteProperties[index];

                return Container(
                  margin:
                      const EdgeInsets.only(bottom: 14),

                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white,

                    borderRadius:
                        BorderRadius.circular(20),

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
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),

                    leading: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),

                    title: Text(
                      property.title,

                      style: GoogleFonts.cairo(
                        color: text,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      "${property.city} - ${property.price}\$",

                      style: GoogleFonts.cairo(
                        color: sub,
                      ),
                    ),

                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: sub,
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PropertyDetailsScreen(
                            property: property,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}