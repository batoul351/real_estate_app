import 'package:flutter/material.dart';

class OwnerNotificationsScreen extends StatelessWidget {
  const OwnerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "title": "تم قبول العقار",
        "subtitle": "تمت الموافقة على شقة حي النرجس",
        "status": "accepted",
        "date": "منذ ساعتين",
      },
      {
        "title": "العقار قيد المراجعة",
        "subtitle": "يتم الآن مراجعة فيلا حي الياسمين",
        "status": "pending",
        "date": "منذ 5 ساعات",
      },
      {
        "title": "تم رفض العقار",
        "subtitle": "تم رفض مكتب شارع الملك بسبب نقص الصور",
        "status": "rejected",
        "date": "أمس",
      },
      {
        "title": "العقار قيد المراجعة",
        "subtitle": "طلب إضافة استراحة جديدة تحت التدقيق",
        "status": "pending",
        "date": "منذ يومين",
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("الإشعارات"), centerTitle: true),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // دائرة الحالة
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _getStatusColor(item["status"]!),
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 14),

                // النصوص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"]!,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        item["subtitle"]!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        item["date"]!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Icon(
                  Icons.notifications_active_outlined,
                  color: _getStatusColor(item["status"]!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green;

      case "pending":
        return Colors.orange;

      case "rejected":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}

