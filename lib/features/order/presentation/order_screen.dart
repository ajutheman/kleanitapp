import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:kleanitapp/core/constants/constants.dart';
import 'package:kleanitapp/core/theme/color_data.dart';
import 'package:kleanitapp/core/utils/hepler.dart';
import 'package:kleanitapp/features/address/bloc/address_bloc.dart';
import 'package:kleanitapp/features/address/bloc/address_event.dart';
import 'package:kleanitapp/features/address/screens/address_list_screen.dart';
import 'package:kleanitapp/features/cart/model/cart.dart';
import 'package:kleanitapp/features/home/home_main.dart';
import 'package:kleanitapp/features/order/bloc/coupon/coupon_event.dart';
import 'package:kleanitapp/features/order/bloc/order_bloc.dart';
import 'package:kleanitapp/features/order/bloc/order_event.dart';
import 'package:kleanitapp/features/order/bloc/order_state.dart';
import 'package:kleanitapp/features/order/model/order_calculation.dart';

import '../../../presentation/widgets/error_widget.dart';
import '../../address/bloc/address_state.dart';
import '../../address/model/address.dart';
import '../../cart/bloc/cart_bloc.dart';
import '../../cart/bloc/cart_event.dart';
import '../bloc/coupon/coupon_bloc.dart';
import '../bloc/coupon/coupon_state.dart';
import '../model/time_schedule.dart';

List<int> frequencies = [1, 3, 6];

class OrderConfirmationScreen extends StatefulWidget {
  final List<Cart> carts;

  const OrderConfirmationScreen({super.key, required this.carts});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

enum PropertyType {
  residential,
  commercial;

  static PropertyType fromString(String value) {
    return PropertyType.values.firstWhere((e) => e.name == value, orElse: () => PropertyType.residential);
  }
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  PropertyType selectedPropertyType = PropertyType.residential;

  final _notesController = TextEditingController();

  bool isShowSubFeq = false;
  int? selectedSubFeq;
  final TextEditingController _couponController = TextEditingController();
  String appliedCoupon = '';

  TimeSchedule? selectedSchedule;
  CustomerAddress? currentAddress;
  List<TimeSchedule> timeSchedules = [];
  late DateTime selectedDate;

  int bedrooms = 0;
  int bathrooms = 0;
  int beds = 0;
  int sofaBeds = 1;
  int occupancy = 1;
  bool petsPresent = false;
  bool withLinen = true;
  bool withSupplies = true;
  String checkInTime = "08:00";
  String checkOutTime = "10:00";
  String doorAccessCode = " doorAccessCode";
  String nextGuestCheckInTime = "12:00";
  String wifiAccessCode = " doorAccessCode";
  String typeOfCleaning = "Check Out";

  final List<String> cleaningOptions = ["Check Out", "In Stay", "Touch up"];

  String selectedPaymentMethod = PaymentMethod.STRIPE;

  @override
  void initState() {
    super.initState();
    setDefaultAddress();

    selectedDate = DateTime.now();

    // Fetch schedule list
    loadOrderCalculations();
    context.read<CouponBloc>().add(ClearCoupon());
    context.read<OrderBloc>().add(FetchSchedules(date: selectedDate));
    isShowSubFeq = widget.carts.length == 1 && widget.carts.first.type == SubscriptionType.SUBSCRIPTION;
    if (isShowSubFeq) {
      selectedSubFeq = 1;
    }
  }

  loadOrderCalculations() {
    // load calculations
    final cartIds = widget.carts.map((cart) => cart.id).toList();
    context.read<OrderBloc>().add(
      CalculateOrder(
        cartIds: cartIds,
        coupon: appliedCoupon,
        subscriptionFrequency: selectedSubFeq,
        // subscription_frequency:selectedSubFeq
      ),
    );
    // context.read<OrderBloc>().add(CalculateOrder(cartIds: cartIds, coupon: appliedCoupon ,subscription_frequency:selectedSubFeq));
  }

  bool get hasFilteredSlots {
    final now = DateTime.now();
    final bufferTime = now.add(const Duration(hours: 4));
    return timeSchedules.any((schedule) {
      final slotTime = _parseTime(schedule.scheduleTime);
      final scheduleDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, slotTime.hour, slotTime.minute);
      return scheduleDateTime.isBefore(bufferTime);
    });
  }

