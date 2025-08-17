// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:kleanitapp/features/bookings/model/TimeSlotOption.dart';
// import 'package:kleanitapp/features/bookings/repo/Appbooking_repository.dart';
// import 'package:kleanitapp/features/bookings/screens/Appbooking_detail.dart';
// import 'package:kleanitapp/features/bookings/screens/widgets/Appbooking_list_shimmer.dart';
// import 'package:kleanitapp/features/home/Apphome_main.dart';

// import '../../../core/theme/sypd_color.dart';
// import '../bloc/booking_bloc.dart';
// import '../bloc/booking_event.dart';
// import '../bloc/booking_state.dart';
// import '../model/Appbooking.dart';

// class AppBookingList extends StatefulWidget {
//   final String filterTag;

//   const AppBookingList({Key? key, this.filterTag = "All"}) : super(key: key);

//   @override
//   State<AppBookingList> createState() => _AppBookingListState();
// }

// class _AppBookingListState extends State<AppBookingList> {
//   int currentPage = 1;
//   late AppBookingRepository _repo;
//    // selections per week
//   final Map<int, DateTime> _pickedDates = {};   // weekNumber -> date
//   final Map<int, int> _pickedTimeId = {};       // weekNumber -> time id
//   final Map<int, String> _pickedTimeLabel = {}; // weekNumber -> "08:00 AM"

//   @override
//   void initState() {
//     super.initState();
//     _repo = context.read<AppBookingRepository>(); // use the provided instance

//     _loadBookings();
//   }

//   void _loadBookings() {
//     final Map<String, String> statusMap = {
//       "All": "",
//       "Pending": "pending",
//       "Confirmed": "confirmed",
//       "In Progress": "in_progress",
//       "Completed": "completed",
//       "Cancelled": "cancelled",
//     };

//     context.read<BookingBloc>().add(FetchBookings(page: currentPage, status: statusMap[widget.filterTag] ?? ""));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<BookingBloc, BookingState>(
//       builder: (context, state) {
//         if (state is BookingLoading) {
//           return const Center(
//             child: AppBookingListShimmer(),
//             // CircularProgressIndicator()
//           );
//         } else if (state is BookingError) {
//           return Center(child: Text(state.message));
//         } else if (state is BookingLoaded) {
//           final bookings = state.bookings;

//           if (bookings.isEmpty) {
//             return _buildEmptyState(context);
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(20),
//             itemCount: bookings.length,
//             itemBuilder: (context, index) {
//               return buildBookingCard(context, bookings[index]);
//             },
//           );
//         }

//         return _buildEmptyState(context);
//       },
//     );
//   }

//   Widget buildBookingCard(BuildContext context, AppBookingModel booking) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8)),
//           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
//         ],
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: () {
//           Navigator.push(context, MaterialPageRoute(builder: (_) => AppBookingDetail(bookingId: booking.id)));
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(15),
//           child: Row(
//             children: [
//               // _buildBookingImage(booking),
//               // const SizedBox(width: 15),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildHeaderRow(booking),
//                     const SizedBox(height: 8),
//                     _buildDateInfo(booking),
//                     const SizedBox(height: 8),
//                     _buildScheduleInfo(booking),
//                     const SizedBox(height: 8),
//                     _buildItemsSummary(booking),
//                     const SizedBox(height: 8),
//                     _buildFooterRow(booking),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderRow(AppBookingModel booking) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(
//             'Booked ${booking.items.first.thirdCategoryName} ${booking.items.length <= 1 ? '' : '+${booking.items.length - 1}'}',
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ),
//         const SizedBox(width: 10),
//         // Text(
//         //   "AED ${booking.total.toStringAsFixed(2)}",
//         //   style: TextStyle(
//         //     fontSize: 16,
//         //     fontWeight: FontWeight.bold,
//         //     color: primaryColor,
//         //   ),
//         // ),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.asset("assets/icon/aed_symbol.png", width: 16, height: 16, fit: BoxFit.contain),
//             const SizedBox(width: 4),
//             Text(booking.total.toStringAsFixed(2), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildDateInfo(AppBookingModel booking) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
//             const SizedBox(width: 4),
//             Expanded(child: Text(DateFormat("d MMMM, y").format(booking.createdAt.toLocal()), style: TextStyle(color: Colors.grey[600], fontSize: 14))),
//           ],
//         ),
//         Row(
//           children: [
//             Icon(Icons.calendar_today, size: 16, color: primaryColor),
//             const SizedBox(width: 4),
//             Expanded(
//               child:
//               // Text(
//               //   DateFormat("d MMMM, y").format(booking.bookingDate.toLocal()),
//               //   style: TextStyle(color: Colors.grey[600], fontSize: 14),
//               // ),
//               Text(" Booked For: ${booking.bookingDate}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildScheduleInfo(AppBookingModel booking) {
//     return Row(
//       children: [
//         Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
//         const SizedBox(width: 4),
//         Expanded(
//           child: Text(
//             "${booking.schedule.toString()}",
//             // _formatScheduleTimeToLocal(booking),
//             style: TextStyle(color: Colors.grey[600], fontSize: 14),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildItemsSummary(AppBookingModel booking) {
//     if (booking.items.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     final itemCount = booking.items.length;
//     String summaryText;

