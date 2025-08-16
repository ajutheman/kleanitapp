import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
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

    context.read<BookingBloc>().add(FetchBookings(page: currentPage, status: statusMap[widget.filterTag] ?? ""));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(
            child: AppBookingListShimmer(),
            // CircularProgressIndicator()
          );
        } else if (state is BookingError) {
          return Center(child: Text(state.message));
        } else if (state is BookingLoaded) {
          final bookings = state.bookings;

          if (bookings.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return buildBookingCard(context, bookings[index]);
            },
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
              // _buildBookingImage(booking),
              // const SizedBox(width: 15),
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
        // Text(
        //   "AED ${booking.total.toStringAsFixed(2)}",
        //   style: TextStyle(
        //     fontSize: 16,
        //     fontWeight: FontWeight.bold,
        //     color: primaryColor,
        //   ),
        // ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/icon/aed_symbol.png", width: 16, height: 16, fit: BoxFit.contain),
            const SizedBox(width: 4),
            Text(booking.total.toStringAsFixed(2), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
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
            Expanded(child: Text(DateFormat("d MMMM, y").format(booking.createdAt.toLocal()), style: TextStyle(color: Colors.grey[600], fontSize: 14))),
          ],
        ),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: primaryColor),
            const SizedBox(width: 4),
            Expanded(
              child:
              // Text(
              //   DateFormat("d MMMM, y").format(booking.bookingDate.toLocal()),
              //   style: TextStyle(color: Colors.grey[600], fontSize: 14),
              // ),
              Text(" Booked For: ${booking.bookingDate}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
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
            "${booking.schedule.toString()}",
            // _formatScheduleTimeToLocal(booking),
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSummary(AppBookingModel booking) {
    if (booking.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemCount = booking.items.length;
    String summaryText;

    if (itemCount == 1) {
      summaryText = booking.items[0].thirdCategoryName;
    } else {
      summaryText = "${booking.items[0].thirdCategoryName} +${itemCount - 1} more";
    }

    return Text(summaryText, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  Widget _buildFooterRow(AppBookingModel booking) {
    return Row(
      children: [
        // if (booking.hasSubscription)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.repeat, size: 14, color: Colors.blue[600]),
              const SizedBox(width: 4),
              Text(booking.hasSubscription ? "Subscription" : 'Single', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue[600])),
            ],
          ),
        ),
        const Spacer(),
        // _buildPaymentStatusChip(booking.paymentStatus),
        // const SizedBox(width: 8),
        _buildStatusChip(booking.orderStatus),
      ],
    );
  }

  // Widget _buildPaymentStatusChip(String status) {
  //   Color chipColor;
  //   Color textColor;
  //   String label = status;
  //   IconData iconData;
  //
  //   switch (status.toLowerCase()) {
  //     case "paid":
  //       chipColor = Colors.green.withOpacity(0.1);
  //       textColor = Colors.green;
  //       label = "Paid";
  //       iconData = Icons.check_circle;
  //       break;
  //     case "pending":
  //       chipColor = Colors.orange.withOpacity(0.1);
  //       textColor = Colors.orange;
  //       label = "Pending";
  //       iconData = Icons.hourglass_empty;
  //       break;
  //     case "failed":
  //       chipColor = Colors.red.withOpacity(0.1);
  //       textColor = Colors.red;
  //       label = "Failed";
  //       iconData = Icons.error;
  //       break;
  //     default:
  //       chipColor = Colors.grey.withOpacity(0.1);
  //       textColor = Colors.grey;
  //       label = status.isNotEmpty ? status : "Unknown";
  //       iconData = Icons.help;
  //   }

  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: chipColor,
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(iconData, size: 12, color: textColor),
  //         const SizedBox(width: 4),
  //         Text(
  //           label,
  //           style: TextStyle(
  //             color: textColor,
  //             fontSize: 12,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
}

// String _formatScheduleTimeToLocal(BookingModel booking) {
//   try {
//     // Extract time (e.g., "14:00")
//     final timeParts = booking.schedule.scheduleTime.split(':');
//     final hour = int.parse(timeParts[0]);
//     final minute = int.parse(timeParts[1]);
//
//     // Create datetime with booking date and schedule time
//     final combinedDateTime = DateTime(
//       booking.schedule.date.year,
//       booking.schedule.date.month,
//       booking.schedule.date.day,
//       hour,
//       minute,
//     );
//
//     // Convert to local and format
//     final localDateTime = combinedDateTime.toLocal();
//     return DateFormat.jm().format(localDateTime); // e.g., 2:00 PM
//   } catch (e) {
//     return booking.schedule.scheduleTime; // fallback
//   }
// }
