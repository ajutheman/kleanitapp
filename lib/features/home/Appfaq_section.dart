// import 'package:flutter/material.dart';
//
// class FAQSection extends StatefulWidget {
//   const FAQSection({Key? key}) : super(key: key);
//
//   @override
//   _FAQSectionState createState() => _FAQSectionState();
// }
//
// class _FAQSectionState extends State<FAQSection> {
//   final List<FAQItem> _faqItems = [
//     FAQItem(
//       question: 'Why should I choose Kleanit?',
//       answer:
//           'Kleanit offers reliable, professional, and on-demand cleaning services at your convenience. With a dedicated team, real-time order tracking, and wallet-based payments, we ensure a hassle-free experience every time.',
//     ),
//    FAQItem(
//       question: 'How do I schedule a cleaning service?',
//       answer: 'After logging in, browse the available services, select your preferred date and time, and confirm the booking with your wallet or card.',
//     ),
//     FAQItem(
//       question: 'How do I update my profile information?',
//       answer: 'Go to the Profile tab and tap "Edit Profile" to update your name, contact info, address, and more.',
//     ),
//     FAQItem(
//       question: 'Is my personal data safe on Kleanit?',
//       answer: 'Absolutely. We use secure encryption and follow industry best practices to protect all your information.',
//     ),
//     FAQItem(
//       question: 'How do I contact Kleanit support?',
//       answer: 'Open the app menu, go to "Help & Support", and you can chat with us, send a message, or call/email our support team.',
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 25),
//         Text(
//           'Frequently Asked Questions',
//           style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 3),
//         Text(
//           'Find answers to common questions about our app',
//           style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//         ),
//         SizedBox(height: 10),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 10),
//           child: ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: _faqItems.length,
//             itemBuilder: (context, index) {
//               return FAQExpansionTile(faqItem: _faqItems[index]);
//             },
//           ),
//         )
//       ],
//     );
//   }
// }
//
// class FAQItem {
//   final String question;
//   final String answer;
//
//   FAQItem({required this.question, required this.answer});
// }
//
// class FAQExpansionTile extends StatefulWidget {
//   final FAQItem faqItem;
//
//   const FAQExpansionTile({Key? key, required this.faqItem}) : super(key: key);
//
//   @override
//   _FAQExpansionTileState createState() => _FAQExpansionTileState();
// }
//
// class _FAQExpansionTileState extends State<FAQExpansionTile> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _iconTurns;
//   late Animation<double> _heightFactor;
//   bool _isExpanded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//
//     _heightFactor = _controller.drive(CurveTween(curve: Curves.easeIn));
//     _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeIn)));
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _toggleExpansion() {
//     setState(() {
//       _isExpanded = !_isExpanded;
//       if (_isExpanded) {
//         _controller.forward();
//       } else {
//         _controller.reverse();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.white,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         children: [
//           InkWell(
//             onTap: _toggleExpansion,
//             borderRadius: BorderRadius.circular(12),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       widget.faqItem.question,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                   RotationTransition(
//                     turns: _iconTurns,
//                     child: const Icon(Icons.keyboard_arrow_down),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           ClipRect(
//             child: AnimatedBuilder(
//               animation: _controller,
//               builder: (context, child) {
//                 return Align(
//                   heightFactor: _heightFactor.value,
//                   child: child,
//                 );
//               },
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     widget.faqItem.answer,
//                     style: TextStyle(
//                       color: Colors.grey[800],
//                       height: 1.5,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:kleanitapp/features/home/repo/AppFaqRepository.dart';

import 'modle/Appfaq_item.dart';

// import 'model/faq_item.dart';
// import 'repository/faq_repository.dart';

class AppFAQSection extends StatefulWidget {
  const AppFAQSection({Key? key}) : super(key: key);

  @override
  State<AppFAQSection> createState() => _AppFAQSectionState();
}

class _AppFAQSectionState extends State<AppFAQSection> {
  List<AppFAQItem> _faqItems = [];
  bool _isLoading = true;
  bool _hasError = false;
  final AppFAQRepository faqRepository = AppFAQRepository();

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  // Future<void> _loadFaqs() async {
  //   try {
  //     final faqs = await faqRepository.fetchFAQs();
  //     setState(() {
  //       _faqItems = faqs;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _hasError = true;
  //       _isLoading = false;
  //     });
  //   }
  // }
  Future<void> _loadFaqs() async {
    try {
      final faqs = await faqRepository.fetchFAQs();
      if (!mounted) return;
      setState(() {
        _faqItems = faqs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('Frequently Asked Questions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('Find answers to common questions about our app', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ),
        const SizedBox(height: 10),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_hasError)
          Center(child: Text("Failed to load FAQs."))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqItems.length,
            itemBuilder: (context, index) {
              return FAQExpansionTile(faqItem: _faqItems[index]);
            },
          ),
      ],
    );
  }
}

// class FAQExpansionTile extends StatefulWidget {
//   final FAQItem faqItem;
//
//   const FAQExpansionTile({Key? key, required this.faqItem}) : super(key: key);
//
//   @override
//   _FAQExpansionTileState createState() => _FAQExpansionTileState();
// }
//
// class _FAQExpansionTileState extends State<FAQExpansionTile> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _iconTurns;
//   late Animation<double> _heightFactor;
//   bool _isExpanded = false;
//   final Color primaryColor = const Color(0xFF077975);
//   final Color answerBgColor = const Color(0xFFE6F6F3); // Light mint green
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//
//     _heightFactor = _controller.drive(CurveTween(curve: Curves.easeIn));
//     _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeIn)));
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _toggleExpansion() {
//     setState(() {
//       _isExpanded = !_isExpanded;
//       if (_isExpanded) {
//         _controller.forward();
//       } else {
//         _controller.reverse();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         children: [
//           InkWell(
//             onTap: _toggleExpansion,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       widget.faqItem.question,
//                       style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//                     ),
//                   ),
//                   RotationTransition(
//                     turns: _iconTurns,
//                     child: const Icon(Icons.keyboard_arrow_down),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           ClipRect(
//             child: AnimatedBuilder(
//               animation: _controller,
//               builder: (context, child) {
//                 return Align(
//                   heightFactor: _heightFactor.value,
//                   child: child,
//                 );
//               },
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color:answerBgColor,
//                   // color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   widget.faqItem.answer,
//                   style: TextStyle(color: Colors.grey[800], height: 1.5),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
class FAQExpansionTile extends StatefulWidget {
  final AppFAQItem faqItem;

  const FAQExpansionTile({Key? key, required this.faqItem}) : super(key: key);

  @override
  _FAQExpansionTileState createState() => _FAQExpansionTileState();
}

class _FAQExpansionTileState extends State<FAQExpansionTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;
  bool _isExpanded = false;

  final Color primaryColor = const Color(0xFF077975);
  final Color answerBgColor = const Color(0xFFE6F6F3); // Light mint green

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeInOut)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1.5,
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Expanded(child: Text(widget.faqItem.question, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: primaryColor))),
                  RotationTransition(turns: _iconTurns, child: Icon(Icons.keyboard_arrow_down, color: Colors.grey[700])),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Align(heightFactor: _heightFactor.value, child: child);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(color: answerBgColor, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14))),
                child: Text(widget.faqItem.answer, style: TextStyle(color: Colors.grey[800], fontSize: 14.5, height: 1.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
