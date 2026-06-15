import 'package:flutter/material.dart';
import 'property_data.dart';
import 'property_details_screen.dart';

class CustomerHomeTab extends StatefulWidget {
  const CustomerHomeTab({super.key});

  @override
  State<CustomerHomeTab> createState() =>
      _CustomerHomeTabState();
}

class _CustomerHomeTabState
    extends State<CustomerHomeTab> {

  String selectedCategory = "الكل";
  String searchText = "";

  @override
  Widget build(BuildContext context) {

    final filtered = properties.where((p) {

      final categoryMatch =
          selectedCategory == "الكل" ||
          p.type == selectedCategory;

      final searchMatch =
          p.title.toLowerCase().contains(
                searchText.toLowerCase(),
              );

      return categoryMatch && searchMatch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xff070B18),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [

            const Text(
              "Welcome 👋",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "ابحث عن العقار المناسب لك",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              style: const TextStyle(
                color: Colors.white,
              ),

              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },

              decoration: InputDecoration(
                hintText: "Search Property...",
                hintStyle: const TextStyle(
                  color: Colors.white38,
                ),

                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white54,
                ),

                filled: true,
                fillColor: const Color(0xff111827),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Categories",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: Row(
                children: [
                  _chip("الكل"),
                  _chip("شقة"),
                  _chip("فيلا"),
                  _chip("مكتب"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Featured Properties",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 200,

              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: properties.length,

                itemBuilder: (_, index) {

                  final property =
                      properties[index];

                  return GestureDetector(
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

                    child: Container(
                      width: 250,
                      margin:
                          const EdgeInsets.only(
                        right: 12,
                      ),

                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(20),

                        image: DecorationImage(
                          image: NetworkImage(
                            property.images.first,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),

                      child: Container(
                        padding:
                            const EdgeInsets.all(
                          12,
                        ),

                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),

                          gradient:
                              LinearGradient(
                            begin:
                                Alignment.bottomCenter,
                            end:
                                Alignment.topCenter,
                            colors: [
                              Colors.black87,
                              Colors.transparent,
                            ],
                          ),
                        ),

                        child: Align(
                          alignment:
                              Alignment.bottomLeft,

                          child: Text(
                            property.title,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Latest Properties",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            ...filtered.map(
              (property) => Card(
                color: const Color(
                  0xff111827,
                ),

                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),

                child: ListTile(

                  leading: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),

                    child: Image.network(
                      property.images.first,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),

                  title: Text(
                    property.title,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                    ),
                  ),

                  subtitle: Text(
                    "${property.city} - ${property.price}\$",
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),

                  trailing: IconButton(
                    icon: Icon(
                      favoriteProperties
                              .contains(
                            property,
                          )
                          ? Icons.favorite
                          : Icons
                              .favorite_border,
                      color: Colors.red,
                    ),

                    onPressed: () {
                      setState(() {

                        if (favoriteProperties
                            .contains(
                          property,
                        )) {

                          favoriteProperties
                              .remove(
                            property,
                          );

                        } else {

                          favoriteProperties
                              .add(
                            property,
                          );
                        }
                      });
                    },
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PropertyDetailsScreen(
                          property:
                              property,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {

    final selected =
        selectedCategory == text;

    return Padding(
      padding:
          const EdgeInsets.only(right: 8),

      child: ChoiceChip(
        label: Text(text),

        selected: selected,

        selectedColor:
            const Color(0xff1E3A8A),

        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : Colors.black,
        ),

        onSelected: (_) {
          setState(() {
            selectedCategory = text;
          });
        },
      ),
    );
  }
}