//     if (itemCount == 1) {
//       summaryText = booking.items[0].thirdCategoryName;
//     } else {
//       summaryText = "${booking.items[0].thirdCategoryName} +${itemCount - 1} more";
//     }

//     return Text(summaryText, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis);
//   }

//   // Widget _buildFooterRow(AppBookingModel booking) {
//   //   return Row(
//   //     children: [
//   //       // if (booking.hasSubscription)
//   //       Container(
//   //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//   //         decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
//   //         child: Row(
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             Icon(Icons.repeat, size: 14, color: Colors.blue[600]),
//   //             const SizedBox(width: 4),
//   //             Text(booking.hasSubscription ? "Subscription" : 'Single', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue[600])),
//   //           ],
//   //         ),
//   //       ),
//   //       const Spacer(),
//   //       // _buildPaymentStatusChip(booking.paymentStatus),
//   //       // const SizedBox(width: 8),
//   //       _buildStatusChip(booking.orderStatus),
//   //     ],
//   //   );
//   // }
//   Widget _buildFooterRow(AppBookingModel booking) {
//     final showSelectDates = _hasAnyUnbooked(booking);

//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.repeat, size: 14, color: Colors.blue[600]),
//               const SizedBox(width: 4),
//               Text(
//                 booking.hasSubscription ? "Subscription" : 'Single',
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue[600]),
//               ),
//             ],
//           ),
//         ),
//         const Spacer(),
//         if (showSelectDates) ...[
//           TextButton.icon(
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: Colors.red.shade600,
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//             onPressed: () => _showSubscriptionDateSheet(context, booking),
//             icon: const Icon(Icons.event_note, size: 16, color: Colors.white),
//             label: const Text("Select dates", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
//           ),
//           const SizedBox(width: 8),
//         ],
//         _buildStatusChip(booking.orderStatus),
//       ],
//     );
//   }
//    DateTime? _tryParseYmd(String s) {
//     try {
//       return DateTime.parse(s);
//     } catch (_) {
//       return null;
//     }
//   }
// void _showSubscriptionDateSheet(BuildContext context, AppBookingModel booking) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) {
//         final weeks = booking.weeklySchedules;

//         return SafeArea(
//           child: SizedBox(
//             height: MediaQuery.of(context).size.height * 0.8,
//             child: weeks.isEmpty
//                 ? const Center(child: Text("No subscription weeks available."))
//                 : StatefulBuilder(
//                     builder: (context, setSheetState) {
//                       return Column(
//                         children: [
//                           // Header
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//                             child: Row(
//                               children: [
//                                 const Expanded(
//                                   child: Text(
//                                     "Select dates & times",
//                                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//                                   ),
//                                 ),
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   child: const Text("Close"),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const Divider(height: 1),

