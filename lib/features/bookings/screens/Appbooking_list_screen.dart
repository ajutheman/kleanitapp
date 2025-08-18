import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kleanitapp/features/bookings/model/TimeSlotOption.dart';
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

  // One-date-per-week (legacy)
  final Map<int, DateTime> _pickedDates = {};
  final Map<int, int> _pickedTimeId = {};
  final Map<int, String> _pickedTimeLabel = {};

  // Multi-date selections & time per Y-M-D
  final Map<int, Set<DateTime>> _pickedDatesByWeek = {};
  final Map<String, int> _timeIdByYmd = {};
  final Map<String, String> _timeLabelByYmd = {};

  @override
  void initState() {
    super.initState();
    _repo = context.read<BookingBloc>().repository;
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
          return const Center(child: AppBookingListShimmer());
        } else if (state is BookingError) {
          return Center(child: Text(state.message));
        } else if (state is BookingLoaded) {
          final bookings = state.bookings;
          if (bookings.isEmpty) return _buildEmptyState(context);
          return ListView.builder(padding: const EdgeInsets.all(20), itemCount: bookings.length, itemBuilder: (context, index) => buildBookingCard(context, bookings[index]));
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
            Expanded(child: Text("Booked For: ${booking.bookingDate}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor))),
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
        Expanded(child: Text(booking.schedule, style: TextStyle(color: Colors.grey[600], fontSize: 14))),
      ],
    );
  }

  Widget _buildItemsSummary(AppBookingModel booking) {
    if (booking.items.isEmpty) return const SizedBox.shrink();
    final itemCount = booking.items.length;
    final summary = itemCount == 1 ? booking.items[0].thirdCategoryName : "${booking.items[0].thirdCategoryName} +${itemCount - 1} more";
    return Text(summary, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  Widget _buildFooterRow(AppBookingModel booking) {
    final showSelectDates = _hasAnyUnbooked(booking);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
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
            _buildStatusChip(booking.orderStatus),
          ],
        ),
        if (showSelectDates) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showSubscriptionDateSheet(context, booking),
                icon: const Icon(Icons.event_note, size: 16, color: Colors.white),
                label: const Text("Select dates", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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

  String _ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  int? _selectedTimeIdFor(DateTime d) => _timeIdByYmd[_ymd(d)];

  String? _selectedTimeLabelFor(DateTime d) => _timeLabelByYmd[_ymd(d)];

  void _setTimeFor(DateTime d, int id, String label) {
    final key = _ymd(d);
    _timeIdByYmd[key] = id;
    _timeLabelByYmd[key] = label;
  }

  int _countSelectedInMonth(AppBookingModel booking, String yyyyMM) {
    int count = 0;
    for (final w in booking.weeklySchedules) {
      final set = _pickedDatesByWeek[w.weekNumber];
      if (set == null) continue;
      for (final d in set) {
        final m = DateFormat('yyyy-MM').format(d);
        if (m == yyyyMM) count++;
      }
    }
    return count;
  }

  void _showSubscriptionDateSheet(BuildContext context, AppBookingModel booking) {
    //  // CLear data
    //  _pickedDatesByWeek.clear();
    // _timeIdByYmd .clear();
    // _timeLabelByYmd.clear();

    bool saving = false;

    // Subscription rules
    final firstItem = booking.items.isNotEmpty ? booking.items.first : null;
    final mode = (firstItem?.subscriptionMode ?? '').toLowerCase(); // "weekly" | "monthly" | ""
    final timesPerWeek = (firstItem?.timesPerWeek ?? 0) > 0 ? firstItem!.timesPerWeek! : 1;
    final timesPerMonth = (firstItem?.timesPerMonth ?? 0) > 0 ? firstItem!.timesPerMonth! : 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        final weeks = booking.weeklySchedules;

        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child:
                weeks.isEmpty
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
                                  Expanded(
                                    child: Text(
                                      mode == 'monthly' ? "Pick up to $timesPerMonth dates per month" : "Pick up to $timesPerWeek date(s) each week",
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  TextButton(onPressed: saving ? null : () => Navigator.pop(context), child: const Text("Close")),
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

                                  // Build week dates from API map keys
                                  final List<DateTime> weekDates = w.days.keys.map((k) => _tryParseYmd(k)).whereType<DateTime>().toList()..sort();

                                  // Selected set for this week
                                  final selectedSet = _pickedDatesByWeek[w.weekNumber] ??= <DateTime>{};

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                      border: Border.all(color: booked ? Colors.green.shade100 : Colors.red.shade100),
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
                                                "${start != null ? DateFormat('d MMM').format(start) : '--'} – "
                                                "${end != null ? DateFormat('d MMM').format(end) : '--'}",
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: booked ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (booked) Icon(Icons.check_circle, size: 14, color: booked ? Colors.red : Colors.green),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    booked ? "Booked" : "Available",
                                                    style: TextStyle(color: booked ? Colors.red : Colors.green, fontWeight: FontWeight.w600, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // Date chips for the week
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            for (final d in weekDates)
                                              FilterChip(
                                                label: Text(DateFormat('EEE d').format(d)),
                                                selected: selectedSet.contains(d),
                                                onSelected: (val) {
                                                  if (booked || saving) return;
                                                  if (val) {
                                                    // enforce rules
                                                    if (mode == 'monthly') {
                                                      final monthKey = DateFormat('yyyy-MM').format(d);
                                                      final monthCount = _countSelectedInMonth(booking, monthKey);
                                                      if (monthCount >= timesPerMonth) {
                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Max $timesPerMonth selections in $monthKey")));
                                                        return;
                                                      }
                                                    } else {
                                                      if (selectedSet.length >= timesPerWeek) {
                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Max $timesPerWeek selection(s) this week")));
                                                        return;
                                                      }
                                                    }
                                                    setSheetState(() {
                                                      selectedSet.add(d);
                                                    });
                                                  } else {
                                                    setSheetState(() {
                                                      selectedSet.remove(d);
                                                      // clear any time picked for this date
                                                      final key = _ymd(d);
                                                      _timeIdByYmd.remove(key);
                                                      _timeLabelByYmd.remove(key);
                                                    });
                                                  }
                                                },
                                              ),
                                          ],
                                        ),

                                        // For each selected date, render time slots + chosen label
                                        if (selectedSet.isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          ...(() {
                                            final list = selectedSet.toList()..sort();
                                            return list.map((d) {
                                              final tId = _selectedTimeIdFor(d);
                                              final tLabel = _selectedTimeLabelFor(d);
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(DateFormat('EEE, d MMM y').format(d), style: const TextStyle(fontWeight: FontWeight.w700)),
                                                    _TimeSlotsForDate(
                                                      repo: _repo,
                                                      orderId: booking.id,
                                                      weekNumber: w.weekNumber,
                                                      date: d,
                                                      selectedTimeId: tId,
                                                      onPick:
                                                          (timeId) => setSheetState(() {
                                                            _setTimeFor(d, timeId, tLabel ?? '');
                                                          }),
                                                      onLabel:
                                                          (label) => setSheetState(() {
                                                            final id = _selectedTimeIdFor(d);
                                                            if (id != null) _setTimeFor(d, id, label);
                                                          }),
                                                    ),
                                                    if (tId != null && (tLabel ?? '').isNotEmpty)
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 6),
                                                        child: Text("Chosen: $tLabel", style: const TextStyle(fontWeight: FontWeight.w600)),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            }).toList();
                                          })(),
                                        ],
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    backgroundColor: primaryColor,
                                                    foregroundColor: Colors.white,
                                                  ),
                                                  onPressed: saving ? null : () => _saveSelections(w.id,booking, selectedSet, start!, end!),
                                                  icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                                                  label: Text(saving ? "Saving..." : "Save selections"),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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

  void _saveSelections(int scheduleId,AppBookingModel booking, Set<DateTime> selectedSet, DateTime start, DateTime end) async {
    final payload = _buildSelectionPayload(selectedSet, _timeIdByYmd);
    final formatter = DateFormat('yyyy-MM-dd');
    // setSheetState(() => saving = true);
    try {
     await _repo.updateWeeklySchedule(scheduleId: scheduleId,orderId: booking.id, startDate: formatter.format(start), endDate:formatter.format( end), days: payload);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Updated")));
      }
    } catch (e) {
      // setSheetState(() => saving = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save: $e")));
      }
    }
  }

  List<Map<String, dynamic>> _buildSelectionPayload(Set<DateTime> selectedSet, Map<String, int> timeIdByYmd) {
    // Sort for stable order in the payload (optional)
    final sortedDays = selectedSet.toList()..sort();

    final payload = <Map<String, dynamic>>[];

    for (final day in sortedDays) {
      final key = _ymd(day);
      final timeId = timeIdByYmd[key];

      // Only add if there is a matching time id for the selected date.
      // This naturally ignores any "extra" time entries not in selectedSet.
      if (timeId != null) {
        payload.add({'date': key, 'time_schedule_id': timeId});
      } else {
        // If you want to see mismatches during dev:
        // debugPrint('No time_schedule_id for selected date: $key');
      }
    }

    return payload;
  }
}

