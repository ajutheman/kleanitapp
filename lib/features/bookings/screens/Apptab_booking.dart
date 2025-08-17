// tab_booking.dart
import 'package:flutter/material.dart';

import '../../../core/theme/sypd_color.dart';
import '../../notification/screen/Appnotification_screen.dart';
import 'Appbooking_list_screen.dart';

class AppTabBookings extends StatefulWidget {
  const AppTabBookings({Key? key}) : super(key: key);

  @override
  State<AppTabBookings> createState() => _AppTabBookingsState();
}

class _AppTabBookingsState extends State<AppTabBookings> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ["All", "Completed", "Cancelled"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildHeader(), _buildTabBar(), Expanded(child: _buildTabView())]);
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Bookings', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AppNotificationListScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicator: ShapeDecoration(color: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildTabView() {
    return TabBarView(controller: _tabController, children: _tabs.map((tab) => AppBookingList(filterTag: tab)).toList());
  }
}
