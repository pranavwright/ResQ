// Make sure your Notice class has the required fields and NoticeUrgency enum
enum NoticeUrgency { critical, high, medium, low }

class Notice {
  final String id;
  final String title;
  final String content;  // Maps to "description" in API
  final String status;
  final NoticeUrgency priority;
  final DateTime createdAt;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    required this.priority,
    required this.createdAt,
  });
}