// ---- helper widget (unchanged) ----
class _TimeSlotsForDate extends StatelessWidget {
  final AppBookingRepository repo;
  final String orderId;
  final int weekNumber;
  final DateTime date;
  final int? selectedTimeId;
  final ValueChanged<int> onPick;
  final ValueChanged<String> onLabel;

  const _TimeSlotsForDate({
    required this.repo,
    required this.orderId,
    required this.weekNumber,
    required this.date,
    required this.selectedTimeId,
    required this.onPick,
    required this.onLabel,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TimeSlotOption>>(
      future: repo.fetchTimeSlotsForDate(date, orderId: orderId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.only(top: 8.0), child: LinearProgressIndicator(minHeight: 2));
        }
        if (snap.hasError) {
          return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text("Failed to load time slots", style: TextStyle(color: Colors.red[700])));
        }
        final slots = snap.data ?? const [];
        if (slots.isEmpty) {
          return const Padding(padding: EdgeInsets.only(top: 8.0), child: Text("No time slots on this date."));
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
                  onSelected:
                      s.available
                          ? (val) {
                            if (val && s.ids.isNotEmpty) {
                              onPick(s.ids.first);
                              onLabel(s.scheduleTime);
                            }
                          }
                          : null,
                  disabledColor: Colors.grey.shade200,
                  labelStyle: TextStyle(color: s.available ? null : Colors.grey, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        );
      },
    );
  }
}

// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:intl/intl.dart';
// // import 'package:kleanitapp/features/bookings/model/TimeSlotOption.dart';
// // import 'package:kleanitapp/features/bookings/repo/Appbooking_repository.dart';
// // import 'package:kleanitapp/features/bookings/screens/Appbooking_detail.dart';
// // import 'package:kleanitapp/features/bookings/screens/widgets/Appbooking_list_shimmer.dart';
// // import 'package:kleanitapp/features/home/Apphome_main.dart';

// // import '../../../core/theme/sypd_color.dart';
// // import '../bloc/booking_bloc.dart';
// // import '../bloc/booking_event.dart';
// // import '../bloc/booking_state.dart';
// // import '../model/Appbooking.dart';

// // class AppBookingList extends StatefulWidget {
// //   final String filterTag;

// //   const AppBookingList({Key? key, this.filterTag = "All"}) : super(key: key);

// //   @override
// //   State<AppBookingList> createState() => _AppBookingListState();
// // }

// // class _AppBookingListState extends State<AppBookingList> {
// //   int currentPage = 1;
// //   late AppBookingRepository _repo;
// //    // selections per week
// //   final Map<int, DateTime> _pickedDates = {};   // weekNumber -> date
// //   final Map<int, int> _pickedTimeId = {};       // weekNumber -> time id
// //   final Map<int, String> _pickedTimeLabel = {}; // weekNumber -> "08:00 AM"

// //   @override
// //   void initState() {
// //     super.initState();
// //     _repo = context.read<AppBookingRepository>(); // use the provided instance

// //     _loadBookings();
// //   }

// //   void _loadBookings() {
// //     final Map<String, String> statusMap = {
// //       "All": "",
// //       "Pending": "pending",
// //       "Confirmed": "confirmed",
// //       "In Progress": "in_progress",
// //       "Completed": "completed",
// //       "Cancelled": "cancelled",
// //     };

