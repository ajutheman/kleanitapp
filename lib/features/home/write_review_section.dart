// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kleanitapp/features/categories/bloc/review/review_bloc.dart';
//
// import '../../core/theme/color_data.dart';
//
// class WriteReviewSection extends StatefulWidget {
//   final int secondCategoryId;
//
//   const WriteReviewSection({Key? key, required this.secondCategoryId}) : super(key: key);
//
//   @override
//   State<WriteReviewSection> createState() => _WriteReviewSectionState();
// }
//
// class _WriteReviewSectionState extends State<WriteReviewSection> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _reviewController = TextEditingController();
//   int _rating = 0;
//   bool _isSubmitting = false;
//   @override
//   void initState() {
//     super.initState();
//     // Load reviews initially
//     context.read<ReviewBloc>().add(LoadReviews(secondCatId: widget.secondCategoryId));
//   }
//   @override
//   void dispose() {
//     _reviewController.dispose();
//     super.dispose();
//   }
//
//   void _submitReview() {
//     if (_formKey.currentState!.validate() && _rating > 0) {
//       setState(() {
//         _isSubmitting = true;
//       });
//
//       // final reviewBloc = context.read<ReviewBloc>();
//       // reviewBloc.add(SubmitReview(
//       //   secondCatId: widget.secondCategoryId,
//       //   review: _reviewController.text,
//       //   rating: _rating,
//       // ));
//       context.read<ReviewBloc>().add(SubmitReview(
//         secondCatId: widget.secondCategoryId,
//         review: _reviewController.text,
//         rating: _rating,
//       ));
//     } else if (_rating == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select a rating'),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<ReviewBloc, ReviewState>(
//       listener: (ctx, state) {
//         // Listen for the result
//         if (state is ReviewSubmitted) {
//           setState(() {
//             _isSubmitting = false;
//             _reviewController.clear();
//             _rating = 0;
//           });
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Review submitted successfully!')),
//           );
//
//           // Reload reviews
//           // reviewBloc.add(LoadReviews(secondCatId: widget.secondCategoryId));
//           context.read<ReviewBloc>().add(LoadReviews(secondCatId: widget.secondCategoryId));
//
//         } else if (state is ReviewError) {
//           setState(() {
//             _isSubmitting = false;
//           });
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.message)),
//           );
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: const [
//             BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0)),
//           ],
//         ),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Section Header
//               Row(
//                 children: [
//                   Icon(Icons.rate_review, color: primaryColor),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Write a Review',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//
//               // Rating Stars
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   5,
//                   (index) => GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _rating = index + 1;
//                       });
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       child: Icon(
//                         Icons.star,
//                         size: 32,
//                         color: index < _rating ? Colors.amber : Colors.grey[300],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Review Text Field
//               TextFormField(
//                 controller: _reviewController,
//                 maxLines: 4,
//                 decoration: InputDecoration(
//                   hintText: 'Share your experience...',
//                   filled: true,
//                   fillColor: Colors.grey[50],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.grey[200]!),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: primaryColor),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your review';
//                   }
//                   if (value.length < 5) {
//                     return 'Review must be at least 5 characters';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               // Submit Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isSubmitting ? null : _submitReview,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     backgroundColor: primaryColor,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: _isSubmitting
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         )
//                       : const Text(
//                           'Submit Review',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kleanitapp/features/categories/bloc/review/review_bloc.dart';

import '../../core/theme/color_data.dart';

class WriteReviewSection extends StatefulWidget {
  final int secondCategoryId;

  const WriteReviewSection({Key? key, required this.secondCategoryId}) : super(key: key);

  @override
  State<WriteReviewSection> createState() => _WriteReviewSectionState();
}

class _WriteReviewSectionState extends State<WriteReviewSection> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Load reviews initially
    context.read<ReviewBloc>().add(LoadReviews(secondCatId: widget.secondCategoryId));
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_formKey.currentState!.validate() && _rating > 0) {
      setState(() {
        _isSubmitting = true;
      });

      context.read<ReviewBloc>().add(SubmitReview(secondCatId: widget.secondCategoryId, review: _reviewController.text, rating: _rating));
    } else if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a rating')));
    }
  }

  // Widget buildReviewCard(review) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 6),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 6,
  //           offset: const Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             CircleAvatar(
  //               radius: 18,
  //               backgroundColor: Colors.grey[300],
  //               child: const Icon(Icons.person, color: Colors.white, size: 20),
  //             ),
  //             const SizedBox(width: 10),
  //             Expanded(
  //               child: Text(
  //                 review.customer?.name ?? "Anonymous",
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 15,
  //                 ),
  //               ),
  //             ),
  //             Row(
  //               children: List.generate(
  //                 5,
  //                     (index) => Icon(
  //                   Icons.star,
  //                   size: 18,
  //                   color: index < review.rating ? Colors.amber : Colors.grey[300],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Text(
  //           review.review,
  //           style: const TextStyle(
  //             fontSize: 14,
  //             height: 1.4,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Row(
  //           children: [
  //             const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
  //             const SizedBox(width: 4),
  //             Text(
  //               review.createdAt != null
  //                   ? review.createdAt!.split("T").first
  //                   : "",
  //               style: TextStyle(
  //                 color: Colors.grey[600],
  //                 fontSize: 12,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget buildReviewCard(review) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFF00CFC1), width: 2), shape: BoxShape.circle),
                  child: CircleAvatar(radius: 22, backgroundColor: Colors.grey[200], backgroundImage: const AssetImage("assets/icon/default-avatar.png")),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(review.customer?.name ?? "Anonymous", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          SizedBox(width: 14),
                          Row(children: List.generate(5, (index) => Icon(Icons.star_rounded, size: 22, color: index < review.rating ? const Color(0xFF00CFC1) : Colors.grey[300]))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFEFFCFB), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Color(0xFF00CFC1)),
                                const SizedBox(width: 4),
                                Text(review.createdAt != null ? review.createdAt!.split("T").first : "", style: const TextStyle(color: Color(0xFF00CFC1), fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Row(
                      //   children: List.generate(
                      //     5,
                      //         (index) => Icon(
                      //       Icons.star_rounded,
                      //       size: 20,
                      //       color: index < review.rating
                      //           ? const Color(0xFF00CFC1)
                      //           : Colors.grey[300],
                      //     ),
                      //   ),
                      // ),
                      Text(review.review, style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF333333))),
                    ],
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 12),
            // Text(
            //   review.review,
            //   style: const TextStyle(
            //     fontSize: 15,
            //     height: 1.6,
            //     color: Color(0xFF333333),
            //   ),
            // ),
            // const SizedBox(height: 12),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFEFFCFB),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       const Icon(
            //         Icons.calendar_today,
            //         size: 14,
            //         color: Color(0xFF00CFC1),
            //       ),
            //       const SizedBox(width: 4),
            //       Text(
            //         review.createdAt != null
            //             ? review.createdAt!.split("T").first
            //             : "",
            //         style: const TextStyle(
            //           color: Color(0xFF00CFC1),
            //           fontSize: 12,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (ctx, state) {
        if (state is ReviewSubmitted) {
          setState(() {
            _isSubmitting = false;
            _reviewController.clear();
            _rating = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted successfully!')));
          context.read<ReviewBloc>().add(LoadReviews(secondCatId: widget.secondCategoryId));
        } else if (state is ReviewError) {
          setState(() {
            _isSubmitting = false;
          });
          // Use ScaffoldMessenger to show a styled error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message.isNotEmpty ? state.message : 'Something went wrong. Please try again.', style: const TextStyle(color: Colors.white))),
                ],
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (ctx, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Review Form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0))],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.rate_review, color: primaryColor),
                        const SizedBox(width: 8),
                        const Text('Write a Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Rating Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.star, size: 32, color: index < _rating ? Colors.amber : Colors.grey[300]),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Review Text Field
                    TextFormField(
                      controller: _reviewController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Share your experience...',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your review';
                        }
                        if (value.length < 5) {
                          return 'Review must be at least 5 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            _isSubmitting
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                : const Text('Submit Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Reviews Section
            if (state is ReviewLoading)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
            else if (state is ReviewLoaded)
              state.reviews.isEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.rate_review, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text('No reviews yet.', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  )
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (_, index) {
                      final review = state.reviews[index];
                      return buildReviewCard(review);
                    },
                  )
            else if (state is ReviewError)
              Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(state.message, style: const TextStyle(color: Colors.red)))),
          ],
        );
      },
    );
  }
}
