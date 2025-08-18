

class AppNotificationModel {
  final String title;
  final String body;
  final String? image;
  final String? data;
  final DateTime? sentTime;
  final DateTime? createdAt;

  AppNotificationModel({required this.title, required this.body, this.image, this.data, this.sentTime, this.createdAt});

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      image: json['image'],
      data: json['data'],
      sentTime: json['sent_at'] != null ? DateTime.tryParse(json['sent_at']!)?.toLocal() : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']!)?.toLocal() : null,
    );
  }

  static List<AppNotificationModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((item) => AppNotificationModel.fromJson(item)).toList();
  }
}
