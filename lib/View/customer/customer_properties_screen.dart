import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/customer_search_controller.dart';
import '../../controller/customer_favorites_controller.dart';
import '../../Service/theme_service.dart';
import 'property_details_screen.dart';

class CustomerPropertiesScreen extends StatelessWidget {
  const CustomerPropertiesScreen({super.key});

  static const Color primary = Color(0xff1E3A8A);

  final List<String> propertyTypes = const [
    'الكل',
    'apartment',
    'villa',
    'land',
    'farm',
    'shop',
    'office',
  ];

  final List<String> offerTypes = const [
    'الكل',
    'sale',
    'rent',
  ];

  @override
  Widget build(BuildContext context) {
    final CustomerSearchController searchController =
        Get.find<CustomerSearchController>();
    final CustomerFavoritesController favoritesController =
        Get.find<CustomerFavoritesController>();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xff070B18) : const Color(0xffF7F8FA);
    final Color text = isDark ? Colors.white : const Color(0xff0F172A);
    final Color subText = isDark ? Colors.white60 : Colors.black54;
    final Color cardColor = isDark ? const Color(0xff111827) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'العقارات',
          style: GoogleFonts.cairo(
              color: text, fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // ============================================================
          // ✅ صف واحد فقط: نوع العرض (الأهم) + زر فلاتر إضافية
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: offerTypes.map((type) {
                            final isSelected =
                                searchController.selectedOfferType.value ==
                                    type;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    searchController.setOfferType(type),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _getOfferTypeLabel(type),
                                    style: GoogleFonts.cairo(
                                      color: isSelected ? Colors.white : text,
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )),
                ),
                const SizedBox(width: 10),
                Obx(() {
                  final hasExtra =
                      (searchController.selectedType.value.isNotEmpty &&
                              searchController.selectedType.value != 'الكل') ||
                          searchController.selectedRegion.value.isNotEmpty ||
                          searchController.minPrice.value > 0 ||
                          searchController.maxPrice.value < 1000000000;
                  return InkWell(
                    onTap: () => _openFiltersSheet(context, searchController),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 44,
                      decoration: BoxDecoration(
                        color: hasExtra
                            ? primary
                            : (isDark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.tune_rounded,
                              color: hasExtra ? Colors.white : text, size: 21),
                          if (hasExtra)
                            const Positioned(
                              top: 8,
                              right: 10,
                              child: CircleAvatar(
                                  radius: 3.5,
                                  backgroundColor: Colors.orangeAccent),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // ============================================================
          // ✅ القائمة - عرض بسيط وواضح، صف واحد لكل عقار
          // ============================================================
          Expanded(
            child: Obx(() {
              if (searchController.isLoading.value &&
                  searchController.searchResults.isEmpty) {
                return Center(child: CircularProgressIndicator(color: primary));
              }

              if (searchController.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: subText),
                      const SizedBox(height: 12),
                      Text('لا توجد نتائج',
                          style: GoogleFonts.cairo(
                              color: text,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => searchController.resetFilters(),
                        child: Text('إعادة تعيين الفلاتر',
                            style: GoogleFonts.cairo(
                                color: primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: searchController.refreshSearch,
                color: primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: searchController.searchResults.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final property = searchController.searchResults[index];
                    final imageUrl = property['images'] != null &&
                            property['images'].isNotEmpty
                        ? '${searchController.baseUrl}/storage/${property['images'][0]['url']}'
                        : '';
                    final isFav =
                        favoritesController.isFavorite(property['id']);

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Get.to(
                          () => PropertyDetailsScreen(property: property)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3)),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 90,
                                        height: 90,
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.broken_image,
                                            color: Colors.grey),
                                      ),
                                    )
                                  : Container(
                                      width: 90,
                                      height: 90,
                                      color: Colors.grey.shade200,
                                      child: Icon(Icons.home_rounded,
                                          color: Colors.grey.shade400,
                                          size: 32),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    property['title'] ?? 'بدون عنوان',
                                    style: GoogleFonts.cairo(
                                        color: text,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    property['region'] ?? '',
                                    style: GoogleFonts.cairo(
                                        color: subText, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${_formatPrice(property['price_sp'] ?? 0)} ل.س',
                                    style: GoogleFonts.cairo(
                                        color: primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFav ? Colors.red : subText,
                              ),
                              onPressed: () async {
                                if (isFav) {
                                  await favoritesController
                                      .removeFromFavorites(property['id']);
                                } else {
                                  await favoritesController
                                      .addToFavorites(property['id']);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ✅ شيت فلاتر إضافية - بسيط، خيار واحد لكل سطر
  // ============================================================
  void _openFiltersSheet(
      BuildContext context, CustomerSearchController searchController) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color text = isDark ? Colors.white : const Color(0xff0F172A);
    final Color subText = isDark ? Colors.white60 : Colors.black54;
    final Color chipBg =
        isDark ? Colors.white.withOpacity(0.06) : const Color(0xffF1F2F6);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xff111827) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text('فلاتر إضافية',
                            style: GoogleFonts.cairo(
                                color: text,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => searchController.resetFilters(),
                          child: Text('مسح الكل',
                              style: GoogleFonts.cairo(
                                  color: Colors.red.shade400, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          Text('نوع العقار',
                              style: GoogleFonts.cairo(
                                  color: text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          Obx(() => Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: propertyTypes.map((type) {
                                  final isSelected =
                                      searchController.selectedType.value ==
                                          type;
                                  return GestureDetector(
                                    onTap: () =>
                                        searchController.setPropertyType(type),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 9),
                                      decoration: BoxDecoration(
                                        color: isSelected ? primary : chipBg,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _getPropertyTypeLabel(type),
                                        style: GoogleFonts.cairo(
                                          color:
                                              isSelected ? Colors.white : text,
                                          fontSize: 12.5,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )),
                          const SizedBox(height: 22),
                          Text('المنطقة',
                              style: GoogleFonts.cairo(
                                  color: text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          Obx(() => DropdownButtonFormField<String>(
                                value: searchController
                                        .selectedRegion.value.isEmpty
                                    ? null
                                    : searchController.selectedRegion.value,
                                hint: Text('كل المناطق',
                                    style: GoogleFonts.cairo(
                                        color: subText, fontSize: 13)),
                                items: searchController.regionsList
                                    .map((region) => DropdownMenuItem(
                                        value: region,
                                        child: Text(region,
                                            style: GoogleFonts.cairo(
                                                color: text, fontSize: 13))))
                                    .toList(),
                                onChanged: (value) => searchController
                                    .setSelectedRegion(value ?? ''),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: chipBg,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                                dropdownColor: isDark
                                    ? const Color(0xff1F2937)
                                    : Colors.white,
                                style: GoogleFonts.cairo(color: text),
                              )),
                          const SizedBox(height: 22),
                          Text('السعر (ل.س)',
                              style: GoogleFonts.cairo(
                                  color: text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          Obx(() => RangeSlider(
                                min: 0,
                                max: 1000000000,
                                values: RangeValues(
                                  searchController.minPrice.value.toDouble(),
                                  searchController.maxPrice.value.toDouble(),
                                ),
                                onChanged: (values) =>
                                    searchController.setPriceRange(
                                        values.start.toInt(),
                                        values.end.toInt()),
                                activeColor: primary,
                              )),
                          Obx(() => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      _formatPrice(
                                          searchController.minPrice.value),
                                      style: GoogleFonts.cairo(
                                          color: subText, fontSize: 12)),
                                  Text(
                                      _formatPrice(
                                          searchController.maxPrice.value),
                                      style: GoogleFonts.cairo(
                                          color: subText, fontSize: 12)),
                                ],
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Obx(() => Text(
                              'عرض ${searchController.searchResults.length} نتيجة',
                              style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            )),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getPropertyTypeLabel(String type) {
    const map = {
      'apartment': 'شقة',
      'villa': 'فيلا',
      'land': 'أرض',
      'farm': 'مزرعة',
      'shop': 'محل',
      'office': 'مكتب',
      'الكل': 'الكل',
    };
    return map[type] ?? type;
  }

  String _getOfferTypeLabel(String type) {
    const map = {
      'sale': 'بيع',
      'rent': 'إيجار',
      'الكل': 'الكل',
    };
    return map[type] ?? type;
  }

  String _formatPrice(int price) {
    if (price >= 1000000000) {
      return '${(price / 1000000000).toStringAsFixed(1)}م';
    } else if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(0)}م';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}أ';
    }
    return price.toString();
  }
}
