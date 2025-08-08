class FAQItem {
  final int id;
  final String question;
  final String answer;
  final String encryptedId;

  FAQItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.encryptedId,
  });

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      encryptedId: json['encrypted_id'],
    );
  }
}
