// class NotificationModel {
//   final String title;
//   final String body;
//
//   final DateTime? sentTime;
//
//   NotificationModel({
//     required this.title,
//     required this.body,
//     required this.sentTime,
//   });
//
//   factory NotificationModel.fromJson(Map<String, dynamic> json) {
//     return NotificationModel(
//       title: json['title'] ?? '',
//       body: json['body'] ?? '',
//       sentTime: json['sent_at'] == null ? null : DateTime.parse(json['sent_at']).toLocal(),
//     );
//   }
//
//   static List<NotificationModel> listFromJson(List<dynamic> jsonList) {
//     return jsonList.map((item) => NotificationModel.fromJson(item)).toList();
//   }
// }

class NotificationModel {
  final String title;
  final String body;
  final String? image;
  final String? data;
  final DateTime? sentTime;
  final DateTime? createdAt;

  NotificationModel({required this.title, required this.body, this.image, this.data, this.sentTime, this.createdAt});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      image: json['image'],
      data: json['data'],
      sentTime: json['sent_at'] != null ? DateTime.tryParse(json['sent_at']!)?.toLocal() : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']!)?.toLocal() : null,
    );
  }

  static List<NotificationModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((item) => NotificationModel.fromJson(item)).toList();
  }
}