  // void filterAvailableSchedules() {
  //   final now = DateTime.now();
  //   final bufferTime = now.add(const Duration(hours: 4));
  //
  //   setState(() {
  //     timeSchedules = timeSchedules.where((schedule) {
  //       final slotTime = _parseTime(schedule.scheduleTime);
  //       final scheduleDateTime = DateTime(
  //         selectedDate.year,
  //         selectedDate.month,
  //         selectedDate.day,
  //         slotTime.hour,
  //         slotTime.minute,
  //       );
  //
  //       // Allow all times if selected date is not today
  //       if (!isSameDate(selectedDate, now)) return true;
  //
  //       // Allow only slots after 4 hours from now
  //       return scheduleDateTime.isAfter(bufferTime);
  //     }).toList();
  //   });
  // }
  void filterAvailableSchedules() {
    final now = DateTime.now();
    final bufferTime = now.add(const Duration(hours: 4));

    setState(() {
      timeSchedules =
          timeSchedules.where((schedule) {
            final scheduleDateTime = DateTime.parse(schedule.scheduleTimeRaw).toLocal();

            // Allow all slots if selected date is not today
            if (!isSameDate(selectedDate, now)) return true;

            // Allow only slots at least 4 hours ahead
            return scheduleDateTime.isAfter(bufferTime);
          }).toList();
    });
  }

