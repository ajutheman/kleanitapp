import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/color_data.dart';
import '../../bloc/weekly_schedule_bloc.dart';
import '../../bloc/weekly_schedule_event.dart';
import '../../bloc/weekly_schedule_state.dart';
import '../../model/weekly_schedule.dart';

class WeeklyScheduleSelector extends StatefulWidget {
  final String orderId;

  const WeeklyScheduleSelector({super.key, required this.orderId});

  @override
  State<WeeklyScheduleSelector> createState() => _WeeklyScheduleSelectorState();
}

class _WeeklyScheduleSelectorState extends State<WeeklyScheduleSelector> with TickerProviderStateMixin {
  final List<String> _allDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<WeeklyScheduleBloc>().add(FetchWeeklySchedule(orderId: widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WeeklyScheduleBloc, WeeklyScheduleState>(
      listener: (context, state) {
        if (state is WeeklyScheduleError) {
          Fluttertoast.showToast(msg: state.message);
        } else if (state is WeeklyScheduleSuccess) {
          Fluttertoast.showToast(msg: "Schedule updated");
        }
      },
      builder: (context, state) {
        if (state is WeeklyScheduleLoaded) {
          final currentWeek = state.schedule.firstWhere((s) => s.startDate.isBefore(DateTime.now()) && s.endDate.isAfter(DateTime.now()));
          final nextWeek = state.schedule.firstWhere(
            (s) => s.startDate.isBefore(DateTime.now().add(Duration(days: 7))) && s.endDate.isAfter(DateTime.now().add(Duration(days: 7))),
          );

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: Offset(0.0, 10.0))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Select Working Days", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text("Maximum ${state.schedule.first.weekNumber} days", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  TabBar(controller: _tabController, labelColor: Colors.black, indicatorColor: Colors.blue, tabs: [Tab(text: "Current Week"), Tab(text: "Upcoming Week")]),
                  SizedBox(height: 350, child: TabBarView(controller: _tabController, children: [contentBox(currentWeek), contentBox(nextWeek)])),
                ],
              ),
            ),
          );
        }
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          elevation: 0,
          backgroundColor: Colors.white,
          child: SizedBox(height: 300, width: 100, child: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }

  Widget contentBox(WeeklySchedule schedule) {
    final dateFormat = DateFormat('d MMM'); // e.g., 26 Jun
    final dateRangeText = '${dateFormat.format(schedule.startDate)} - ${dateFormat.format(schedule.endDate)}';

    return Column(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(dateRangeText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
        Expanded(
          child: ListView.builder(
            itemCount: _allDays.length,
            itemBuilder: (context, index) {
              final day = _allDays[index];
              final isSelected = _isDaySelected(day, schedule.days);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  onTap: () {
                    if (isSelected) {
                      _toggleDay(day, schedule.days, false);
                    } else {
                      if (_selectedCount(schedule.days) < schedule.weekNumber) {
                        _toggleDay(day, schedule.days, true);
                      } else {
                        Fluttertoast.showToast(msg: 'You can select maximum ${schedule.weekNumber} days');
                      }
                    }
                    setState(() {});
                  },
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? primaryColor : Colors.grey[200],
                    child: isSelected ? const Icon(Icons.check, color: Colors.white) : Text(day[0], style: TextStyle(color: Colors.grey[800])),
                  ),
                  title: Text(day, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? primaryColor : Colors.black87)),
                  trailing: isSelected ? Icon(Icons.check_circle, color: primaryColor) : null,
                  tileColor: isSelected ? primaryColor.withOpacity(0.1) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isSelected ? primaryColor : Colors.transparent, width: 1)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: primaryColor),
              child: const Text("Cancel", style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<WeeklyScheduleBloc>().add(UpdateWeeklySchedule(id: schedule.id, days: schedule.days));

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Confirm", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  bool _isDaySelected(String day, WeeklyScheduleDays weekSchedule) {
    switch (day) {
      case 'Sunday':
        return weekSchedule.sunday;
      case 'Monday':
        return weekSchedule.monday;
      case 'Tuesday':
        return weekSchedule.tuesday;
      case 'Wednesday':
        return weekSchedule.wednesday;
      case 'Thursday':
        return weekSchedule.thursday;
      case 'Friday':
        return weekSchedule.friday;
      case 'Saturday':
        return weekSchedule.saturday;
      default:
        return false;
    }
  }

  int _selectedCount(WeeklyScheduleDays weekSchedule) {
    return [
      weekSchedule.sunday,
      weekSchedule.monday,
      weekSchedule.tuesday,
      weekSchedule.wednesday,
      weekSchedule.thursday,
      weekSchedule.friday,
      weekSchedule.saturday,
    ].where((d) => d).length;
  }

  void _toggleDay(String day, WeeklyScheduleDays weekSchedule, bool value) {
    setState(() {
      switch (day) {
        case 'Sunday':
          weekSchedule.sunday = value;
          break;
        case 'Monday':
          weekSchedule.monday = value;
          break;
        case 'Tuesday':
          weekSchedule.tuesday = value;
          break;
        case 'Wednesday':
          weekSchedule.wednesday = value;
          break;
        case 'Thursday':
          weekSchedule.thursday = value;
          break;
        case 'Friday':
          weekSchedule.friday = value;
          break;
        case 'Saturday':
          weekSchedule.saturday = value;
          break;
      }
    });
  }
}