// //     context.read<BookingBloc>().add(FetchBookings(page: currentPage, status: statusMap[widget.filterTag] ?? ""));
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return BlocBuilder<BookingBloc, BookingState>(
// //       builder: (context, state) {
// //         if (state is BookingLoading) {
// //           return const Center(
// //             child: AppBookingListShimmer(),
// //             // CircularProgressIndicator()
// //           );
// //         } else if (state is BookingError) {
// //           return Center(child: Text(state.message));
// //         } else if (state is BookingLoaded) {
// //           final bookings = state.bookings;

// //           if (bookings.isEmpty) {
// //             return _buildEmptyState(context);
// //           }

// //           return ListView.builder(
// //             padding: const EdgeInsets.all(20),
// //             itemCount: bookings.length,
// //             itemBuilder: (context, index) {
// //               return buildBookingCard(context, bookings[index]);
// //             },
// //           );
// //         }

// //         return _buildEmptyState(context);
// //       },
// //     );
// //   }

// //   Widget buildBookingCard(BuildContext context, AppBookingModel booking) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(20),
// //         boxShadow: [
// //           BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8)),
// //           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
// //         ],
// //       ),
// //       child: InkWell(
// //         borderRadius: BorderRadius.circular(20),
// //         onTap: () {
// //           Navigator.push(context, MaterialPageRoute(builder: (_) => AppBookingDetail(bookingId: booking.id)));
// //         },
// //         child: Padding(
// //           padding: const EdgeInsets.all(15),
// //           child: Row(
// //             children: [
// //               // _buildBookingImage(booking),
// //               // const SizedBox(width: 15),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     _buildHeaderRow(booking),
// //                     const SizedBox(height: 8),
// //                     _buildDateInfo(booking),
// //                     const SizedBox(height: 8),
// //                     _buildScheduleInfo(booking),
// //                     const SizedBox(height: 8),
// //                     _buildItemsSummary(booking),
// //                     const SizedBox(height: 8),
// //                     _buildFooterRow(booking),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildHeaderRow(AppBookingModel booking) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Expanded(
// //           child: Text(
// //             'Booked ${booking.items.first.thirdCategoryName} ${booking.items.length <= 1 ? '' : '+${booking.items.length - 1}'}',
// //             maxLines: 1,
// //             overflow: TextOverflow.ellipsis,
// //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //           ),
// //         ),
// //         const SizedBox(width: 10),
// //         // Text(
// //         //   "AED ${booking.total.toStringAsFixed(2)}",
// //         //   style: TextStyle(
// //         //     fontSize: 16,
// //         //     fontWeight: FontWeight.bold,
// //         //     color: primaryColor,
// //         //   ),
// //         // ),
// //         Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Image.asset("assets/icon/aed_symbol.png", width: 16, height: 16, fit: BoxFit.contain),
// //             const SizedBox(width: 4),
// //             Text(booking.total.toStringAsFixed(2), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
// //           ],
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildDateInfo(AppBookingModel booking) {
// //     return Column(
// //       children: [
// //         Row(
// //           children: [
// //             Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
// //             const SizedBox(width: 4),
// //             Expanded(child: Text(DateFormat("d MMMM, y").format(booking.createdAt.toLocal()), style: TextStyle(color: Colors.grey[600], fontSize: 14))),
// //           ],
// //         ),
// //         Row(
// //           children: [
// //             Icon(Icons.calendar_today, size: 16, color: primaryColor),
// //             const SizedBox(width: 4),
// //             Expanded(
// //               child:
// //               // Text(
// //               //   DateFormat("d MMMM, y").format(booking.bookingDate.toLocal()),
// //               //   style: TextStyle(color: Colors.grey[600], fontSize: 14),
// //               // ),
// //               Text(" Booked For: ${booking.bookingDate}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildScheduleInfo(AppBookingModel booking) {
// //     return Row(
// //       children: [
// //         Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
// //         const SizedBox(width: 4),
// //         Expanded(
// //           child: Text(
// //             "${booking.schedule.toString()}",
// //             // _formatScheduleTimeToLocal(booking),
// //             style: TextStyle(color: Colors.grey[600], fontSize: 14),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildItemsSummary(AppBookingModel booking) {
// //     if (booking.items.isEmpty) {
// //       return const SizedBox.shrink();
// //     }

// //     final itemCount = booking.items.length;
// //     String summaryText;

// //     if (itemCount == 1) {
// //       summaryText = booking.items[0].thirdCategoryName;
// //     } else {
// //       summaryText = "${booking.items[0].thirdCategoryName} +${itemCount - 1} more";
// //     }

// //     return Text(summaryText, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis);
// //   }

// //   // Widget _buildFooterRow(AppBookingModel booking) {
// //   //   return Row(
// //   //     children: [
// //   //       // if (booking.hasSubscription)
// //   //       Container(
// //   //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //   //         decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
// //   //         child: Row(
// //   //           mainAxisSize: MainAxisSize.min,
// //   //           children: [
// //   //             Icon(Icons.repeat, size: 14, color: Colors.blue[600]),
// //   //             const SizedBox(width: 4),
// //   //             Text(booking.hasSubscription ? "Subscription" : 'Single', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue[600])),
// //   //           ],
// //   //         ),
// //   //       ),
// //   //       const Spacer(),
// //   //       // _buildPaymentStatusChip(booking.paymentStatus),
// //   //       // const SizedBox(width: 8),
// //   //       _buildStatusChip(booking.orderStatus),
// //   //     ],
// //   //   );
// //   // }
// //   Widget _buildFooterRow(AppBookingModel booking) {
// //     final showSelectDates = _hasAnyUnbooked(booking);

// //     return Row(
// //       children: [
// //         Container(
// //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //           decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
// //           child: Row(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Icon(Icons.repeat, size: 14, color: Colors.blue[600]),
// //               const SizedBox(width: 4),
// //               Text(
// //                 booking.hasSubscription ? "Subscription" : 'Single',
// //                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue[600]),
// //               ),
// //             ],
// //           ),
// //         ),
// //         const Spacer(),
// //         if (showSelectDates) ...[
// //           TextButton.icon(
// //             style: TextButton.styleFrom(
// //               foregroundColor: Colors.white,
// //               backgroundColor: Colors.red.shade600,
// //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //             ),
// //             onPressed: () => _showSubscriptionDateSheet(context, booking),
// //             icon: const Icon(Icons.event_note, size: 16, color: Colors.white),
// //             label: const Text("Select dates", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
// //           ),
// //           const SizedBox(width: 8),
// //         ],
// //         _buildStatusChip(booking.orderStatus),
// //       ],
// //     );
// //   }
// //    DateTime? _tryParseYmd(String s) {
// //     try {
// //       return DateTime.parse(s);
// //     } catch (_) {
// //       return null;
// //     }
// //   }
// // void _showSubscriptionDateSheet(BuildContext context, AppBookingModel booking) {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
// //       ),
// //       builder: (_) {
// //         final weeks = booking.weeklySchedules;

// //         return SafeArea(
// //           child: SizedBox(
// //             height: MediaQuery.of(context).size.height * 0.8,
// //             child: weeks.isEmpty
// //                 ? const Center(child: Text("No subscription weeks available."))
// //                 : StatefulBuilder(
// //                     builder: (context, setSheetState) {
// //                       return Column(
// //                         children: [
// //                           // Header
// //                           Padding(
// //                             padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
// //                             child: Row(
// //                               children: [
// //                                 const Expanded(
// //                                   child: Text(
// //                                     "Select dates & times",
// //                                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
// //                                   ),
// //                                 ),
// //                                 TextButton(
// //                                   onPressed: () => Navigator.pop(context),
// //                                   child: const Text("Close"),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                           const Divider(height: 1),

// //                           // Weeks list
// //                           Expanded(
// //                             child: ListView.separated(
// //                               padding: const EdgeInsets.all(16),
// //                               itemCount: weeks.length,
// //                               separatorBuilder: (_, __) => const SizedBox(height: 12),
// //                               itemBuilder: (context, i) {
// //                                 final w = weeks[i];
// //                                 final start = _tryParseYmd(w.startDate);
// //                                 final end = _tryParseYmd(w.endDate) ?? start;
// //                                 final booked = w.isBooked;
// //                                 final selectedDate = _pickedDates[w.weekNumber];
// //                                 final selectedTimeId = _pickedTimeId[w.weekNumber];
// //                                 final selectedTimeLabel = _pickedTimeLabel[w.weekNumber];

// //                                 return Container(
// //                                   decoration: BoxDecoration(
// //                                     color: Colors.white,
// //                                     borderRadius: BorderRadius.circular(12),
// //                                     boxShadow: [
// //                                       BoxShadow(
// //                                         color: Colors.black.withOpacity(0.05),
// //                                         blurRadius: 10,
// //                                         offset: const Offset(0, 4),
// //                                       ),
// //                                     ],
// //                                     border: Border.all(
// //                                       color: booked ? Colors.green.shade100 : Colors.red.shade100,
// //                                     ),
// //                                   ),
// //                                   padding: const EdgeInsets.all(12),
// //                                   child: Column(
// //                                     crossAxisAlignment: CrossAxisAlignment.start,
// //                                     children: [
// //                                       // Week header
// //                                       Row(
// //                                         children: [
// //                                           Expanded(
// //                                             child: Text(
// //                                               "Week ${w.weekNumber}: "
// //                                               "${start != null ? DateFormat('d MMM').format(start) : '--'}"
// //                                               " – "
// //                                               "${end != null ? DateFormat('d MMM').format(end) : '--'}",
// //                                               style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
// //                                             ),
// //                                           ),
// //                                           Container(
// //                                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                                             decoration: BoxDecoration(
// //                                               color: booked ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
// //                                               borderRadius: BorderRadius.circular(8),
// //                                             ),
// //                                             child: Row(
// //                                               mainAxisSize: MainAxisSize.min,
// //                                               children: [
// //                                                 Icon(
// //                                                   booked ? Icons.check_circle : Icons.error_outline,
// //                                                   size: 14,
// //                                                   color: booked ? Colors.green : Colors.red,
// //                                                 ),
// //                                                 const SizedBox(width: 4),
// //                                                 Text(
// //                                                   booked ? "Booked" : "Not booked",
// //                                                   style: TextStyle(
// //                                                     color: booked ? Colors.green : Colors.red,
// //                                                     fontWeight: FontWeight.w600,
// //                                                     fontSize: 12,
// //                                                   ),
// //                                                 ),
// //                                               ],
// //                                             ),
// //                                           ),
// //                                         ],
// //                                       ),

// //                                       const SizedBox(height: 10),

// //                                       // Date selector
// //                                       Row(
// //                                         children: [
// //                                           Expanded(
// //                                             child: Text(
// //                                               selectedDate != null
// //                                                   ? "Selected: ${DateFormat('EEE, d MMM y').format(selectedDate)}"
// //                                                   : "Pick a date within this week",
// //                                               style: TextStyle(
// //                                                 fontSize: 14,
// //                                                 color: selectedDate != null ? Colors.black : Colors.grey[700],
// //                                               ),
// //                                             ),
// //                                           ),
// //                                           const SizedBox(width: 8),
// //                                           TextButton.icon(
// //                                             style: TextButton.styleFrom(
// //                                               foregroundColor: Colors.white,
// //                                               backgroundColor: booked ? Colors.grey : Colors.red.shade600,
// //                                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //                                             ),
// //                                             onPressed: booked || start == null || end == null
// //                                                 ? null
// //                                                 : () async {
// //                                                     final picked = await showDatePicker(
// //                                                       context: context,
// //                                                       initialDate: selectedDate ?? start,
// //                                                       firstDate: start,
// //                                                       lastDate: end,
// //                                                     );
// //                                                     if (picked != null) {
// //                                                       setSheetState(() {
// //                                                         _pickedDates[w.weekNumber] = picked;
// //                                                         _pickedTimeId.remove(w.weekNumber);
// //                                                         _pickedTimeLabel.remove(w.weekNumber);
// //                                                       });
// //                                                     }
// //                                                   },
// //                                             icon: const Icon(Icons.event_available, size: 18, color: Colors.white),
// //                                             label: const Text("Select date", style: TextStyle(color: Colors.white)),
// //                                           ),
// //                                         ],
// //                                       ),

// //                                       // Time slots (appear after date picked)
// //                                       if (selectedDate != null)
// //                                         _TimeSlotsForDate(
// //                                           repo: _repo,
// //                                           weekNumber: w.weekNumber,
// //                                           date: selectedDate,
// //                                           selectedTimeId: selectedTimeId,
// //                                           onPick: (timeId) => setSheetState(() => _pickedTimeId[w.weekNumber] = timeId),
// //                                           onLabel: (label) => setSheetState(() => _pickedTimeLabel[w.weekNumber] = label),
// //                                         ),

// //                                       if (selectedDate != null && selectedTimeId != null) ...[
// //                                         const SizedBox(height: 8),
// //                                         Text(
// //                                           "Chosen: ${DateFormat('d MMM y').format(selectedDate)} at ${selectedTimeLabel ?? ''}",
// //                                           style: const TextStyle(fontWeight: FontWeight.w600),
// //                                         ),
// //                                       ],
// //                                     ],
// //                                   ),
// //                                 );
// //                               },
// //                             ),
// //                           ),

// //                           // Bottom action
// //                           Padding(
// //                             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
// //                             child: Row(
// //                               children: [
// //                                 Expanded(
// //                                   child: ElevatedButton.icon(
// //                                     onPressed: () {
// //                                       // TODO: wire to backend save call
// //                                       Navigator.pop(context);
// //                                       ScaffoldMessenger.of(context).showSnackBar(
// //                                         const SnackBar(content: Text("Selections stored locally (wire to API next).")),
// //                                       );
// //                                     },
// //                                     icon: const Icon(Icons.save),
// //                                     label: const Text("Save selections"),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                       );
// //                     },
// //                   ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // // --- helper widget that loads time slots for a picked date
// // class _TimeSlotsForDate extends StatelessWidget {
// //   final AppBookingRepository repo;
// //   final int weekNumber;
// //   final DateTime date;
// //   final int? selectedTimeId;
// //   final ValueChanged<int> onPick;     // chosen timeId
// //   final ValueChanged<String> onLabel; // chosen label

// //   const _TimeSlotsForDate({
// //     required this.repo,
// //     required this.weekNumber,
// //     required this.date,
// //     required this.selectedTimeId,
// //     required this.onPick,
// //     required this.onLabel,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return FutureBuilder<List<TimeSlotOption>>(
// //       future: repo.fetchTimeSlotsForDate(date),
// //       builder: (context, snap) {
// //         if (snap.connectionState == ConnectionState.waiting) {
// //           return const Padding(
// //             padding: EdgeInsets.only(top: 8.0),
// //             child: LinearProgressIndicator(minHeight: 2),
// //           );
// //         }
// //         if (snap.hasError) {
// //           return Padding(
// //             padding: const EdgeInsets.only(top: 8.0),
// //             child: Text("Failed to load time slots", style: TextStyle(color: Colors.red[700])),
// //           );
// //         }
// //         final slots = snap.data ?? const [];
// //         if (slots.isEmpty) {
// //           return const Padding(
// //             padding: EdgeInsets.only(top: 8.0),
// //             child: Text("No time slots on this date."),
// //           );
// //         }

// //         return Padding(
// //           padding: const EdgeInsets.only(top: 8.0),
// //           child: Wrap(
// //             spacing: 8,
// //             runSpacing: 8,
// //             children: [
// //               for (final s in slots)
// //                 ChoiceChip(
// //                   label: Text(s.scheduleTime),
// //                   selected: selectedTimeId != null && s.ids.isNotEmpty && s.ids.first == selectedTimeId,
// //                   onSelected: s.available
// //                       ? (val) {
// //                           if (val && s.ids.isNotEmpty) {
// //                             onPick(s.ids.first);
// //                             onLabel(s.scheduleTime);
// //                           }
// //                         }
// //                       : null,
// //                   disabledColor: Colors.grey.shade200,
// //                   labelStyle: TextStyle(
// //                     color: s.available ? null : Colors.grey,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// //   Widget _buildStatusChip(String status) {
// //     Color chipColor;
// //     Color textColor;
// //     String label = status;
// //     IconData iconData;

// //     switch (status.toLowerCase()) {
// //       case "pending":
// //         chipColor = Colors.orange.withOpacity(0.1);
// //         textColor = Colors.orange;
// //         label = "Pending";
// //         iconData = Icons.schedule;
// //         break;
// //       case "confirmed":
// //         chipColor = Colors.blue.withOpacity(0.1);
// //         textColor = Colors.blue;
// //         label = "Confirmed";
// //         iconData = Icons.check;
// //         break;
// //       case "in_progress":
// //         chipColor = Colors.purple.withOpacity(0.1);
// //         textColor = Colors.purple;
// //         label = "In Progress";
// //         iconData = Icons.directions_run;
// //         break;
// //       case "completed":
// //         chipColor = Colors.green.withOpacity(0.1);
// //         textColor = Colors.green;
// //         label = "Completed";
// //         iconData = Icons.done_all;
// //         break;
// //       case "cancelled":
// //         chipColor = Colors.red.withOpacity(0.1);
// //         textColor = Colors.red;
// //         label = "Cancelled";
// //         iconData = Icons.cancel;
// //         break;
// //       default:
// //         chipColor = Colors.grey.withOpacity(0.1);
// //         textColor = Colors.grey;
// //         label = status.isNotEmpty ? status : "Unknown";
// //         iconData = Icons.help;
// //     }

// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //       decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(8)),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(iconData, size: 12, color: textColor),
// //           const SizedBox(width: 4),
// //           Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
// //         ],
// //       ),
// //     );
// //   }

// //   // Widget _buildPaymentStatusChip(String status) {
// //   //   Color chipColor;
// //   //   Color textColor;
// //   //   String label = status;
// //   //   IconData iconData;
// //   //
// //   //   switch (status.toLowerCase()) {
// //   //     case "paid":
// //   //       chipColor = Colors.green.withOpacity(0.1);
// //   //       textColor = Colors.green;
// //   //       label = "Paid";
// //   //       iconData = Icons.check_circle;
// //   //       break;
// //   //     case "pending":
// //   //       chipColor = Colors.orange.withOpacity(0.1);
// //   //       textColor = Colors.orange;
// //   //       label = "Pending";
// //   //       iconData = Icons.hourglass_empty;
// //   //       break;
// //   //     case "failed":
// //   //       chipColor = Colors.red.withOpacity(0.1);
// //   //       textColor = Colors.red;
// //   //       label = "Failed";
// //   //       iconData = Icons.error;
// //   //       break;
// //   //     default:
// //   //       chipColor = Colors.grey.withOpacity(0.1);
// //   //       textColor = Colors.grey;
// //   //       label = status.isNotEmpty ? status : "Unknown";
// //   //       iconData = Icons.help;
// //   //   }

// //   //   return Container(
// //   //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //   //     decoration: BoxDecoration(
// //   //       color: chipColor,
// //   //       borderRadius: BorderRadius.circular(8),
// //   //     ),
// //   //     child: Row(
// //   //       mainAxisSize: MainAxisSize.min,
// //   //       children: [
// //   //         Icon(iconData, size: 12, color: textColor),
// //   //         const SizedBox(width: 4),
// //   //         Text(
// //   //           label,
// //   //           style: TextStyle(
// //   //             color: textColor,
// //   //             fontSize: 12,
// //   //             fontWeight: FontWeight.w600,
// //   //           ),
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }

// //   // Widget _buildStatusChip(String status) {
// //     Color chipColor;
// //     Color textColor;
// //     String label = status;
// //     IconData iconData;

// //     switch (status.toLowerCase()) {
// //       case "pending":
// //         chipColor = Colors.orange.withOpacity(0.1);
// //         textColor = Colors.orange;
// //         label = "Pending";
// //         iconData = Icons.schedule;
// //         break;
// //       case "confirmed":
// //         chipColor = Colors.blue.withOpacity(0.1);
// //         textColor = Colors.blue;
// //         label = "Confirmed";
// //         iconData = Icons.check;
// //         break;
// //       case "in_progress":
// //         chipColor = Colors.purple.withOpacity(0.1);
// //         textColor = Colors.purple;
// //         label = "In Progress";
// //         iconData = Icons.directions_run;
// //         break;
// //       case "completed":
// //         chipColor = Colors.green.withOpacity(0.1);
// //         textColor = Colors.green;
// //         label = "Completed";
// //         iconData = Icons.done_all;
// //         break;
// //       case "cancelled":
// //         chipColor = Colors.red.withOpacity(0.1);
// //         textColor = Colors.red;
// //         label = "Cancelled";
// //         iconData = Icons.cancel;
// //         break;
// //       default:
// //         chipColor = Colors.grey.withOpacity(0.1);
// //         textColor = Colors.grey;
// //         label = status.isNotEmpty ? status : "Unknown";
// //         iconData = Icons.help;
// //     }

// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //       decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(8)),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(iconData, size: 12, color: textColor),
// //           const SizedBox(width: 4),
// //           Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildEmptyState(BuildContext context) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[400]),
// //           const SizedBox(height: 20),
// //           Text('No Bookings Yet!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])),
// //           const SizedBox(height: 10),
// //           Text('Book your first service now', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
// //           const SizedBox(height: 30),
// //           ElevatedButton(
// //             onPressed: () {
// //               // Go to home
// //               currentHomeIndexNotifier.value = 0;
// //             },
// //             style: ElevatedButton.styleFrom(
// //               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
// //               backgroundColor: primaryColor,
// //               foregroundColor: Colors.white,
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //             ),
// //             child: const Text('Browse Services'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // String _formatScheduleTimeToLocal(BookingModel booking) {
// // //   try {
// // //     // Extract time (e.g., "14:00")
// // //     final timeParts = booking.schedule.scheduleTime.split(':');
// // //     final hour = int.parse(timeParts[0]);
// // //     final minute = int.parse(timeParts[1]);
// // //
// // //     // Create datetime with booking date and schedule time
// // //     final combinedDateTime = DateTime(
// // //       booking.schedule.date.year,
// // //       booking.schedule.date.month,
// // //       booking.schedule.date.day,
// // //       hour,
// // //       minute,
// // //     );
// // //
// // //     // Convert to local and format
// // //     final localDateTime = combinedDateTime.toLocal();
// // //     return DateFormat.jm().format(localDateTime); // e.g., 2:00 PM
// // //   } catch (e) {
// // //     return booking.schedule.scheduleTime; // fallback
// // //   }
// // // }
// import 'dart:convert'; // for pretty logging responses
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

//   /// New multi-select state
//   /// weekNumber -> set of selected dates in that week
//   final Map<int, Set<DateTime>> _pickedDatesByWeek = {};
//   /// yyyy-MM-dd -> chosen time id
//   final Map<String, int> _timeIdByYmd = {};
//   /// yyyy-MM-dd -> chosen time label (e.g. "08:00 AM")
//   final Map<String, String> _timeLabelByYmd = {};

//   @override
//   void initState() {
//     super.initState();
//     _repo = context.read<BookingBloc>().repository;
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

//     context.read<BookingBloc>().add(
//           FetchBookings(page: currentPage, status: statusMap[widget.filterTag] ?? ""),
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<BookingBloc, BookingState>(
//       builder: (context, state) {
//         if (state is BookingLoading) {
//           return const Center(child: AppBookingListShimmer());
//         } else if (state is BookingError) {
//           return Center(child: Text(state.message));
//         } else if (state is BookingLoaded) {
//           final bookings = state.bookings;
//           if (bookings.isEmpty) return _buildEmptyState(context);

//           return ListView.builder(
//             padding: const EdgeInsets.all(20),
//             itemCount: bookings.length,
//             itemBuilder: (context, index) => buildBookingCard(context, bookings[index]),
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
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.asset("assets/icon/aed_symbol.png", width: 16, height: 16, fit: BoxFit.contain),
//             const SizedBox(width: 4),
//             Text(
//               booking.total.toStringAsFixed(2),
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
//             ),
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
//             Expanded(
//               child: Text(
//                 DateFormat("d MMMM, y").format(booking.createdAt.toLocal()),
//                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
//               ),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             Icon(Icons.calendar_today, size: 16, color: primaryColor),
//             const SizedBox(width: 4),
//             Expanded(
//               child: Text(
//                 "Booked For: ${booking.bookingDate}",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
//               ),
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
//             booking.schedule,
//             style: TextStyle(color: Colors.grey[600], fontSize: 14),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildItemsSummary(AppBookingModel booking) {
//     if (booking.items.isEmpty) return const SizedBox.shrink();
//     final itemCount = booking.items.length;
//     final summary = itemCount == 1
//         ? booking.items[0].thirdCategoryName
//         : "${booking.items[0].thirdCategoryName} +${itemCount - 1} more";
//     return Text(summary, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis);
//   }

//   Widget _buildFooterRow(AppBookingModel booking) {
//     final showSelectDates = _hasAnyUnbooked(booking);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Top row: left = subscription/single chip, right = status chip
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.blue[50],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.repeat, size: 14, color: Colors.blue[600]),
//                   const SizedBox(width: 4),
//                   Text(
//                     booking.hasSubscription ? "Subscription" : 'Single',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.blue[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Spacer(),
//             _buildStatusChip(booking.orderStatus),
//           ],
//         ),

//         // Bottom row: right-aligned "Select dates" button (only when needed)
//         if (showSelectDates) ...[
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TextButton.icon(
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.white,
//                   backgroundColor: Colors.red.shade600,
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () => _showSubscriptionDateSheet(context, booking),
//                 icon: const Icon(Icons.event_note, size: 16, color: Colors.white),
//                 label: const Text(
//                   "Select dates",
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ],
//     );
//   }

//   bool _hasAnyUnbooked(AppBookingModel b) {
//     if (!b.hasSubscription) return false;
//     if (b.weeklySchedules.isEmpty) return false;
//     return b.weeklySchedules.any((w) => !w.isBooked);
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

//   // ---------- helpers for multi-select logic ----------

//   String _ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

//   DateTime? _parseYmd(String s) {
//     try {
//       return DateTime.parse(s);
//     } catch (_) {
//       return null;
//     }
//   }

//   bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

//   WeeklySchedule? _findWeekForDate(List<WeeklySchedule> weeks, DateTime date) {
//     for (final w in weeks) {
//       final s = _parseYmd(w.startDate);
//       final e = _parseYmd(w.endDate);
//       if (s != null && e != null) {
//         final inRange = !date.isBefore(s) && !date.isAfter(e);
//         if (inRange) return w;
//       }
//     }
//     return null;
//   }

//   int _countSelectedInMonth(DateTime monthAnchor) {
//     int count = 0;
//     for (final set in _pickedDatesByWeek.values) {
//       for (final d in set) {
//         if (_isSameMonth(d, monthAnchor)) count++;
//       }
//     }
//     return count;
//   }

//   bool _tryAddDate({
//     required AppBookingModel booking,
//     required WeeklySchedule week,
//     required DateTime date,
//   }) {
//     final primaryItem = booking.items.isNotEmpty ? booking.items.first : null;

//     // If your data carries mode at booking level, you can fallback:
//     final subscriptionMode = (primaryItem?.subscriptionMode ?? '').toLowerCase();
//     final timesPerWeek = primaryItem?.timesPerWeek ?? 1;
//     final timesPerMonth = primaryItem?.timesPerMonth ?? 1;

//     _pickedDatesByWeek.putIfAbsent(week.weekNumber, () => <DateTime>{});

//     if (subscriptionMode == 'weekly') {
//       final current = _pickedDatesByWeek[week.weekNumber]!.length;
//       if (current >= timesPerWeek) return false; // hit per-week cap
//     } else if (subscriptionMode == 'monthly') {
//       final monthCount = _countSelectedInMonth(date);
//       if (monthCount >= timesPerMonth) return false; // hit per-month cap
//     }

//     _pickedDatesByWeek[week.weekNumber]!.add(date);
//     return true;
//   }

//   void _removeDate(WeeklySchedule week, DateTime date) {
//     final set = _pickedDatesByWeek[week.weekNumber];
//     if (set == null) return;
//     set.remove(date);
//     final key = _ymd(date);
//     _timeIdByYmd.remove(key);
//     _timeLabelByYmd.remove(key);
//   }

//   int? _selectedTimeIdFor(DateTime date) => _timeIdByYmd[_ymd(date)];
//   String? _selectedTimeLabelFor(DateTime date) => _timeLabelByYmd[_ymd(date)];

//   void _setTimeFor(DateTime date, int id, String label) {
//     final k = _ymd(date);
//     _timeIdByYmd[k] = id;
//     _timeLabelByYmd[k] = label;
//   }

//   // ---------- bottom sheet: multi-date & per-date times ----------

//   void _showSubscriptionDateSheet(BuildContext context, AppBookingModel booking) {
//     bool saving = false;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) {
//         final weeks = booking.weeklySchedules;
//         final primaryItem = booking.items.isNotEmpty ? booking.items.first : null;
//         final mode = (primaryItem?.subscriptionMode ?? '').toLowerCase();
//         final timesPerWeek = primaryItem?.timesPerWeek ?? 1;
//         final timesPerMonth = primaryItem?.timesPerMonth ?? 1;

//         return SafeArea(
//           child: SizedBox(
//             height: MediaQuery.of(context).size.height * 0.85,
//             child: weeks.isEmpty
//                 ? const Center(child: Text("No subscription weeks available."))
//                 : StatefulBuilder(
//                     builder: (context, setSheetState) {
//                       Future<void> _pickDateForWeek(WeeklySchedule w) async {
//                         final s = _parseYmd(w.startDate);
//                         final e = _parseYmd(w.endDate);
//                         if (s == null || e == null) return;

//                         final picked = await showDatePicker(
//                           context: context,
//                           initialDate: s,
//                           firstDate: s,
//                           lastDate: e,
//                         );
//                         if (picked != null) {
//                           final ok = _tryAddDate(booking: booking, week: w, date: picked);
//                           if (!ok) {
//                             final limitMsg = mode == 'weekly'
//                                 ? "You can pick up to $timesPerWeek date(s) in this week."
//                                 : "You can pick up to $timesPerMonth date(s) in this month.";
//                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(limitMsg)));
//                             return;
//                           }
//                           setSheetState(() {}); // refresh list
//                         }
//                       }

//                       Future<void> _saveAll() async {
//                         // Build: backend week id -> [ {date, time_schedule_id}, ... ]
//                         final Map<int, List<Map<String, dynamic>>> payloadByWeekId = {};
//                         int totalDates = 0;

//                         // Verify each date has a time, and group by week backend id
//                         final weekByNumber = {for (final w in weeks) w.weekNumber: w};

//                         for (final entry in _pickedDatesByWeek.entries) {
//                           final wkNumber = entry.key;
//                           final dates = entry.value.toList()..sort();
//                           final wk = weekByNumber[wkNumber];
//                           if (wk == null) continue;

//                           for (final d in dates) {
//                             final timeId = _selectedTimeIdFor(d);
//                             if (timeId == null) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text("Please pick a time for ${DateFormat('d MMM y').format(d)}.")),
//                               );
//                               return;
//                             }
//                             payloadByWeekId.putIfAbsent(wk.id, () => <Map<String, dynamic>>[]);
//                             payloadByWeekId[wk.id]!.add({
//                               "date": _ymd(d),
//                               "time_schedule_id": timeId,
//                             });
//                             totalDates++;
//                           }
//                         }

//                         if (payloadByWeekId.isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No dates selected.")));
//                           return;
//                         }

//                         setSheetState(() => saving = true);

//                         int success = 0;
//                         try {
//                           for (final w in weeks) {
//                             final days = payloadByWeekId[w.id];
//                             if (days == null || days.isEmpty) continue;

//                             final resp = await _repo.updateWeeklySchedule(
//                               scheduleId: w.id,
//                               orderId: booking.id, // encrypted order id
//                               startDate: w.startDate,
//                               endDate: w.endDate,
//                               days: days,
//                             );

//                             // Pretty print response for debugging
//                             try {
//                               final pretty = const JsonEncoder.withIndent('  ').convert(resp);
//                               debugPrint("✅ Updated week ${w.weekNumber} (id=${w.id})\n$pretty");
//                             } catch (_) {
//                               debugPrint("✅ Updated week ${w.weekNumber} (id=${w.id}) raw: $resp");
//                             }

//                             success++;
//                           }

//                           if (context.mounted) {
//                             Navigator.pop(context);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text("Saved $totalDates date(s) in $success week(s).")),
//                             );
//                           }
//                         } catch (e) {
//                           setSheetState(() => saving = false);
//                           if (context.mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text("Failed to save: $e")),
//                             );
//                           }
//                         }
//                       }

//                       return Column(
//                         children: [
//                           // Header
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       const Text("Select dates & times",
//                                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
//                                       if (mode == 'weekly')
//                                         Text("Up to $timesPerWeek per week", style: TextStyle(color: Colors.grey[700])),
//                                       if (mode == 'monthly')
//                                         Text("Up to $timesPerMonth per month", style: TextStyle(color: Colors.grey[700])),
//                                     ],
//                                   ),
//                                 ),
//                                 TextButton(
//                                   onPressed: saving ? null : () => Navigator.pop(context),
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
//                                 final s = _parseYmd(w.startDate);
//                                 final e = _parseYmd(w.endDate) ?? s;
//                                 final booked = w.isBooked;

//                                 final pickedSet = _pickedDatesByWeek[w.weekNumber] ?? <DateTime>{};
//                                 final perWeekCount = pickedSet.length;
//                                 final weekCapHit = (mode == 'weekly') && (perWeekCount >= timesPerWeek);

//                                 // For monthly, we cap by month across all weeks:
//                                 final monthCapHit = (mode == 'monthly' && s != null && _countSelectedInMonth(s) >= timesPerMonth);

//                                 return Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     boxShadow: [
//                                       BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
//                                               "${s != null ? DateFormat('d MMM').format(s) : '--'} – "
//                                               "${e != null ? DateFormat('d MMM').format(e!) : '--'}",
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
//                                                 Icon(booked ? Icons.check_circle : Icons.error_outline,
//                                                     size: 14, color: booked ? Colors.green : Colors.red),
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

//                                       const SizedBox(height: 12),

//                                       // Already picked dates for this week
//                                       if (pickedSet.isNotEmpty) ...[
//                                         for (final d in (pickedSet.toList()..sort()))
//                                           Container(
//                                             margin: const EdgeInsets.only(bottom: 8),
//                                             padding: const EdgeInsets.all(8),
//                                             decoration: BoxDecoration(
//                                               border: Border.all(color: Colors.grey.shade200),
//                                               borderRadius: BorderRadius.circular(10),
//                                             ),
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Row(
//                                                   children: [
//                                                     Expanded(
//                                                       child: Text(
//                                                         DateFormat('EEE, d MMM y').format(d),
//                                                         style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//                                                       ),
//                                                     ),
//                                                     IconButton(
//                                                       icon: const Icon(Icons.delete_outline),
//                                                       onPressed: saving ? null : () => setSheetState(() => _removeDate(w, d)),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 _TimeSlotsForDate(
//                                                   repo: _repo,
//                                                   orderId: booking.id,
//                                                   weekNumber: w.weekNumber,
//                                                   date: d,
//                                                   selectedTimeId: _selectedTimeIdFor(d),
//                                                   onPick: (timeId) => setSheetState(() {
//                                                     _setTimeFor(d, timeId, _selectedTimeLabelFor(d) ?? '');
//                                                   }),
//                                                   onLabel: (label) => setSheetState(() {
//                                                     final id = _selectedTimeIdFor(d);
//                                                     if (id != null) _setTimeFor(d, id, label);
//                                                   }),
//                                                 ),
//                                                 final tId = _selectedTimeIdFor(d);
//                                                 final tLabel = _selectedTimeLabelFor(d);
//                                                 if (tId != null && tLabel != null && tLabel.isNotEmpty)
//                                                   Padding(
//                                                     padding: const EdgeInsets.only(top: 6),
//                                                     child: Text("Chosen: $tLabel",
//                                                         style: const TextStyle(fontWeight: FontWeight.w600)),
//                                                   ),
//                                               ],
//                                             ),
//                                           ),
//                                       ],

//                                       // Add date button
//                                       Align(
//                                         alignment: Alignment.centerRight,
//                                         child: TextButton.icon(
//                                           style: TextButton.styleFrom(
//                                             foregroundColor: Colors.white,
//                                             backgroundColor: (booked || saving || (mode == 'weekly' && weekCapHit) || (mode == 'monthly' && monthCapHit))
//                                                 ? Colors.grey
//                                                 : Colors.red.shade600,
//                                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                           ),
//                                           onPressed: (booked || saving || s == null || e == null || (mode == 'weekly' && weekCapHit) || (mode == 'monthly' && monthCapHit))
//                                               ? null
//                                               : () => _pickDateForWeek(w),
//                                           icon: const Icon(Icons.event_available, size: 18, color: Colors.white),
//                                           label: const Text("Add date", style: TextStyle(color: Colors.white)),
//                                         ),
//                                       ),
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
//                                     style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
//                                     onPressed: saving ? null : _saveAll,
//                                     icon: saving
//                                         ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
//                                         : const Icon(Icons.save),
//                                     label: Text(saving ? "Saving..." : "Save selections"),
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
//   final String orderId; // encrypted order id (if your API needs it for availability)
//   final int weekNumber;
//   final DateTime date;
//   final int? selectedTimeId;
//   final ValueChanged<int> onPick; // chosen timeId
//   final ValueChanged<String> onLabel; // chosen label

//   const _TimeSlotsForDate({
//     required this.repo,
//     required this.orderId,
//     required this.weekNumber,
//     required this.date,
//     required this.selectedTimeId,
//     required this.onPick,
//     required this.onLabel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<TimeSlotOption>>(
//       // If your repo doesn't take orderId, remove the named arg.
//       future: repo.fetchTimeSlotsForDate(date, orderId: orderId),
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
//                             onPick(s.ids.first);     // set selected time id
//                             onLabel(s.scheduleTime); // set display label
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
// }
