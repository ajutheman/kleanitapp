// import 'package:flutter/material.dart';
//
// import '../categories/modle/review_model.dart';
//
// class ReviewSection extends StatelessWidget {
//   final List<Review> reviews;
//   const ReviewSection({Key? key, required this.reviews}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Section Header
//         Text(
//           'Customer Reviews',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.blueAccent,
//           ),
//         ),
//         SizedBox(height: 16),
//         // List of review cards
//         ...reviews.map((review) {
//           return Card(
//             elevation: 3,
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Review text
//                   Text(
//                     review.review,
//                     style: const TextStyle(fontSize: 16, color: Colors.black87),
//                   ),
//                   const SizedBox(height: 8),
//                   // Rating with star icon
//                   Row(
//                     children: [
//                       const Icon(Icons.star, color: Colors.amber, size: 18),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${review.rating}',
//                         style: const TextStyle(
//                             fontSize: 14, color: Colors.black54),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   // Customer name container
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.blue[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding:
//                         const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.person,
//                             color: Colors.blueAccent, size: 18),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             "Name: ${review.customer.name}",
//                             style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.blueAccent),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   // Customer email container
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.green[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding:
//                         const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.email, color: Colors.green, size: 18),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             "Email: ${review.customer.email}",
//                             style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.green),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kleanitapp/features/categories/modle/review_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../categories/bloc/review/review_bloc.dart';

class ReviewSection extends StatefulWidget {
  final int secondCatId;

  const ReviewSection({super.key, required this.secondCatId});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  @override
  void initState() {
    context.read<ReviewBloc>().add(LoadReviews(secondCatId: widget.secondCatId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        if (state is ReviewLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ReviewLoaded) {
          final reviews = state.reviews;
          if (reviews.isEmpty) return SizedBox();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Customer Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey[200], height: 32),
                itemBuilder: (context, index) => ReviewCard(review: reviews[index]),
              ),
            ],
          );
        } else if (state is ReviewError) {
          return Text("Error loading reviews: ${state.message}");
        }
        return Container();
      },
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(backgroundColor: Colors.grey[200], child: Text(review.customer.name[0], style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.customer.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(5, (index) => Icon(Icons.star, size: 16, color: index < review.rating ? Colors.amber : Colors.grey[300])),
                      const SizedBox(width: 8),
                      Text(formatDateTimeHumanReadable(DateTime.tryParse(review.createdAt) ?? DateTime.now()), style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(review.review, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
      ],
    );
  }

  String formatDateTimeHumanReadable(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // If within 7 days, show 'x days ago' or 'x hours ago'
    if (difference.inDays < 7) {
      return timeago.format(dateTime);
    }
    // Otherwise, show full date
    else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }
}
