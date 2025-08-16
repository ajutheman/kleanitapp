
class AppReferalAdvertisement {
  final int id;
  final String title;
  final String content;
  final String status;
  final String image;
  final String? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? referralAdCode;
  final int? customerId;
  final String? welcomeNote;
  final String type;
  final String encryptedId;

  AppReferalAdvertisement({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    required this.image,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.referralAdCode,
    this.customerId,
    this.welcomeNote,
    required this.type,
    required this.encryptedId,
  });

  factory AppReferalAdvertisement.fromJson(Map<String, dynamic> json) {
    return AppReferalAdvertisement(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      status: json['status'],
      image: json['image'],
      deletedAt: json['deleted_at'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      referralAdCode: json['referral_ad_code'],
      customerId: json['customer_id'],
      welcomeNote: json['welcome_note'],
      type: json['type'],
      encryptedId: json['encrypted_id'],
    );
  }
}
