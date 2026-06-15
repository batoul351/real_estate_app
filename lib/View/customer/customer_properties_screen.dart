import 'package:flutter/material.dart';
import 'property_data.dart';
import 'property_details_screen.dart';

class CustomerPropertiesScreen extends StatefulWidget {
  const CustomerPropertiesScreen({super.key});

  @override
  State<CustomerPropertiesScreen> createState() =>
      _CustomerPropertiesScreenState();
}

class _CustomerPropertiesScreenState
    extends State<CustomerPropertiesScreen> {

  String selectedType = "الكل";

  bool isFavorite(Property property) {
    return favoriteProperties.contains(property);
  }

  @override
  Widget build(BuildContext context) {

    final filtered = selectedType == "الكل"
        ? properties
        : properties.where(
            (e) => e.type == selectedType,
          ).toList();

    return Scaffold(
      backgroundColor: const Color(0xff070b18),

      appBar: AppBar(
        backgroundColor: const Color(0xff070b18),
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "العقارات",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: Column(
        children: [

          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: Row(
              children: [

                const SizedBox(width: 10),

                _filterChip("الكل"),
                _filterChip("شقة"),
                _filterChip("فيلا"),
                _filterChip("مكتب"),

              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,

              itemBuilder: (context, index) {

                final property = filtered[index];

                return Card(
                  color: const Color(0xff111827),

                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),

                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(18),

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PropertyDetailsScreen(
                            property: property,
                          ),
                        ),
                      ).then((_) {
                        setState(() {});
                      });

                    },

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Stack(
                          children: [

                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.only(
                                topLeft:
                                    Radius.circular(18),
                                topRight:
                                    Radius.circular(18),
                              ),

                              child: Image.network(
                                property.images.first,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                            Positioned(
                              top: 10,
                              left: 10,

                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius:
                                      BorderRadius.circular(
                                    50,
                                  ),
                                ),

                                child: IconButton(
                                  icon: Icon(
                                    isFavorite(property)
                                        ? Icons.favorite
                                        : Icons.favorite_border,

                                    color: Colors.red,
                                  ),

                                  onPressed: () {

                                    setState(() {

                                      if (favoriteProperties
                                          .contains(
                                              property)) {

                                        favoriteProperties
                                            .remove(
                                                property);

                                      } else {

                                        favoriteProperties
                                            .add(
                                                property);

                                      }

                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding:
                              const EdgeInsets.all(15),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Text(
                                property.title,

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                property.city,

                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "${property.price} \$",

                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,

                                children: [

                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),

                                    decoration:
                                        BoxDecoration(
                                      color:
                                          const Color(
                                        0xff1E3A8A,
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        20,
                                      ),
                                    ),

                                    child: Text(
                                      property.type,

                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                      ),
                                    ),
                                  ),

                                  Text(
                                    isFavorite(property)
                                        ? "بالمفضلة"
                                        : "إضافة للمفضلة",

                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.red,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String type) {

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 5),

      child: ChoiceChip(
        label: Text(type),

        selected: selectedType == type,

        selectedColor:
            const Color(0xff1E3A8A),

        labelStyle: TextStyle(
          color: selectedType == type
              ? Colors.white
              : Colors.black,
        ),

        onSelected: (_) {

          setState(() {

            selectedType = type;

          });

        },
      ),
    );
  }
}
