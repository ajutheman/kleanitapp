class WalletDetails {
  final String name;
  final String profileUrl;
  final String mobileLast4;
  final double walletAmount;

  WalletDetails({required this.name, required this.profileUrl, required this.mobileLast4, required this.walletAmount});

  factory WalletDetails.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return WalletDetails(
      name: data['name'] ?? '',
      profileUrl: data['profile_url'] ?? '',
      mobileLast4: data['mobile_last4'] ?? '',
      walletAmount: double.tryParse(json['wallet_amount'].toString()) ?? 0.0,
    );
  }
}
