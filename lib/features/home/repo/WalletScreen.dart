// import 'package:flutter/material.dart';
// import 'package:kleanitapp/features/home/repo/wallet_repository.dart';
// import '../../../core/theme/color_data.dart';
// import '../modle/wallet_details.dart';
// import 'package:shimmer/shimmer.dart';
// import 'WalletTransaction.dart';
//
// class WalletScreen extends StatefulWidget {
//   const WalletScreen({Key? key}) : super(key: key);
//
//   @override
//   State<WalletScreen> createState() => _WalletScreenState();
// }
//
// class _WalletScreenState extends State<WalletScreen> {
//   bool isCreditSelected = true;
//   WalletDetails? walletDetails;
//   bool isLoading = true;
//
//   List<WalletTransaction> sentTransactions = [];
//   List<WalletTransaction> receivedTransactions = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadWalletDetails();
//   }
//
//   Future<void> _loadWalletDetails() async {
//     try {
//       final details = await WalletRepository().fetchWalletDetails();
//       final sent = await WalletRepository().fetchSentTransactions();
//       final received = await WalletRepository().fetchReceivedTransactions();
//
//       setState(() {
//         walletDetails = details;
//         sentTransactions = sent;
//         receivedTransactions = received;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("❌ Failed to load wallet or transactions: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final transactions = isCreditSelected ? receivedTransactions : sentTransactions;
//
//     return Scaffold(
//       appBar: AppBar( leading: IconButton(
//         onPressed: () => Navigator.of(context).pop(),
//         icon: Icon(Icons.arrow_back_ios,color:Color(0xFF0F3D4A)
//         // primaryColor,
//         ), // or your custom `icon`
//       ),
//         title: const Text("Wallet", style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.black),
//         elevation: 1,
//       ),
//       backgroundColor: Colors.white,
//       body: isLoading
//           ? _buildWalletCardShimmer()
//           : Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             _buildWalletCard(),
//             const SizedBox(height: 20),
//             // Row(
//             //   mainAxisAlignment: MainAxisAlignment.center,
//             //   children: [
//             //     _buildTabButton("Credits", isCreditSelected),
//             //     const SizedBox(width: 16),
//             //     _buildTabButton("Debits", !isCreditSelected),
//             //   ],
//             // ),
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(child: _buildTabButton("Credits", isCreditSelected)),
//                   Expanded(child: _buildTabButton("Debits", !isCreditSelected)),
//                 ],
//               ),
//             )
// ,
//             const SizedBox(height: 20),
//             Expanded(
//               child: transactions.isEmpty
//                   ? const Center(child: Text("No transactions found"))
//                   : ListView.builder(
//                 itemCount: transactions.length,
//                 itemBuilder: (context, index) {
//                   final txn = transactions[index];
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 22,
//                           backgroundImage: txn.userPhoto != null
//                               ? NetworkImage(txn.userPhoto!)
//                               : const AssetImage('assets/images/user.png') as ImageProvider,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(txn.userName ?? "Unknown",
//                                   style: const TextStyle(fontWeight: FontWeight.w600)),
//                               // Text(
//                               //   _getDisplayName(txn),
//                               //   style: const TextStyle(fontWeight: FontWeight.w600),
//                               // ),
//
//                               Text("On ${txn.date}",
//                                   style: const TextStyle(color: Colors.black54, fontSize: 13)),
//                             ],
//                           ),
//                         ),
//                         Text(
//                           "${txn.type == "credit" ? "+ coins " : "- coins "}${txn.amount}",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: txn.type == "credit" ? Colors.black : Colors.red,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTabButton(String label, bool isSelected) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           isCreditSelected = label == "Credits";
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         decoration: BoxDecoration(
//           color: isSelected ?
//           // Colors.teal[700]
//           Color(0xFF0F3D4A)
//               : Colors.grey[200],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Center(
//           child: Text(
//             label,
//             style: TextStyle(
//               color: isSelected ? Colors.white : Colors.black87,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildWalletCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(3),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         gradient: LinearGradient(
//           colors: [
//             // Colors.teal[700]!
//             Color(0xFF0F3D4A)
//             , Colors.teal[800]!],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: const [
//           BoxShadow(
//             color:Colors.teal,
//             // Colors.black26,
//             blurRadius: 12,
//             offset: Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color:  Color(0xFF034051),
//           // Colors.teal[600],
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 28,
//                   backgroundImage: (walletDetails != null &&
//                       walletDetails!.profileUrl.isNotEmpty &&
//                       !walletDetails!.profileUrl.contains('default-avatar'))
//                       ? NetworkImage(walletDetails!.profileUrl)
//                       : const AssetImage('assets/images/user.png') as ImageProvider,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   walletDetails?.name ?? '',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 17,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               decoration: BoxDecoration(
//                 color:  Color(0xFF097B9A),
//                 // Colors.teal[200],
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("My Wallet",
//                       style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 6),
//                   Text(
//                     "Coins ${walletDetails?.walletAmount.toStringAsFixed(2) ?? '0.00'}",
//                     style: const TextStyle(
//                       color: Colors.teal,
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                     ),
//
//
//                   ),
//                   Text(
//                     '* Note: ${walletDetails != null ? _getAedFromCoins(walletDetails!.walletAmount) : '0.00'} AED available',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       letterSpacing: 2,
//                     ),
//                   ),
//
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               '*** *** *** ${walletDetails?.mobileLast4?.isNotEmpty == true ? walletDetails!.mobileLast4 : '0000'}',
//               style: const TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//                 letterSpacing: 2,
//               ),
//             ),
//             const Text(
//               '* Note : 50 Coins = 1 AED',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 12,
//                 letterSpacing: 2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildWalletCardShimmer() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey.shade300,
//       highlightColor: Colors.grey.shade100,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(3),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           gradient: LinearGradient(
//             colors: [Colors.teal[700]!, Colors.teal[800]!],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 12,
//               offset: Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Container(
//           padding: const EdgeInsets.all(18),
//           decoration: BoxDecoration(
//             color: Colors.teal[600],
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const CircleAvatar(radius: 28, backgroundColor: Colors.white),
//                   const SizedBox(width: 12),
//                   Container(width: 100, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                 decoration: BoxDecoration(color: Colors.teal[200], borderRadius: BorderRadius.circular(16)),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(width: 80, height: 14, color: Colors.white),
//                     const SizedBox(height: 8),
//                     Container(width: 120, height: 24, color: Colors.white),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Container(width: 100, height: 12, color: Colors.white),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// String _getDisplayName(WalletTransaction txn) {
//   final name = txn.userName?.trim().toLowerCase() ?? '';
//   if (name.isEmpty || name == 'unknown') {
//     return txn.type == 'credit' ? 'Coin In' : 'Coin Used';
//   }
//   return txn.userName!;
// }
//
//
// String _getAedFromCoins(double coins) {
//   double aed = coins / 50;
//   return aed.toStringAsFixed(2);
// }
//
import 'package:flutter/material.dart';
import 'package:kleanitapp/features/home/repo/wallet_repository.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/color_data.dart';
import '../modle/wallet_details.dart';
import 'WalletTransaction.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool isCreditSelected = true;
  WalletDetails? walletDetails;
  bool isLoading = true;

  List<WalletTransaction> sentTransactions = [];
  List<WalletTransaction> receivedTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadWalletDetails();
  }

  Future<void> _loadWalletDetails() async {
    try {
      final details = await WalletRepository().fetchWalletDetails();
      final sent = await WalletRepository().fetchSentTransactions();
      final received = await WalletRepository().fetchReceivedTransactions();

      setState(() {
        walletDetails = details;
        sentTransactions = sent;
        receivedTransactions = received;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Failed to load wallet or transactions: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = isCreditSelected ? receivedTransactions : sentTransactions;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.arrow_back_ios, color: accentColor)),
        title: const Text("Wallet", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body:
          isLoading
              ? _buildWalletCardShimmer()
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildWalletCard(),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [Expanded(child: _buildTabButton("Credits", isCreditSelected)), Expanded(child: _buildTabButton("Debits", !isCreditSelected))]),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child:
                          transactions.isEmpty
                              ? const Center(child: Text("No transactions found"))
                              : ListView.builder(
                                itemCount: transactions.length,
                                itemBuilder: (context, index) {
                                  final txn = transactions[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundImage: txn.userPhoto != null ? NetworkImage(txn.userPhoto!) : const AssetImage('assets/images/user.png') as ImageProvider,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(txn.userName ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.w600)),
                                              Text("On ${txn.date}", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "${txn.type == "credit" ? "+ coins " : "- coins "}${txn.amount}",
                                          style: TextStyle(fontWeight: FontWeight.bold, color: txn.type == "credit" ? accentColor : Colors.red),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTabButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isCreditSelected = label == "Credits";
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: isSelected ? accentColor : Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600))),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      (walletDetails != null && walletDetails!.profileUrl.isNotEmpty && !walletDetails!.profileUrl.contains('default-avatar'))
                          ? NetworkImage(walletDetails!.profileUrl)
                          : const AssetImage('assets/images/user.png') as ImageProvider,
                ),
                const SizedBox(width: 12),
                Text(walletDetails?.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: accentColor.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("My Wallet", style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text("Coins  : ${walletDetails?.walletAmount.toStringAsFixed(2) ?? '0.00'}", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text(
                        '* Note: ',
                        // '${walletDetails != null ? _getAedFromCoins(walletDetails!.walletAmount) : '0.00'} AED available',
                        style: const TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 2),
                      ),
                      Image.asset(
                        'assets/icon/aed_symbol.png',
                        width: 14,
                        height: 14,
                        fit: BoxFit.contain,
                        // color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${walletDetails != null ? _getAedFromCoins(walletDetails!.walletAmount) : '0.00'} available',
                        style: const TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '*** *** *** ${walletDetails?.mobileLast4?.isNotEmpty == true ? walletDetails!.mobileLast4 : '0000'}',
              style: const TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 2),
            ),
            Row(
              children: [
                const Text('* Note : 50 Coins = ', style: TextStyle(color: Colors.black, fontSize: 12, letterSpacing: 2)),
                Image.asset('assets/icon/aed_symbol.png', width: 14, height: 14, fit: BoxFit.contain),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(colors: [primaryColor, primaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 28, backgroundColor: Colors.white),
                  const SizedBox(width: 12),
                  Container(width: 100, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Container(width: 80, height: 14, color: Colors.white), const SizedBox(height: 8), Container(width: 120, height: 24, color: Colors.white)],
                ),
              ),
              const SizedBox(height: 20),
              Container(width: 100, height: 12, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

String _getAedFromCoins(double coins) {
  double aed = coins / 50;
  return aed.toStringAsFixed(2);
}
