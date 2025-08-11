import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kleanitapp/features/bookings/screens/widgets/weekly_schedule_selector.dart';
import 'package:kleanitapp/presentation/widgets/error_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/Constant.dart';
import '../../../core/constants/pref_resources.dart';
import '../../../core/theme/color_data.dart';
import '../../../core/theme/resizer/fetch_pixels.dart';
import '../../../core/theme/widget_utils.dart';
import '../../home/write_review_section.dart';
import '../bloc/booking_detail_bloc.dart';
import '../bloc/booking_detail_event.dart';
import '../bloc/booking_detail_state.dart';
import '../model/book_detail.dart';
import '../repo/booking_repository.dart';

class BookingDetail extends StatefulWidget {
  final String bookingId;

  const BookingDetail({super.key, required this.bookingId});

  @override
  State<BookingDetail> createState() => _BookingDetailState();
}

class _BookingDetailState extends State<BookingDetail> {
  BookingDetails? bookingDetails;
  bool isDownloading = false;

  @override
  void initState() {
    loadOrderDetails();
    super.initState();
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefResources.USER_ACCESS_TOCKEN);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      resizeToAvoidBottomInset: true,
      backgroundColor: backGroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // Match your custom styling
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: getSvgImage("back.svg", height: FetchPixels.getPixelHeight(24), width: FetchPixels.getPixelHeight(24)),
          onPressed: () {
            Constant.backToPrev(context);
          },
        ),
        title: getCustomFont("Order", 24, Colors.black, 1, fontWeight: FontWeight.w800, fontFamily: Constant.fontsFamily),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              showCancelOrderDialog(context, orderId: widget.bookingId);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[const PopupMenuItem<String>(value: 'cancel', child: Text('Cancel'))],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            BlocConsumer<BookingDetailBloc, BookingDetailState>(
              listener: (ctx, state) {
                if (state is BookingDetailLoaded) {
                  setState(() {
                    bookingDetails = state.booking;
                  });
                }
              },
              builder: (context, state) {
                if (state is BookingDetailLoading || state is CancelOrderLoading) {
                  return Expanded(child: const Center(child: CircularProgressIndicator()));
                } else if (state is BookingDetailError) {
                  return Expanded(child: Center(child: MyErrorWidget(onRetry: () => loadOrderDetails(), message: state.message)));
                } else if (state is CancelOrderFailure) {
                  return Expanded(child: Center(child: MyErrorWidget(onRetry: () => loadOrderDetails(), message: state.message)));
                }
                if (bookingDetails == null) return SizedBox();
                final statusColor = _getStatusColor(bookingDetails!.orderStatus);
                final statusLabel = _getStatusLabel(bookingDetails!.orderStatus);
                return Expanded(
                  flex: 1,
                  child: ListView(
                    primary: true,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Order summary card
                      getPaddingWidget(
                        EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(20)),
                        Container(
                          padding: EdgeInsets.all(FetchPixels.getPixelHeight(16)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0))],
                            borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  getCustomFont(DateFormat('d MMMM, y').format(DateTime.parse(bookingDetails!.createdAt).toLocal()), 14, textColor, 1, fontWeight: FontWeight.w400),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(10), vertical: FetchPixels.getPixelHeight(6)),
                                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(6))),
                                    child: getCustomFont(statusLabel, 12, statusColor, 1, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              getVerSpace(FetchPixels.getPixelHeight(12)),

                              // Booking schedule
                              Container(
                                padding: EdgeInsets.all(FetchPixels.getPixelHeight(12)),
                                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(8))),
                                child: Row(
                                  children: [
                                    getSvgImage("calender.svg", width: FetchPixels.getPixelHeight(24), height: FetchPixels.getPixelHeight(24)),
                                    getHorSpace(FetchPixels.getPixelWidth(10)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          getCustomFont("Schedule", 14, Colors.black87, 1, fontWeight: FontWeight.w600),
                                          getVerSpace(FetchPixels.getPixelHeight(4)),
                                          getCustomFont(
                                            bookingDetails!.scheduledTime,

                                            // bookingDetails!.scheduledTime.scheduleTime,
                                            13,
                                            textColor,
                                            2,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              getVerSpace(FetchPixels.getPixelHeight(12)),

                              // Service type and price
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Fixed Header Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      getCustomFont("Service Type", 14, Colors.black87, 1, fontWeight: FontWeight.w600),
                                      getCustomFont("Price", 14, Colors.black87, 1, fontWeight: FontWeight.w600),
                                    ],
                                  ),
                                  getVerSpace(FetchPixels.getPixelHeight(10)), // Spacing after header
                                  // Dynamic List of Services
                                  ...bookingDetails!.items
                                      .map(
                                        (e) => Padding(
                                          padding: EdgeInsets.only(bottom: FetchPixels.getPixelHeight(4)), // Adjust spacing
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(child: getCustomFont(e.thirdCategory.name, 13, textColor, 2, fontWeight: FontWeight.w400)),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Image.asset(
                                                    'assets/icon/aed_symbol.png',
                                                    width: 14,
                                                    height: 14,
                                                    fit: BoxFit.contain,
                                                    // color: primaryColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  getCustomFont(" ${e.itemTotal}", 16, primaryColor, 1, fontWeight: FontWeight.w800),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ],
                              ),
                              getVerSpace(FetchPixels.getPixelHeight(12)),

                              // Payment status
                              Container(
                                padding: EdgeInsets.all(FetchPixels.getPixelHeight(12)),
                                decoration: BoxDecoration(
                                  color: bookingDetails!.paymentStatus.toLowerCase() == 'paid' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(8)),
                                ),
                                child: Row(
                                  children: [
                                    getSvgImage(
                                      bookingDetails!.paymentStatus.toLowerCase() == 'paid' ? "check_complete.svg" : "clock.svg",
                                      width: FetchPixels.getPixelHeight(24),
                                      height: FetchPixels.getPixelHeight(24),
                                    ),
                                    getHorSpace(FetchPixels.getPixelWidth(10)),
                                    getCustomFont(
                                      bookingDetails!.paymentStatus.toLowerCase() == 'paid' ? "Payment Completed" : "Payment Pending",
                                      14,
                                      bookingDetails!.paymentStatus.toLowerCase() == 'paid' ? Colors.green : Colors.orange,
                                      1,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),

                              if (bookingDetails!.hasSubscription) ...[
                                getVerSpace(FetchPixels.getPixelHeight(12)),
                                Container(
                                  padding: EdgeInsets.all(FetchPixels.getPixelHeight(12)),
                                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(8))),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          getCustomFont("Subscription Service", 14, Colors.blue, 1, fontWeight: FontWeight.w600),
                                          getVerSpace(FetchPixels.getPixelHeight(4)),
                                          getCustomFont("Recurring service scheduled", 13, Colors.blue.shade700, 1, fontWeight: FontWeight.w400),
                                        ],
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap: () {
                                          showWorkingDaysDialog(context, bookingDetails!.id);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(12), vertical: FetchPixels.getPixelHeight(6)),
                                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(6))),
                                          child: getCustomFont("Select Days", 13, Colors.white, 1, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Service provider section
                      if (bookingDetails!.orderStatus.toLowerCase() == 'confirmed' || bookingDetails!.orderStatus.toLowerCase() == 'in_progress') ...[
                        getPaddingWidget(
                          EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(20)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getVerSpace(FetchPixels.getPixelHeight(30)),
                              getCustomFont("Service Provider", 20, Colors.black, 1, fontWeight: FontWeight.w800),
                              getVerSpace(FetchPixels.getPixelHeight(16)),
                              Container(
                                padding: EdgeInsets.all(FetchPixels.getPixelHeight(16)),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0))],
                                  borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: FetchPixels.getPixelHeight(60),
                                      width: FetchPixels.getPixelHeight(60),
                                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(30))),
                                      child: Center(child: getSvgImage("user.svg", width: FetchPixels.getPixelHeight(30), height: FetchPixels.getPixelHeight(30))),
                                    ),
                                    getHorSpace(FetchPixels.getPixelWidth(15)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          getCustomFont("Service Provider", 14, Colors.black87, 1, fontWeight: FontWeight.w600),
                                          getVerSpace(FetchPixels.getPixelHeight(4)),
                                          getCustomFont("Professional technician", 13, textColor, 1, fontWeight: FontWeight.w400),
                                          getVerSpace(FetchPixels.getPixelHeight(8)),
                                          Row(
                                            children: [
                                              getSvgImage("star.svg", width: FetchPixels.getPixelHeight(16), height: FetchPixels.getPixelHeight(16)),
                                              getHorSpace(FetchPixels.getPixelWidth(6)),
                                              getCustomFont("4.5", 14, Colors.black, 1, fontWeight: FontWeight.w400),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: FetchPixels.getPixelHeight(42),
                                      width: FetchPixels.getPixelHeight(42),
                                      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(21))),
                                      child: Center(
                                        child: getSvgImage("call.svg", width: FetchPixels.getPixelHeight(20), height: FetchPixels.getPixelHeight(20), color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Options section
                      getPaddingWidget(
                        EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(20)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getVerSpace(FetchPixels.getPixelHeight(30)),
                            getCustomFont("Booking Options", 20, Colors.black, 1, fontWeight: FontWeight.w800),
                            getVerSpace(FetchPixels.getPixelHeight(16)),

                            // Invoice download
                            // getButtonWithIcon(
                            //   context,
                            //   Colors.white,
                            //   "Download Invoice",
                            //   Colors.black,
                            //   () {},
                            //   16,
                            //   weight: FontWeight.w600,
                            //   buttonHeight: FetchPixels.getPixelHeight(60),
                            //   borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
                            //   boxShadow: [
                            //     const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0)),
                            //   ],
                            //   prefixIcon: true,
                            //   prefixImage: "download.svg",
                            //   sufixIcon: true,
                            //   suffixImage: "arrow_right.svg",
                            // ),
                            getVerSpace(FetchPixels.getPixelHeight(1)),
                            _buildInvoiceDownloadButton(),

                            // Customer support
                            // getButtonWithIcon(
                            //   context,
                            //   Colors.white,
                            //   "Customer Support",
                            //   Colors.black,
                            //   () {},
                            //   16,
                            //   weight: FontWeight.w600,
                            //   buttonHeight: FetchPixels.getPixelHeight(60),
                            //   borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
                            //   boxShadow: [
                            //     const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0)),
                            //   ],
                            //   prefixIcon: true,
                            //   prefixImage: "headset.svg",
                            //   sufixIcon: true,
                            //   suffixImage: "arrow_right.svg",
                            // ),
                            getVerSpace(FetchPixels.getPixelHeight(10)),

                            // Add this method inside your _BookingDetailState class

                            // Add this inside the build method where you list the booking options
                            getPaddingWidget(
                              EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(5)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // getVerSpace(FetchPixels.getPixelHeight(30)),
                                  // getCustomFont("Booking Options", 20, Colors.black, 1, fontWeight: FontWeight.w800),
                                  // getVerSpace(FetchPixels.getPixelHeight(16)),

                                  // Customer Support Button
                                  GestureDetector(
                                    onTap:
                                        () => _openWhatsApp(
                                          context,
                                          "+971501887853", // Replace with your support number
                                          bookingDetails: bookingDetails, // Pass the booking details here
                                        ), // Replace with your support number
                                    child: Container(
                                      width: FetchPixels.getPixelHeight(390),
                                      // double.infinity,
                                      height: FetchPixels.getPixelHeight(60),
                                      margin: EdgeInsets.only(bottom: FetchPixels.getPixelHeight(16)),
                                      padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(18)),
                                      decoration: getButtonDecoration(
                                        Colors.white,
                                        borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
                                        shadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0))],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              // getSvgImage("Booking Options"),
                                              getHorSpace(FetchPixels.getPixelWidth(12)),
                                              getCustomFont("Customer Support", 16, Colors.black, 1, textAlign: TextAlign.center, fontWeight: FontWeight.w600),
                                            ],
                                          ),
                                          Row(children: [getSvgImage("arrow_right.svg"), getHorSpace(FetchPixels.getPixelWidth(18))]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Service warranty
                            getButtonWithIcon(
                              context,
                              Colors.white,
                              "Service Warranty",
                              Colors.black,
                              () {
                                _showServiceWarrantyDialog(context, bookingDetails!.orderNumber);
                              },
                              16,
                              weight: FontWeight.w600,
                              buttonHeight: FetchPixels.getPixelHeight(60),
                              borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
                              boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0))],
                              prefixIcon: true,
                              prefixImage: "safe.svg",
                              sufixIcon: true,
                              suffixImage: "arrow_right.svg",
                            ),
                          ],
                        ),
                      ),

                      // Service details section
                      getVerSpace(FetchPixels.getPixelHeight(30)),

                      Container(
                        color: const Color(0xFFF2F4F8),
                        padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(20), vertical: FetchPixels.getPixelHeight(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getCustomFont("Service Details", 18, Colors.black, 1, fontWeight: FontWeight.w700),
                            getVerSpace(FetchPixels.getPixelHeight(16)),

                            // Service items
                            ...bookingDetails!.items.map(
                              (item) => Container(
                                margin: EdgeInsets.only(bottom: FetchPixels.getPixelHeight(12)),
                                padding: EdgeInsets.all(FetchPixels.getPixelHeight(12)),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(8)),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0.0, 2.0))],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: FetchPixels.getPixelHeight(40),
                                      width: FetchPixels.getPixelHeight(40),
                                      decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(8))),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(8)),
                                        child: Image.network(item.thirdCategory.image, fit: BoxFit.cover),
                                      ),
                                      // child: Center(
                                      //   child: getSvgImage(
                                      //     item.type == 'service' ? "service.svg" : "product.svg",
                                      //     width: FetchPixels.getPixelHeight(24),
                                      //     height: FetchPixels.getPixelHeight(24),
                                      //   ),
                                      // ),
                                    ),
                                    getHorSpace(FetchPixels.getPixelWidth(12)),
                                    Expanded(child: getCustomFont(item.thirdCategory.name, 14, Colors.black, 2, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Need help section
                      // getPaddingWidget(
                      //   EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(20)),
                      //   Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       getVerSpace(FetchPixels.getPixelHeight(30)),
                      //       getCustomFont("Need Help?", 20, Colors.black, 1, fontWeight: FontWeight.w800),
                      //       getVerSpace(FetchPixels.getPixelHeight(16)),
                      //
                      //       // Help options
                      //       Container(
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
                      //           boxShadow: const [
                      //             BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0)),
                      //           ],
                      //         ),
                      //         child: Column(
                      //           children: [
                      //             _buildHelpOption(
                      //               "Professional not assigned",
                      //               () {},
                      //             ),
                      //             Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                      //             _buildHelpOption(
                      //               "I'm unhappy with my booking experience",
                      //               () {},
                      //             ),
                      //             Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                      //             _buildHelpOption(
                      //               "Need help with other issues",
                      //               () {},
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      getVerSpace(FetchPixels.getPixelHeight(30)),

                      WriteReviewSection(secondCategoryId: bookingDetails!.items.first.thirdCategory.secondCatId),
                      getVerSpace(FetchPixels.getPixelHeight(30)),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(16), vertical: FetchPixels.getPixelHeight(16)),
        child: Row(
          children: [
            Expanded(child: getCustomFont(title, 14, Colors.black, 1, fontWeight: FontWeight.w500)),
            getSvgImage("arrow_right.svg", width: FetchPixels.getPixelHeight(20), height: FetchPixels.getPixelHeight(20)),
          ],
        ),
      ),
    );
  }

  // Example usage:
  void showWorkingDaysDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WeeklyScheduleSelector(orderId: orderId);
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return success;
      case 'in_progress':
        return primaryColor;
      case 'completed':
        return completed;
      case 'cancelled':
        return error;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Booking Pending';
      case 'confirmed':
        return 'Booking Confirmed';
      case 'in_progress':
        return 'Service In Progress';
      case 'completed':
        return 'Booking Completed';
      case 'cancelled':
        return 'Booking Cancelled';
      default:
        return 'Booking Status Unknown';
    }
  }

  Future<Map<String, dynamic>?> showCancelOrderDialog(BuildContext context, {required String orderId}) async {
    // List of common cancellation reasons
    final List<String> cancellationReasons = [
      'Changed my mind',
      'Found a better price elsewhere',
      'Ordered by mistake',
      'Shipping takes too long',
      'Product no longer needed',
      'Other reason',
    ];

    // Selected reason and custom reason text
    String? selectedReason;
    final TextEditingController customReasonCtrl = TextEditingController();
    bool isCustomReason = false;

    // Form key for validation
    final formKey = GlobalKey<FormState>();

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 24, top: 65, right: 24, bottom: 24),
                    margin: const EdgeInsets.only(top: 45),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Cancel Order', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('Are you sure you want to cancel order?', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                          const SizedBox(height: 24),

                          // Cancellation reason selection section
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: [
                                Text(
                                  'Cancellation Policy:Orders may be cancelled only if requested at least 48 hours prior to the scheduled time. Cancellations outside this window cannot be accommodated.',
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700, height: 1.4),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Rescheduling Policy:Orders may be rescheduled only if requested at least 24 hours prior to the scheduled time. Rescheduling requests outside this window are subject to availability and approval. Kindly request via customer support.',
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700, height: 1.4),
                                ),
                                Text('Please select a reason for cancellation:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade800)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Reason option cards
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: SingleChildScrollView(
                              child: Column(
                                children:
                                    cancellationReasons.map((reason) {
                                      final isSelected = reason == selectedReason;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedReason = reason;
                                            isCustomReason = reason == 'Other reason';
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: isSelected ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                                            border: Border.all(color: isSelected ? Colors.red : Colors.grey.withOpacity(0.15), width: 1.5),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                reason,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                  color: isSelected ? Colors.red : Colors.black87,
                                                ),
                                              ),
                                              if (isSelected) const Icon(Icons.check_circle, color: Colors.red, size: 20),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),

                          // Custom reason text field (visible only when "Other reason" is selected)
                          if (isCustomReason) ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: customReasonCtrl,
                              decoration: InputDecoration(
                                hintText: 'Please specify your reason...',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
                                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red.shade300)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              validator: (value) {
                                if (isCustomReason && (value == null || value.trim().isEmpty)) {
                                  return 'Please specify your cancellation reason';
                                }
                                return null;
                              },
                              minLines: 3,
                              maxLines: 5,
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey.shade800,
                                    backgroundColor: Colors.grey.shade100,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Go Back', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (selectedReason == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a cancellation reason'), backgroundColor: Colors.red));
                                      return;
                                    }

                                    if (formKey.currentState!.validate()) {
                                      // Navigator.of(context).pop({
                                      //   'reason': isCustomReason ? customReasonCtrl.text : selectedReason,
                                      //   'timestamp': DateTime.now().toIso8601String(),
                                      // });
                                      context.read<BookingDetailBloc>().add(
                                        CancelOrder(orderId: widget.bookingId, reason: isCustomReason ? customReasonCtrl.text : selectedReason!),
                                      );
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Cancel Order', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top cancel icon
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 45,
                      child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(45)), child: Icon(Icons.close, color: Colors.white, size: 45)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  loadOrderDetails() {
    context.read<BookingDetailBloc>().add(FetchBookingDetail(widget.bookingId));
  }

  Widget _buildInvoiceDownloadButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: FetchPixels.getPixelHeight(2)),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: FetchPixels.getPixelHeight(10)),
        padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(8)),
        width: double.infinity,
        height: FetchPixels.getPixelHeight(60),
        child: ElevatedButton.icon(
          onPressed:
              isDownloading
                  ? null
                  : () async {
                    try {
                      setState(() {
                        isDownloading = true;
                      });

                      final encryptedInvoiceId = bookingDetails!.id;
                      final bookingRepository = BookingRepository();
                      final token = await _getAccessToken();
                      // Fetch the access token
                      // final token = await bookingRepository._getAccessToken();
                      if (token == null) throw Exception("Unauthorized: Token not found");

                      // final url = "https://kleanit.planetprouae.com/api/customer/orders/invoice/$encryptedInvoiceId";
                      final url = "https://backend.kleanit.ae/api/customer/orders/invoice/$encryptedInvoiceId";
                      final directory = await getApplicationDocumentsDirectory();
                      final filePath = "${directory.path}/invoice_$encryptedInvoiceId.pdf";

                      final response = await bookingRepository.dio.download(
                        url,
                        filePath,
                        options: Options(headers: {"Authorization": "Bearer $token", "Accept": "application/pdf"}),
                      );

                      if (response.statusCode == 200) {
                        await OpenFile.open(filePath);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invoice downloaded successfully")));
                        print("Invoice downloaded successfully: $filePath");
                      } else {
                        print("Failed to download invoice. Status Code: ${response.statusCode}");
                        throw Exception("Failed to download invoice");
                      }
                    } catch (e) {
                      print("Download Error: $e");
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error downloading invoice: $e")));
                    } finally {
                      setState(() {
                        isDownloading = false;
                      });
                    }
                  },
          icon: isDownloading ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2) : const Icon(Icons.file_download),
          label: Text(isDownloading ? "Downloading..." : "Download Invoice"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  void _openWhatsApp(BuildContext context, String phoneNumber, {BookingDetails? bookingDetails}) async {
    String message = "Hello, I need support regarding my booking.";

    // Add order details if available
    if (bookingDetails != null) {
      message += "\n\nOrder Details:\n";
      message += "Order Number: ${bookingDetails.orderNumber}\n";
      message += "Order Date: ${DateFormat('d MMMM, y').format(DateTime.parse(bookingDetails.createdAt).toLocal())}\n";
      message += "Subtotal: AED ${bookingDetails.subtotal}\n";
      message += "Total Amount: AED ${bookingDetails.total}\n";
      message += "Payment Status: ${bookingDetails.paymentStatus}\n";
      message += "Order Status: ${bookingDetails.orderStatus}\n";
    }

    final String encodedMessage = Uri.encodeComponent(message);
    final url = "https://wa.me/${phoneNumber.replaceAll("+", "")}?text=$encodedMessage";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open WhatsApp")));
    }
  }

  void _showServiceWarrantyDialog(BuildContext context, String serviceName) {
    const Color darkTeal = Color(0xFF073F4A); // From your image
    const Color lightTeal = Color(0xFF2C7A7B); // Lighter complementary shade

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Gradient container
              Container(
                padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
                margin: const EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [darkTeal, lightTeal]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Service Warranty", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    Text(
                      "You're viewing warranty details for:\n\n🛠️ $serviceName\n\n"
                      "⚡ If issues arise, we provide a free resolution.\n"
                      "📞 Contact support: +971 501887853",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: darkTeal,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Got it!"),
                    ),
                  ],
                ),
              ),

              // Gradient CircleAvatar
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [lightTeal, darkTeal], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: const Center(child: Icon(Icons.verified, size: 40, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