//                           // Weeks list
//                           Expanded(
//                             child: ListView.separated(
//                               padding: const EdgeInsets.all(16),
//                               itemCount: weeks.length,
//                               separatorBuilder: (_, __) => const SizedBox(height: 12),
//                               itemBuilder: (context, i) {
//                                 final w = weeks[i];
//                                 final start = _tryParseYmd(w.startDate);
//                                 final end = _tryParseYmd(w.endDate) ?? start;
//                                 final booked = w.isBooked;
//                                 final selectedDate = _pickedDates[w.weekNumber];
//                                 final selectedTimeId = _pickedTimeId[w.weekNumber];
//                                 final selectedTimeLabel = _pickedTimeLabel[w.weekNumber];

//                                 return Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.05),
//                                         blurRadius: 10,
//                                         offset: const Offset(0, 4),
//                                       ),
//                                     ],
//                                     border: Border.all(
//                                       color: booked ? Colors.green.shade100 : Colors.red.shade100,
//                                     ),
//                                   ),
//                                   padding: const EdgeInsets.all(12),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       // Week header
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               "Week ${w.weekNumber}: "
//                                               "${start != null ? DateFormat('d MMM').format(start) : '--'}"
//                                               " – "
//                                               "${end != null ? DateFormat('d MMM').format(end) : '--'}",
//                                               style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
//                                             ),
//                                           ),
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                             decoration: BoxDecoration(
//                                               color: booked ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
//                                               borderRadius: BorderRadius.circular(8),
//                                             ),
//                                             child: Row(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 Icon(
//                                                   booked ? Icons.check_circle : Icons.error_outline,
//                                                   size: 14,
//                                                   color: booked ? Colors.green : Colors.red,
//                                                 ),
//                                                 const SizedBox(width: 4),
//                                                 Text(
//                                                   booked ? "Booked" : "Not booked",
//                                                   style: TextStyle(
//                                                     color: booked ? Colors.green : Colors.red,
//                                                     fontWeight: FontWeight.w600,
//                                                     fontSize: 12,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),

//                                       const SizedBox(height: 10),

//                                       // Date selector
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               selectedDate != null
//                                                   ? "Selected: ${DateFormat('EEE, d MMM y').format(selectedDate)}"
//                                                   : "Pick a date within this week",
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: selectedDate != null ? Colors.black : Colors.grey[700],
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 8),
//                                           TextButton.icon(
//                                             style: TextButton.styleFrom(
//                                               foregroundColor: Colors.white,
//                                               backgroundColor: booked ? Colors.grey : Colors.red.shade600,
//                                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                             ),
//                                             onPressed: booked || start == null || end == null
//                                                 ? null
//                                                 : () async {
//                                                     final picked = await showDatePicker(
//                                                       context: context,
//                                                       initialDate: selectedDate ?? start,
//                                                       firstDate: start,
//                                                       lastDate: end,
//                                                     );
//                                                     if (picked != null) {
//                                                       setSheetState(() {
//                                                         _pickedDates[w.weekNumber] = picked;
//                                                         _pickedTimeId.remove(w.weekNumber);
//                                                         _pickedTimeLabel.remove(w.weekNumber);
//                                                       });
//                                                     }
//                                                   },
//                                             icon: const Icon(Icons.event_available, size: 18, color: Colors.white),
//                                             label: const Text("Select date", style: TextStyle(color: Colors.white)),
//                                           ),
//                                         ],
//                                       ),

//                                       // Time slots (appear after date picked)
//                                       if (selectedDate != null)
//                                         _TimeSlotsForDate(
//                                           repo: _repo,
//                                           weekNumber: w.weekNumber,
//                                           date: selectedDate,
//                                           selectedTimeId: selectedTimeId,
//                                           onPick: (timeId) => setSheetState(() => _pickedTimeId[w.weekNumber] = timeId),
//                                           onLabel: (label) => setSheetState(() => _pickedTimeLabel[w.weekNumber] = label),
//                                         ),