  // void filterAvailableSchedules() {
  //   final now = DateTime.now();
  //   final bufferTime = now.add(const Duration(hours: 1));
  //
  //   setState(() {
  //     timeSchedules = timeSchedules.where((schedule) {
  //       final scheduleDateTime = DateTime.parse(schedule.scheduleTimeRaw).toLocal();
  //
  //       if (!isSameDate(selectedDate, now)) return true;
  //
  //       return scheduleDateTime.isAfter(bufferTime);
  //     }).toList();
  //   });
  // }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(":");
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  void _processPayment(BuildContext context, OrderCalculation order) async {
    if (currentAddress == null) {
      showSnackBar(context, msg: "Please select address");
      return;
    }
    if (selectedSchedule == null) {
      showSnackBar(context, msg: "Please time schedule");
      return;
    }
    if (selectedPropertyType == null) {
      showSnackBar(context, msg: "Please selected PropertyType");
      return;
    }
    // if (selectedPropertyType == PropertyType.commercial && !_validateCommercialFields()) {
    //   return;
    // }
    if (selectedPropertyType != PropertyType.residential && selectedPropertyType != PropertyType.commercial) {
      showSnackBar(context, msg: "Please select a valid property type");
      return;
    }

    context.read<OrderBloc>().add(
      PlaceOrder(
        cartIds: widget.carts.map((cart) => cart.id).toList(),
        addressId: currentAddress!.id.toString(),
        scheduleTime: selectedSchedule!.primaryId.toString(),
        subscriptionFeq: selectedSubFeq,
        notes: _notesController.text,
        paymentMethod: selectedPaymentMethod,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        beds: beds,
        sofaBeds: sofaBeds,
        occupancy: occupancy,
        petsPresent: petsPresent,
        withLinen: withLinen,
        withSupplies: withSupplies,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        doorAccessCode: doorAccessCode,
        date: selectedDate,
        coupon: appliedCoupon,
        typeOfCleaning: typeOfCleaning,
        nextGuestCheckInTime: nextGuestCheckInTime,
        wifiAccessCode: wifiAccessCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios, color: primaryColor), // or your custom `icon`
        ),
        title: const Text("Order Confirmation", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) async {
          if (state is OrderPlaced) {
            context.read<CartBloc>().add(FetchCartList());
            if (selectedPaymentMethod == PaymentMethod.STRIPE) {
              try {
                await stripe.Stripe.instance.initPaymentSheet(
                  paymentSheetParameters: stripe.SetupPaymentSheetParameters(
                    paymentIntentClientSecret: state.orderResponse.stripePaymentIntent!.clientSecret,
                    merchantDisplayName: "Kleanit",
                  ),
                );

                await stripe.Stripe.instance.presentPaymentSheet();

                // After successful payment, place order
                if (context.mounted) {
                  currentHomeIndexNotifier.value = 1;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Placed Successfully!")));
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeMainView()), (predicate) => false);
                }
              } on stripe.StripeException catch (e) {
                if (context.mounted) {
                  print("stripe.StripeException catch (e)");
                  print("stripe.StripeException catch (e):$e");
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment was cancelled. ")));
                  showPaymentCanceledDialog(context);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Cancelled")));
                showPaymentCanceledDialog(context);
              }
            } else {
              // Handle wallet payment - assuming it's successful immediately
              if (context.mounted) {
                currentHomeIndexNotifier.value = 1;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Placed Successfully using Wallet!")));
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeMainView()), (predicate) => false);
              }
            }
          } else if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ScheduleLoaded) {
            setState(() {
              timeSchedules = state.schedules;
            });
            filterAvailableSchedules(); // 🔥 Filter slots 4 hrs ahead
            loadOrderCalculations();
          }

          // else if (state is ScheduleLoaded)
          // {
          //   loadOrderCalculations();
          //   setState(() {
          //     timeSchedules = state.schedules;
          //   });
          // }
        },
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrderLoaded) {
            return buildOrderDetails(context, state.orderCalculation);
          } else if (state is OrderError) {
            return MyErrorWidget(onRetry: () => loadOrderCalculations(), message: state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget buildOrderDetails(BuildContext context, OrderCalculation order) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildServiceList(order),
              const SizedBox(height: 16),
              buildBookingDetailsCard(),
              const SizedBox(height: 16),
              buildPropertyDetailsCard(),
              const SizedBox(height: 16),
              buildAddressDetailsCard(currentAddress, context, _selectAddress),
              const SizedBox(height: 16),
              buildPaymentMethodCard(order),
              const SizedBox(height: 16),
              buildCouponCodeCard(),
              const SizedBox(height: 16),
              buildPaymentDetailsCard(order),
              const SizedBox(height: 80),
            ],
          ),
        ),
        Positioned(bottom: 0, left: 0, right: 0, child: buildPaymentButton(context, order)),
      ],
    );
  }

  Widget buildBookingDetailsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.event, color: primaryColor),
                ),
                const SizedBox(width: 12),
                const Text("Booking Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.grey.withOpacity(0.3), thickness: 1)),

            // Date Picker Section
            const Text("Select Date:"),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                _selectDate(context);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]!), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, color: primaryColor, size: 18),
                    const SizedBox(width: 8),
                    Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}", style: TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            // const Text("Select Time Schedule:"),
            const Text("Select Time Schedule:"),
            //
            // if (isSameDate(selectedDate, DateTime.now())) ...[
            //   const SizedBox(height: 6),
            //   Text(
            //     "⚠️ You can only book slots at least 4 hours from now.",
            //     style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
            //   ),
            // ],
            if (isSameDate(selectedDate, DateTime.now()) && hasFilteredSlots) ...[
              const SizedBox(height: 6),
              Text("⚠️ You can only book slots at least 4 hours from now.", style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
            ],

            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  timeSchedules.map((schedule) {
                    final isAvailable = schedule.availableSlots > 0 && schedule.available;
                    final isSelected = selectedSchedule?.primaryId == schedule.primaryId;

                    return InkWell(
                      onTap: () {
                        if (isAvailable) {
                          setState(() => selectedSchedule = schedule);
                        } else {
                          showSnackBar(context, msg: "No slots available for this time");
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? primaryColor.withOpacity(0.15)
                                  : isAvailable
                                  ? Colors.white
                                  : Colors.red.withOpacity(0.05),
                          border: Border.all(
                            color:
                                isSelected
                                    ? primaryColor
                                    : isAvailable
                                    ? Colors.grey.shade300
                                    : Colors.red.shade200,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [if (isSelected) BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule, size: 16, color: isAvailable ? primaryColor : Colors.red),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(schedule.scheduleTime, style: TextStyle(fontWeight: FontWeight.w600, color: isAvailable ? Colors.black : Colors.red, fontSize: 10)),
                                Text(
                                  isAvailable ? '${schedule.availableSlots} slot${schedule.availableSlots > 1 ? 's' : ''} available' : 'No slots',
                                  style: TextStyle(fontSize: 8, color: isAvailable ? Colors.grey[600] : Colors.red),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),

            if (isShowSubFeq) ...[
              const SizedBox(height: 10),
              const Text("Select Frequency:"),
              Wrap(
                spacing: 8,
                children:
                    frequencies
                        .map(
                          (feq) => ChoiceChip(
                            label: Text('$feq Months'),
                            selected: selectedSubFeq == feq,
                            onSelected: (selected) {
                              setState(() {
                                selectedSubFeq = feq;
                              });
                              loadOrderCalculations();
                            },
                          ),
                        )
                        .toList(),
              ),
            ],

            const SizedBox(height: 10),
            // Special Instructions Box
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(Icons.edit_note_rounded, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text("Special Instructions", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey[800])),
                        const SizedBox(width: 4),
                        Text("(Optional)", style: TextStyle(fontSize: 13, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Add any special requirements here...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primaryColor, width: 1.5)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      maxLines: 3,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPropertyDetailsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.home_work, color: primaryColor),
                ),
                const SizedBox(width: 12),
                const Text("Property Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.grey.withOpacity(0.3), thickness: 1)),
            // Row(
            //   children: [
            //     Expanded(
            //       child: RadioListTile<PropertyType>(
            //         value: PropertyType.residential,
            //         groupValue: selectedPropertyType,
            //         onChanged: (val) {
            //           setState(() {
            //             selectedPropertyType = val!;
            //           });
            //         },
            //         title: const Text("Residential"),
            //       ),
            //     ),
            //     Expanded(
            //       child: RadioListTile<PropertyType>(
            //         value: PropertyType.commercial,
            //         groupValue: selectedPropertyType,
            //         onChanged: (val) {
            //           setState(() {
            //             selectedPropertyType = val!;
            //           });
            //         },
            //         title: const Text("Commercial"),
            //       ),
            //     ),
            //   ],
            // ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedPropertyType = PropertyType.residential),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: selectedPropertyType == PropertyType.residential ? primaryColor.withOpacity(0.1) : Colors.white,
                        border: Border.all(color: selectedPropertyType == PropertyType.residential ? primaryColor : Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (selectedPropertyType == PropertyType.residential) BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home, color: selectedPropertyType == PropertyType.residential ? primaryColor : Colors.grey, size: 28),
                          const SizedBox(height: 2),
                          Text(
                            "Residential",
                            style: TextStyle(fontWeight: FontWeight.bold, color: selectedPropertyType == PropertyType.residential ? primaryColor : Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedPropertyType = PropertyType.commercial),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: selectedPropertyType == PropertyType.commercial ? primaryColor.withOpacity(0.1) : Colors.white,
                        border: Border.all(color: selectedPropertyType == PropertyType.commercial ? primaryColor : Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (selectedPropertyType == PropertyType.commercial) BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.apartment, color: selectedPropertyType == PropertyType.commercial ? primaryColor : Colors.grey, size: 28),
                          const SizedBox(height: 2),
                          Text("Commercial", style: TextStyle(fontWeight: FontWeight.bold, color: selectedPropertyType == PropertyType.commercial ? primaryColor : Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.grey.withOpacity(0.3), thickness: 1)),
            if (selectedPropertyType == PropertyType.commercial) ...[
              buildNumberPickerRow("Bedrooms", bedrooms, (v) => setState(() => bedrooms = v)),
              // buildNumberPickerRow("Bathrooms", 0, (_) {}), // Add a state field for bathrooms
              buildNumberPickerRow("Bathrooms", bathrooms, (v) => setState(() => bathrooms = v)),

              buildNumberPickerRow("Beds", beds, (v) => setState(() => beds = v)),
              buildNumberPickerRow("Sofa Beds", sofaBeds, (v) => setState(() => sofaBeds = v)),
              // buildTypeOfCleaningDropdown(), // You'll define this
              // buildTimePickerRow("Check-Out Time", checkOutTime, (val) => setState(() => checkOutTime = val)),
              // buildTimePickerRow("Next Guest Check-In", "", (val) {}), // Add state field
              buildNumberPickerRow("Occupancy", occupancy, (v) => setState(() => occupancy = v)),
              // buildTextInput("Door Access Code", doorAccessCode, (val) => setState(() => doorAccessCode = val)),
              // buildTextInput("WiFi Access Code", "", (val) {}), // Add state field
              buildDropdownRow("Type of Cleaning", cleaningOptions, typeOfCleaning, (val) {
                setState(() => typeOfCleaning = val);
              }),
              // buildTimePickerRow("Check-In Time", checkInTime, (time) => setState(() => checkInTime = time)),
              buildTimePickerRow("Check-Out Time", checkOutTime, (time) => setState(() => checkOutTime = time)),

              // buildTimePickerRow("Check-Out Time", checkOutTime, (time) => setState(() => checkOutTime = time)),
              buildTimePickerRow("Next Guest Check-In", nextGuestCheckInTime, (time) => setState(() => nextGuestCheckInTime = time)),

              buildTextInput("Door Access Code", doorAccessCode, (val) => setState(() => doorAccessCode = val)),
              buildTextInput("WiFi Access Code", wifiAccessCode, (val) => setState(() => wifiAccessCode = val)),

              //   TextFormField(
              //   initialValue: doorAccessCode,
              //   onChanged: (val) => setState(() => doorAccessCode = val),
              //   decoration: InputDecoration(
              //     labelText: "Door Access Code",
              //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              //   ),
              // ),
              //   TextFormField(
              //     initialValue: doorAccessCode,
              //     onChanged: (val) => setState(() => doorAccessCode = val),
              //     decoration: InputDecoration(
              //       labelText: "Door Access Code",
              //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              //     ),
              //   ),
            ] else ...[
              buildNumberPickerRow("Bedrooms", bedrooms, (v) => setState(() => bedrooms = v)),
              buildNumberPickerRow("Beds", beds, (v) => setState(() => beds = v)),
              // buildNumberPickerRow("Bathrooms", 0, (_) {}), // Add a state field
              buildNumberPickerRow("Bathrooms", bathrooms, (v) => setState(() => bathrooms = v)),

              buildSwitchRow("Pets Present", petsPresent, (v) => setState(() => petsPresent = v)),
            ],

            // buildNumberPickerRow("Bedrooms", bedrooms, (v) => setState(() => bedrooms = v)),
            // buildNumberPickerRow("Beds", beds, (v) => setState(() => beds = v)),
            // buildNumberPickerRow("Sofa Beds", sofaBeds, (v) => setState(() => sofaBeds = v)),
            // buildNumberPickerRow("Occupancy", occupancy, (v) => setState(() => occupancy = v)),
            // buildSwitchRow("Pets Present", petsPresent, (v) => setState(() => petsPresent = v)),
            // buildSwitchRow("With Linen", withLinen, (v) => setState(() => withLinen = v)),
            // buildSwitchRow("With Supplies", withSupplies, (v) => setState(() => withSupplies = v)),
            // const SizedBox(height: 12),
            // buildTimePickerRow("Check-In Time", checkInTime, (time) => setState(() => checkInTime = time)),
            // buildTimePickerRow("Check-Out Time", checkOutTime, (time) => setState(() => checkOutTime = time)),
            // const SizedBox(height: 12),
            // TextFormField(
            //   initialValue: doorAccessCode,
            //   onChanged: (val) => setState(() => doorAccessCode = val),
            //   decoration: InputDecoration(
            //     labelText: "Door Access Code",
            //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildNumberPickerRow(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  if (value > 0) onChanged(value - 1);
                },
              ),
              Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => onChanged(value + 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSwitchRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Switch(value: value, onChanged: onChanged, activeColor: primaryColor)]),
    );
  }

  Widget buildTimePickerRow(String label, String value, Function(String) onPicked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          InkWell(
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: int.parse(value.split(":")[0]), minute: int.parse(value.split(":")[1])));
              if (time != null) {
                onPicked("${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}");
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAddressDetailsCard(CustomerAddress? address, BuildContext context, VoidCallback onAddressChange) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.home, color: primaryColor),
                    ),
                    const SizedBox(width: 12),
                    const Text("Delivery Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                TextButton(onPressed: onAddressChange, child: Text("Change", style: TextStyle(color: primaryColor))),
              ],
            ),
            if (address != null) ...[
              Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.grey.withOpacity(0.3), thickness: 1)),
              const SizedBox(height: 8),
              Text("${address.buildingName}, ${address.flatNumber}, Floor ${address.floorNumber}"),
              Text("${address.streetName}, ${address.area}"),
              Text("Landmark: ${address.landmark}"),
              Text("Emirate: ${address.emirate}"),
              const SizedBox(height: 6),
              if (address.additionalDirections.isNotEmpty) Text("Directions: ${address.additionalDirections}", style: TextStyle(color: Colors.grey[600])),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildServiceList(OrderCalculation order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.cleaning_services, color: primaryColor),
                ),
                const SizedBox(width: 12),
                const Text("Service Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.grey.withOpacity(0.3), thickness: 1)),
            ...order.items.map((item) => buildServiceCard(item, widget.carts)),
          ],
        ),
      ),
    );
  }

  Widget buildServiceCard(OrderCalculationItem item, List<Cart> carts) {
    // final matchingCart = carts.firstWhere(
    //   (cart) => cart.id == item.cartId,
    //   orElse: () => carts.first,
    // );
    final matchingCart = carts.firstWhere((cart) => cart.thirdCategory.name.trim().toLowerCase() == item.thirdCategoryName.trim().toLowerCase(), orElse: () => carts.first);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child:
                // Image.network(
                //   matchingCart.thirdCategory.image,
                //   width: 60,
                //   height: 60,
                //   fit: BoxFit.cover,
                //   errorBuilder: (context, error, stackTrace) {
                //     return Container(
                //       width: 60,
                //       height: 60,
                //       color: Colors.grey[200],
                //       child: const Icon(Icons.image_not_supported, color: Colors.grey),
                //     );
                //   },
                // ),
                (matchingCart.thirdCategory.image != null && matchingCart.thirdCategory.image.isNotEmpty)
                    ? Image.network(
                      matchingCart.thirdCategory.image!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey));
                      },
                    )
                    : Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
            // ),
          ),
          const SizedBox(width: 16),
          // Text & amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.thirdCategoryName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icon/aed_symbol.png',
                      width: 15,
                      height: 15,
                      fit: BoxFit.contain,
                      // color: primaryColor, // optional: match text color
                    ),
                    const SizedBox(width: 4),
                    Text(item.itemTotal.toStringAsFixed(2), style: TextStyle(fontSize: 15, color: primaryColor, fontWeight: FontWeight.bold)),
                  ],
                ),

                // Text(
                //   "AED ${item.itemTotal.toStringAsFixed(2)}",
                //   style: TextStyle(
                //     fontSize: 15,
                //     color: primaryColor,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getSubscriptionText(Cart cart) {
    if (cart.type != 'subscription' || cart.subscriptionFrequency.isEmpty) {
      return 'One-time service';
    }

    switch (cart.subscriptionFrequency) {
      case '1':
        return 'Weekly (Once a week)';
      case '2':
        return 'Twice a week';
      case '3':
        return 'Three times a week';
      case '4':
        return 'Four times a week';
      case '5':
        return 'Five times a week';
      case '6':
        return 'Six times a week';
      default:
        return 'Custom frequency';
    }
  }

  Widget buildPaymentMethodCard(OrderCalculation order) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.payment, color: primaryColor),
                ),
                const SizedBox(width: 12),
                const Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.grey.withOpacity(0.3), thickness: 1)),
            const SizedBox(height: 8),

            // Payment method selection
            Column(
              children: [
                RadioListTile<String>(
                  title: Row(children: [Icon(Icons.credit_card, color: Colors.blue[700]), const SizedBox(width: 8), const Text("Card (Debit/Credit)")]),
                  value: PaymentMethod.STRIPE,
                  groupValue: selectedPaymentMethod,
                  onChanged: (String? value) {
                    setState(() {
                      selectedPaymentMethod = value!;
                    });
                  },
                  activeColor: primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
                // RadioListTile<String>(
                //   title: Column(
                //     children: [
                //       Row(
                //         children: [
                //           Icon(Icons.account_balance_wallet, color: Colors.green[700]),
                //           const SizedBox(width: 8),
                //           const Text("Wallet"),
                //           // const Text("Wallet {$walletCoin}"),/
                //
                //
                //         ],
                //       ),
                //       Row(
                //         children: [
                //           Text(
                //             "Available wallet coin :${order.walletAmount.toStringAsFixed(0)} ",
                //             style: TextStyle(
                //               color: Colors.green[700],
                //               fontWeight: FontWeight.w600,
                //               fontSize: 13,
                //             ),
                //           ),
                //         ],
                //       ),
                //       Row(
                //         children: [
                //           Text(
                //             "Required Coin : ${order.requiredAmount.toStringAsFixed(0)} ",
                //             style: TextStyle(
                //               color: Colors.green[700],
                //               fontWeight: FontWeight.w600,
                //               fontSize: 13,
                //             ),
                //           ),
                //         ],
                //       ),
                //
                //     ],
                //   ),
                //   value: PaymentMethod.WALLET,
                //   groupValue: selectedPaymentMethod,
                //   onChanged: (String? value) {
                //     setState(() {
                //       selectedPaymentMethod = value!;
                //     });
                //   },
                //   activeColor: primaryColor,
                //   contentPadding: EdgeInsets.zero,
                // ),
                RadioListTile<String>(
                  value: PaymentMethod.WALLET,
                  groupValue: selectedPaymentMethod,
                  onChanged: (String? value) {
                    setState(() {
                      selectedPaymentMethod = value!;
                    });

                    if (value == PaymentMethod.WALLET && order.walletAmount < order.requiredAmount) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: const Text("You don't have enough wallet coins to place this order."), backgroundColor: Colors.red[400]));
                    }
                  },
                  activeColor: primaryColor,
                  contentPadding: EdgeInsets.zero,
                  title: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.account_balance_wallet, color: Colors.green[700]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Wallet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.monetization_on, size: 16, color: Colors.green[700]),
                                    const SizedBox(width: 2),
                                    Text(
                                      "Available: Coin ${order.walletAmount.toStringAsFixed(2)}",
                                      style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w500, fontSize: 10),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.request_quote, size: 16, color: Colors.orange[800]),
                                    const SizedBox(width: 2),
                                    Text(
                                      "Required: Coin ${order.requiredAmount.toStringAsFixed(2)}",
                                      style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.w500, fontSize: 10),
                                    ),
                                  ],
                                ),
                                if (selectedPaymentMethod == PaymentMethod.WALLET && order.walletAmount < order.requiredAmount)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red[700]),
                                        const SizedBox(width: 2),
                                        Text("Not enough coin wallet balance", style: TextStyle(fontSize: 10, color: Colors.red[700], fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCouponCodeCard() {
    return BlocConsumer<CouponBloc, CouponState>(
      listener: (context, state) {
        if (state is CouponValidationSuccess) {
          setState(() {
            appliedCoupon = state.couponCode;
            loadOrderCalculations();
          });
        } else if (state is CouponValidationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (ctx, state) {
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.discount, color: primaryColor),
                    ),
                    const SizedBox(width: 12),
                    const Text("Coupon Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.grey.withOpacity(0.3), thickness: 1)),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _couponController,
                        decoration: InputDecoration(
                          hintText: "Enter coupon code",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_couponController.text.trim().isNotEmpty) {
                          context.read<CouponBloc>().add(ValidateCoupon(couponCode: _couponController.text.trim()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Apply"),
                    ),
                  ],
                ),
                if (state is! CouponInitial) ...[
                  const SizedBox(height: 10),
                  Text(() {
                    if (state is CouponValidationLoading) {
                      return "Applying coupon...";
                    } else if (state is CouponValidationSuccess) {
                      return "Coupon '$appliedCoupon' applied";
                    } else if (state is CouponValidationFailure) {
                      return state.error;
                    } else {
                      return "";
                    }
                  }(), style: TextStyle(color: (state is CouponValidationFailure) ? Colors.red[700] : Colors.green[700], fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPaymentDetailsCard(OrderCalculation order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.receipt_long, color: primaryColor),
                ),
                const SizedBox(width: 12),
                const Text("Payment Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),

            Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.grey.withOpacity(0.3), thickness: 1)),

            // Service items
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(item.thirdCategoryName, style: TextStyle(fontSize: 15, color: Colors.grey[700]), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    // Text(
                    //   "AED ${item.itemTotal.toStringAsFixed(2)}",
                    //   style: const TextStyle(
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/icon/aed_symbol.png', width: 15, height: 15, fit: BoxFit.contain),
                        const SizedBox(width: 4),
                        Text(item.itemTotal.toStringAsFixed(2), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  // Subtotal
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       "Subtotal",
                  //       style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  //     ),
                  //     Text(
                  //       "AED ${order.subtotal.toStringAsFixed(2)}",
                  //       style: const TextStyle(fontSize: 15),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subtotal", style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/icon/aed_symbol.png', width: 14, height: 14, fit: BoxFit.contain),
                          const SizedBox(width: 4),
                          Text(order.subtotal.toStringAsFixed(2), style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Tax
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tax (VAT) (${order.items.isNotEmpty ? (order.taxAmount / order.subtotal * 100).toStringAsFixed(1) : 0}%)",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/icon/aed_symbol.png', width: 14, height: 14, fit: BoxFit.contain),
                          const SizedBox(width: 4),
                          Text("AED ${order.taxAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                  if (order.couponDiscount != 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Discount (Coupon)", style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                        Text("AED -${order.couponDiscount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15, color: Colors.green)),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Total
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icon/aed_symbol.png',
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                        // color: primaryColor, // Optional: tint to match text
                      ),
                      const SizedBox(width: 4),
                      Text(" ${order.grandTotal.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                ],
              ),
            ),

            // Wallet coins message if available
            if (widget.carts.isNotEmpty && widget.carts.first.thirdCategory.walletCoins.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.amber.shade50, Colors.amber.shade100.withOpacity(0.3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                  boxShadow: [BoxShadow(color: Colors.amber.shade100.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
                      child: Icon(Icons.wallet_giftcard, color: Colors.amber[700], size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Reward Points", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800])),
                          const SizedBox(height: 2),
                          Text("You'll earn ${order.walletCoin} wallet coins with this purchase!", style: TextStyle(color: Colors.amber[800], fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildPaymentButton(BuildContext context, OrderCalculation order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            if (!formIsValid) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("❗ Please fill all required commercial property details.", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white54),
              );
            }
          },
          child: AbsorbPointer(
            // Prevents interaction if form is invalid
            absorbing: !formIsValid,
            child: ElevatedButton(
              onPressed: formIsValid ? () => _processPayment(context, order) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Pay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icon/aed_symbol.png',
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                        // color: Colors.transparent,
                      ),
                      const SizedBox(width: 4),
                      Text(" ${order.grandTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showPaymentCanceledDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top circle with icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(color: Colors.red[100], shape: BoxShape.circle),
                      child: Icon(Icons.close_rounded, color: Colors.red, size: 38),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text("Payment Canceled", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),

                const SizedBox(height: 12),

                // Description
                Text(
                  "Your payment process has been canceled. Would you like to explore other services that might interest you?",
                  style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate to services page
                          currentHomeIndexNotifier.value = 0;
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeMainView()), (predicate) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text("Explore More", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void setDefaultAddress() {
    context.read<AddressBloc>().add(FetchAddresses());

    context.read<AddressBloc>().stream.listen((state) {
      if (state is AddressLoaded) {
        final addressList = state.addresses;

        if (addressList.isNotEmpty) {
          currentAddress = addressList.firstWhere((a) => a.isDefault == 1, orElse: () => addressList.first);
        } else {
          currentAddress = null;
        }
      }
    });
  }

  void _selectAddress() async {
    // Go to address screen
    var address = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddressListScreen(isSelectionMode: true)));
    if (address != null) {
      setState(() {
        currentAddress = address;
      });
    }
  }

  // Date picker function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: primaryColor, onPrimary: Colors.white, onSurface: Colors.black)), child: child!);
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        context.read<OrderBloc>().add(FetchSchedules(date: selectedDate));
      });
    }
  }

  Widget buildTextInput(String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }

  Widget buildDropdownRow(String label, List<String> options, String selected, void Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selected,
        onChanged: (String? val) {
          if (val != null) onChanged(val);
        },
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }

  bool get formIsValid {
    if (selectedPropertyType == PropertyType.commercial) {
      return _validateCommercialFields();
    } else if (selectedPropertyType == PropertyType.residential) {
      return _validateResidentialFields();
    }
    return false;
  }

  bool _validateCommercialFields() {
    return bedrooms > 0 &&
        bathrooms > 0 &&
        beds > 0 &&
        sofaBeds >= 0 &&
        occupancy > 0 &&
        checkInTime.isNotEmpty &&
        checkOutTime.isNotEmpty &&
        typeOfCleaning.isNotEmpty &&
        nextGuestCheckInTime.isNotEmpty &&
        doorAccessCode.isNotEmpty &&
        wifiAccessCode.isNotEmpty;
  }

  bool _validateResidentialFields() {
    return bathrooms > 0;
    // occupancy > 0; // Only this is mandatory
  }
}
