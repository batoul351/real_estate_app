class Property {
  final String title;
  final String city;
  final String type;
  final double price;
  final String description;
  final List<String> images;
  final String phone;

  Property({
    required this.title,
    required this.city,
    required this.type,
    required this.price,
    required this.description,
    required this.images,
    required this.phone,
  });
}

/// بيانات العقارات

final List<Property> properties = [
  Property(
    title: "شقة فاخرة",
    city: "دمشق",
    type: "شقة",
    price: 50000,
    description: "شقة حديثة مؤلفة من 3 غرف وصالون.",
    phone: "0999999999",
    images: [
      "https://images.unsplash.com/photo-1505693416388-ac5ce068fe85",
      "https://images.unsplash.com/photo-1494526585095-c41746248156",
    ],
  ),

  Property(
    title: "فيلا مستقلة",
    city: "ريف دمشق",
    type: "فيلا",
    price: 250000,
    description: "فيلا مع حديقة ومسبح.",
    phone: "0988888888",
    images: [
      "https://images.unsplash.com/photo-1564013799919-ab600027ffc6",
      "https://images.unsplash.com/photo-1600585154526-990dced4db0d",
    ],
  ),

  Property(
    title: "مكتب تجاري",
    city: "حلب",
    type: "مكتب",
    price: 80000,
    description: "مكتب مجهز بالكامل.",
    phone: "0977777777",
    images: [
      "https://images.unsplash.com/photo-1497366754035-f200968a6e72",
    ],
  ),
];

/// المفضلة

List<Property> favoriteProperties = [];

/// بيانات المستخدم

String customerName = "Ahmad Mohammad";

String customerEmail = "ahmad@gmail.com";

String customerPhone = "+963999999999";

String? customerImage;
