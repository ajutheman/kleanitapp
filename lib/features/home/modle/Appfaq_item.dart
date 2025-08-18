class AppFAQItem {
  final int id;
  final String question;
  final String answer;
  final String encryptedId;

  AppFAQItem({required this.id, required this.question, required this.answer, required this.encryptedId});

  factory AppFAQItem.fromJson(Map<String, dynamic> json) {
    return AppFAQItem(id: json['id'], question: json['question'], answer: json['answer'], encryptedId: json['encrypted_id']);
  }
}
