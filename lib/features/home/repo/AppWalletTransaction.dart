class AppWalletTransaction {
  final int id;
  final double amount;
  final String date;
  final String type;
  final String? userName;
  final String? userPhoto;

  AppWalletTransaction({required this.id, required this.amount, required this.date, required this.type, this.userName, this.userPhoto});

  factory AppWalletTransaction.fromJson(Map<String, dynamic> json, {required bool isReceived}) {
    return AppWalletTransaction(
      id: json['id'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: json['date'] ?? '',
      type: json['type']?.toString() ?? (isReceived ? 'credit' : 'debit'),
      userName: isReceived ? json['sender_name'] : json['receiver_name'],
      userPhoto: isReceived ? json['sender_photo'] : json['receiver_photo'],
    );
  }
}
