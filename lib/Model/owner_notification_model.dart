class OwnerNotificationModel {
  final String id;
  final bool isRead;
  final String title;
  final String subtitle;
  final String status; // pending, accepted, rejected
  final String dateHuman;

  OwnerNotificationModel({
    required this.id,
    required this.isRead,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.dateHuman,
  });

  factory OwnerNotificationModel.fromJson(Map<String, dynamic> json) {
    // تفكيك الحقل data الداخلي المرسل من لارافيل
    final Map<String, dynamic> dataPayload = json['data'] ?? {};

    return OwnerNotificationModel(
      id: json['id'] ?? '',
      // الـ API يرجع true/false عبر متغير is_read
      isRead: json['is_read'] ?? false,
      title: dataPayload['title'] ?? 'تحديث حالة العقار',
      subtitle: dataPayload['message'] ?? 'تم تعديل حالة طلبك',
      status: dataPayload['status'] ?? 'pending',
      dateHuman: json['created_human'] ?? '',
    );
  }
}