//                                       if (selectedDate != null && selectedTimeId != null) ...[
//                                         const SizedBox(height: 8),
//                                         Text(
//                                           "Chosen: ${DateFormat('d MMM y').format(selectedDate)} at ${selectedTimeLabel ?? ''}",
//                                           style: const TextStyle(fontWeight: FontWeight.w600),
//                                         ),
//                                       ],
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),

//                           // Bottom action
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: ElevatedButton.icon(
//                                     onPressed: () {
//                                       // TODO: wire to backend save call
//                                       Navigator.pop(context);
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         const SnackBar(content: Text("Selections stored locally (wire to API next).")),
//                                       );
//                                     },
//                                     icon: const Icon(Icons.save),
//                                     label: const Text("Save selections"),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//           ),
//         );
//       },
//     );
//   }
// }

// // --- helper widget that loads time slots for a picked date
// class _TimeSlotsForDate extends StatelessWidget {
//   final AppBookingRepository repo;
//   final int weekNumber;
//   final DateTime date;
//   final int? selectedTimeId;
//   final ValueChanged<int> onPick;     // chosen timeId
//   final ValueChanged<String> onLabel; // chosen label

//   const _TimeSlotsForDate({
//     required this.repo,
//     required this.weekNumber,
//     required this.date,
//     required this.selectedTimeId,
//     required this.onPick,
//     required this.onLabel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<TimeSlotOption>>(
//       future: repo.fetchTimeSlotsForDate(date),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Padding(
//             padding: EdgeInsets.only(top: 8.0),
//             child: LinearProgressIndicator(minHeight: 2),
//           );
//         }
//         if (snap.hasError) {
//           return Padding(
//             padding: const EdgeInsets.only(top: 8.0),
//             child: Text("Failed to load time slots", style: TextStyle(color: Colors.red[700])),
//           );
//         }
//         final slots = snap.data ?? const [];
//         if (slots.isEmpty) {
//           return const Padding(
//             padding: EdgeInsets.only(top: 8.0),
//             child: Text("No time slots on this date."),
//           );
//         }

//         return Padding(
//           padding: const EdgeInsets.only(top: 8.0),
//           child: Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               for (final s in slots)
//                 ChoiceChip(
//                   label: Text(s.scheduleTime),
//                   selected: selectedTimeId != null && s.ids.isNotEmpty && s.ids.first == selectedTimeId,
//                   onSelected: s.available
//                       ? (val) {
//                           if (val && s.ids.isNotEmpty) {
//                             onPick(s.ids.first);
//                             onLabel(s.scheduleTime);
//                           }
//                         }
//                       : null,
//                   disabledColor: Colors.grey.shade200,
//                   labelStyle: TextStyle(
//                     color: s.available ? null : Colors.grey,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//   Widget _buildStatusChip(String status) {
//     Color chipColor;
//     Color textColor;
//     String label = status;
//     IconData iconData;

//     switch (status.toLowerCase()) {
//       case "pending":
//         chipColor = Colors.orange.withOpacity(0.1);
//         textColor = Colors.orange;
//         label = "Pending";
//         iconData = Icons.schedule;
//         break;
//       case "confirmed":
//         chipColor = Colors.blue.withOpacity(0.1);
//         textColor = Colors.blue;
//         label = "Confirmed";
//         iconData = Icons.check;
//         break;
//       case "in_progress":
//         chipColor = Colors.purple.withOpacity(0.1);
//         textColor = Colors.purple;
//         label = "In Progress";
//         iconData = Icons.directions_run;
//         break;
//       case "completed":
//         chipColor = Colors.green.withOpacity(0.1);
//         textColor = Colors.green;
//         label = "Completed";
//         iconData = Icons.done_all;
//         break;
//       case "cancelled":
//         chipColor = Colors.red.withOpacity(0.1);
//         textColor = Colors.red;
//         label = "Cancelled";
//         iconData = Icons.cancel;
//         break;
//       default:
//         chipColor = Colors.grey.withOpacity(0.1);
//         textColor = Colors.grey;
//         label = status.isNotEmpty ? status : "Unknown";
//         iconData = Icons.help;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(8)),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(iconData, size: 12, color: textColor),
//           const SizedBox(width: 4),
//           Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }

//   // Widget _buildPaymentStatusChip(String status) {
//   //   Color chipColor;
//   //   Color textColor;
//   //   String label = status;
//   //   IconData iconData;
//   //
//   //   switch (status.toLowerCase()) {
//   //     case "paid":
//   //       chipColor = Colors.green.withOpacity(0.1);
//   //       textColor = Colors.green;
//   //       label = "Paid";
//   //       iconData = Icons.check_circle;
//   //       break;
//   //     case "pending":
//   //       chipColor = Colors.orange.withOpacity(0.1);
//   //       textColor = Colors.orange;
//   //       label = "Pending";
//   //       iconData = Icons.hourglass_empty;
//   //       break;
//   //     case "failed":
//   //       chipColor = Colors.red.withOpacity(0.1);
//   //       textColor = Colors.red;
//   //       label = "Failed";
//   //       iconData = Icons.error;
//   //       break;
//   //     default:
//   //       chipColor = Colors.grey.withOpacity(0.1);
//   //       textColor = Colors.grey;
//   //       label = status.isNotEmpty ? status : "Unknown";
//   //       iconData = Icons.help;
//   //   }

//   //   return Container(
//   //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//   //     decoration: BoxDecoration(
//   //       color: chipColor,
//   //       borderRadius: BorderRadius.circular(8),
//   //     ),
//   //     child: Row(
//   //       mainAxisSize: MainAxisSize.min,
//   //       children: [
//   //         Icon(iconData, size: 12, color: textColor),
//   //         const SizedBox(width: 4),
//   //         Text(
//   //           label,
//   //           style: TextStyle(
//   //             color: textColor,
//   //             fontSize: 12,
//   //             fontWeight: FontWeight.w600,
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // Widget _buildStatusChip(String status) {
//     Color chipColor;
//     Color textColor;
//     String label = status;
//     IconData iconData;

//     switch (status.toLowerCase()) {
//       case "pending":
//         chipColor = Colors.orange.withOpacity(0.1);
//         textColor = Colors.orange;
//         label = "Pending";
//         iconData = Icons.schedule;
//         break;
//       case "confirmed":
//         chipColor = Colors.blue.withOpacity(0.1);
//         textColor = Colors.blue;
//         label = "Confirmed";
//         iconData = Icons.check;
//         break;
//       case "in_progress":
//         chipColor = Colors.purple.withOpacity(0.1);
//         textColor = Colors.purple;
//         label = "In Progress";
//         iconData = Icons.directions_run;
//         break;
//       case "completed":
//         chipColor = Colors.green.withOpacity(0.1);
//         textColor = Colors.green;
//         label = "Completed";
//         iconData = Icons.done_all;
//         break;
//       case "cancelled":
//         chipColor = Colors.red.withOpacity(0.1);
//         textColor = Colors.red;
//         label = "Cancelled";
//         iconData = Icons.cancel;
//         break;
//       default:
//         chipColor = Colors.grey.withOpacity(0.1);
//         textColor = Colors.grey;
//         label = status.isNotEmpty ? status : "Unknown";
//         iconData = Icons.help;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(8)),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(iconData, size: 12, color: textColor),
//           const SizedBox(width: 4),
//           Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[400]),
//           const SizedBox(height: 20),
//           Text('No Bookings Yet!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])),
//           const SizedBox(height: 10),
//           Text('Book your first service now', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
//           const SizedBox(height: 30),
//           ElevatedButton(
//             onPressed: () {
//               // Go to home
//               currentHomeIndexNotifier.value = 0;
//             },
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//               backgroundColor: primaryColor,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: const Text('Browse Services'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // String _formatScheduleTimeToLocal(BookingModel booking) {
// //   try {
// //     // Extract time (e.g., "14:00")
// //     final timeParts = booking.schedule.scheduleTime.split(':');
// //     final hour = int.parse(timeParts[0]);
// //     final minute = int.parse(timeParts[1]);
// //
// //     // Create datetime with booking date and schedule time
// //     final combinedDateTime = DateTime(
// //       booking.schedule.date.year,
// //       booking.schedule.date.month,
// //       booking.schedule.date.day,
// //       hour,
// //       minute,
// //     );
// //
// //     // Convert to local and format
// //     final localDateTime = combinedDateTime.toLocal();
// //     return DateFormat.jm().format(localDateTime); // e.g., 2:00 PM
// //   } catch (e) {
// //     return booking.schedule.scheduleTime; // fallback
// //   }
// // }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kleanitapp/features/bookings/model/TimeSlotOption.dart'; // NOTE: Ensure file name matches case.
import 'package:kleanitapp/features/bookings/repo/Appbooking_repository.dart';
import 'package:kleanitapp/features/bookings/screens/Appbooking_detail.dart';
import 'package:kleanitapp/features/bookings/screens/widgets/Appbooking_list_shimmer.dart';
import 'package:kleanitapp/features/home/Apphome_main.dart';

import '../../../core/theme/sypd_color.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../model/Appbooking.dart';

class AppBookingList extends StatefulWidget {
  final String filterTag;

  const AppBookingList({Key? key, this.filterTag = "All"}) : super(key: key);

  @override
  State<AppBookingList> createState() => _AppBookingListState();
}

class _AppBookingListState extends State<AppBookingList> {
  int currentPage = 1;
  late AppBookingRepository _repo;

  // selections per week
  final Map<int, DateTime> _pickedDates = {};   // weekNumber -> date
  final Map<int, int> _pickedTimeId = {};       // weekNumber -> time id
  final Map<int, String> _pickedTimeLabel = {}; // weekNumber -> "08:00 AM"

  @override
  void initState() {
    super.initState();
    // _repo = context.read<AppBookingRepository>(); // use the provided instance
    _repo = context.read<BookingBloc>().repository; // ✅ get the same repo from the bloc

    _loadBookings();
  }

  void _loadBookings() {
    final Map<String, String> statusMap = {
      "All": "",
      "Pending": "pending",
      "Confirmed": "confirmed",
      "In Progress": "in_progress",
      "Completed": "completed",
      "Cancelled": "cancelled",
    };

    context
        .read<BookingBloc>()
        .add(FetchBookings(page: currentPage, status: statusMap[widget.filterTag] ?? ""));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(child: AppBookingListShimmer());
        } else if (state is BookingError) {
          return Center(child: Text(state.message));
        } else if (state is BookingLoaded) {
          final bookings = state.bookings;

          if (bookings.isEmpty) return _buildEmptyState(context);

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) => buildBookingCard(context, bookings[index]),
          );
        }
        return _buildEmptyState(context);
      },
    );
  }

  Widget buildBookingCard(BuildContext context, AppBookingModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AppBookingDetail(bookingId: booking.id)));
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderRow(booking),
                    const SizedBox(height: 8),
                    _buildDateInfo(booking),
                    const SizedBox(height: 8),
                    _buildScheduleInfo(booking),
                    const SizedBox(height: 8),
                    _buildItemsSummary(booking),
                    const SizedBox(height: 8),
                    _buildFooterRow(booking),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(AppBookingModel booking) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Booked ${booking.items.first.thirdCategoryName} ${booking.items.length <= 1 ? '' : '+${booking.items.length - 1}'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/icon/aed_symbol.png", width: 16, height: 16, fit: BoxFit.contain),
            const SizedBox(width: 4),
            Text(
              booking.total.toStringAsFixed(2),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateInfo(AppBookingModel booking) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                DateFormat("d MMMM, y").format(booking.createdAt.toLocal()),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: primaryColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                "Booked For: ${booking.bookingDate}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScheduleInfo(AppBookingModel booking) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            booking.schedule,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSummary(AppBookingModel booking) {
    if (booking.items.isEmpty) return const SizedBox.shrink();
    final itemCount = booking.items.length;
    final summary = itemCount == 1
        ? booking.items[0].thirdCategoryName
        : "${booking.items[0].thirdCategoryName} +${itemCount - 1} more";
    return Text(summary, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  // Widget _buildFooterRow(AppBookingModel booking) {
  //   final showSelectDates = _hasAnyUnbooked(booking);
  //
  //   return Row(
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //         decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(Icons.repeat, size: 14, color: Colors.blue[600]),
  //             const SizedBox(width: 4),
  //             Text(
  //               booking.hasSubscription ? "Subscription" : 'Single',
  //               style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue[600]),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const Spacer(),
  //
  //       if (showSelectDates) ...[
  //         TextButton.icon(
  //           style: TextButton.styleFrom(
  //             foregroundColor: Colors.white,
  //             backgroundColor: Colors.red.shade600,
  //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //           ),
  //           onPressed: () => _showSubscriptionDateSheet(context, booking),
  //           icon: const Icon(Icons.event_note, size: 16, color: Colors.white),
  //           label: const Text(
  //             "Select dates",
  //             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //         const SizedBox(width: 8),
  //       ],
  //       _buildStatusChip(booking.orderStatus),
  //     ],
  //   );
  // }
  Widget _buildFooterRow(AppBookingModel booking) {
    final showSelectDates = _hasAnyUnbooked(booking);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: left = subscription/single chip, right = status chip
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.repeat, size: 14, color: Colors.blue[600]),
                  const SizedBox(width: 4),
                  Text(
                    booking.hasSubscription ? "Subscription" : 'Single',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _buildStatusChip(booking.orderStatus),
          ],
        ),

        // Bottom row: right-aligned "Select dates" button (only when needed)
        if (showSelectDates) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showSubscriptionDateSheet(context, booking),
                icon: const Icon(Icons.event_note, size: 16, color: Colors.white),
                label: const Text(
                  "Select dates",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  bool _hasAnyUnbooked(AppBookingModel b) {
    if (!b.hasSubscription) return false;
    if (b.weeklySchedules.isEmpty) return false;
    return b.weeklySchedules.any((w) => !w.isBooked);
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    String label = status;
    IconData iconData;

    switch (status.toLowerCase()) {
      case "pending":
        chipColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        label = "Pending";
        iconData = Icons.schedule;
        break;
      case "confirmed":
        chipColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        label = "Confirmed";
        iconData = Icons.check;
        break;
      case "in_progress":
        chipColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        label = "In Progress";
        iconData = Icons.directions_run;
        break;
      case "completed":
        chipColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        label = "Completed";
        iconData = Icons.done_all;
        break;
      case "cancelled":
        chipColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        label = "Cancelled";
        iconData = Icons.cancel;
        break;
      default:
        chipColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        label = status.isNotEmpty ? status : "Unknown";
        iconData = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text('No Bookings Yet!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 10),
          Text('Book your first service now', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Go to home
              currentHomeIndexNotifier.value = 0;
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Browse Services'),
          ),
        ],
      ),
    );
  }

  DateTime? _tryParseYmd(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  void _showSubscriptionDateSheet(BuildContext context, AppBookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final weeks = booking.weeklySchedules;

        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: weeks.isEmpty
                ? const Center(child: Text("No subscription weeks available."))
                : StatefulBuilder(
                    builder: (context, setSheetState) {
                      return Column(
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Select dates & times",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),

                          // Weeks list
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: weeks.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final w = weeks[i];
                                final start = _tryParseYmd(w.startDate);
                                final end = _tryParseYmd(w.endDate) ?? start;
                                final booked = w.isBooked;
                                final selectedDate = _pickedDates[w.weekNumber];
                                final selectedTimeId = _pickedTimeId[w.weekNumber];
                                final selectedTimeLabel = _pickedTimeLabel[w.weekNumber];

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: booked ? Colors.green.shade100 : Colors.red.shade100,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Week header
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Week ${w.weekNumber}: "
                                              "${start != null ? DateFormat('d MMM').format(start) : '--'}"
                                              " – "
                                              "${end != null ? DateFormat('d MMM').format(end) : '--'}",
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: booked ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  booked ? Icons.check_circle : Icons.error_outline,
                                                  size: 14,
                                                  color: booked ? Colors.green : Colors.red,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  booked ? "Booked" : "Not booked",
                                                  style: TextStyle(
                                                    color: booked ? Colors.green : Colors.red,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),

                                      // Date selector
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              selectedDate != null
                                                  ? "Selected: ${DateFormat('EEE, d MMM y').format(selectedDate)}"
                                                  : "Pick a date within this week",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: selectedDate != null ? Colors.black : Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton.icon(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: booked ? Colors.grey : Colors.red.shade600,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            onPressed: booked || start == null || end == null
                                                ? null
                                                : () async {
                                                    final picked = await showDatePicker(
                                                      context: context,
                                                      initialDate: selectedDate ?? start,
                                                      firstDate: start!,
                                                      lastDate: end!,
                                                    );
                                                    if (picked != null) {
                                                      setSheetState(() {
                                                        _pickedDates[w.weekNumber] = picked;
                                                        _pickedTimeId.remove(w.weekNumber);
                                                        _pickedTimeLabel.remove(w.weekNumber);
                                                      });
                                                    }
                                                  },
                                            icon: const Icon(Icons.event_available, size: 18, color: Colors.white),
                                            label: const Text("Select date", style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),

                                      // Time slots (appear after date picked)
                                      if (selectedDate != null)
                                        _TimeSlotsForDate(
                                          repo: _repo,
                                          weekNumber: w.weekNumber,
                                          date: selectedDate,
                                          selectedTimeId: selectedTimeId,
                                          onPick: (timeId) => setSheetState(() => _pickedTimeId[w.weekNumber] = timeId),
                                          onLabel: (label) => setSheetState(() => _pickedTimeLabel[w.weekNumber] = label),
                                        ),

                                      if (selectedDate != null && selectedTimeId != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          "Chosen: ${DateFormat('d MMM y').format(selectedDate)} at ${selectedTimeLabel ?? ''}",
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // Bottom action
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // TODO: wire to backend save call using:
                                      // _pickedDates[weekNumber], _pickedTimeId[weekNumber], _pickedTimeLabel[weekNumber]
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Selections stored locally (wire to API next).")),
                                      );
                                    },
                                    icon: const Icon(Icons.save),
                                    label: const Text("Save selections"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

// --- helper widget that loads time slots for a picked date
class _TimeSlotsForDate extends StatelessWidget {
  final AppBookingRepository repo;
  final int weekNumber;
  final DateTime date;
  final int? selectedTimeId;
  final ValueChanged<int> onPick;     // chosen timeId
  final ValueChanged<String> onLabel; // chosen label

  const _TimeSlotsForDate({
    required this.repo,
    required this.weekNumber,
    required this.date,
    required this.selectedTimeId,
    required this.onPick,
    required this.onLabel,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TimeSlotOption>>(
      future: repo.fetchTimeSlotsForDate(date),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(minHeight: 2),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text("Failed to load time slots", style: TextStyle(color: Colors.red[700])),
          );
        }
        final slots = snap.data ?? const [];
        if (slots.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text("No time slots on this date."),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in slots)
                ChoiceChip(
                  label: Text(s.scheduleTime),
                  selected: selectedTimeId != null && s.ids.isNotEmpty && s.ids.first == selectedTimeId,
                  onSelected: s.available
                      ? (val) {
                          if (val && s.ids.isNotEmpty) {
                            onPick(s.ids.first);
                            onLabel(s.scheduleTime);
                          }
                        }
                      : null,
                  disabledColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: s.available ? null : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
