// Create a shared model file (e.g., `models/notice.dart`)
enum NoticeUrgency {
  low,
  medium,
  high,
  critical
}

class Notice {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final NoticeUrgency urgency; // Use your existing enum
  final List<String>? affectedAreas;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.urgency,
    this.affectedAreas,
  });

  // Add fromJson/toJson methods to help backend team
  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      urgency: NoticeUrgency.values.firstWhere(
        (e) => e.toString().split('.').last == json['urgency'],
      ),
      affectedAreas: json['affectedAreas'] != null 
          ? List<String>.from(json['affectedAreas'])
          : null,
    );
  }
}