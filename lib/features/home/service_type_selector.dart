import 'package:flutter/material.dart';
import 'package:kleanitapp/core/constants/constants.dart';
import 'package:kleanitapp/core/theme/color_data.dart';

class ServiceTypeSelector extends StatefulWidget {
  final Function(String) onTypeSelected;
  final String initialSelection;

  const ServiceTypeSelector({super.key, required this.onTypeSelected, this.initialSelection = SubscriptionType.SINGLE});

  @override
  State<ServiceTypeSelector> createState() => _ServiceTypeSelectorState();
}

class _ServiceTypeSelectorState extends State<ServiceTypeSelector> with SingleTickerProviderStateMixin {
  late String _selectedType;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialSelection;
    _tabController = TabController(length: 2, vsync: this, initialIndex: _selectedType == SubscriptionType.SINGLE ? 0 : 1);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedType = _tabController.index == 0 ? SubscriptionType.SINGLE : SubscriptionType.SUBSCRIPTION;
      });
      widget.onTypeSelected(_selectedType);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.0), spreadRadius: 0, blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          tabBarTheme: TabBarTheme(
            indicatorColor: Colors.transparent,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            dividerColor: Colors.transparent, // ✅ Important
          ),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.transparent,
          // ✅ Prevents default underline
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [primaryColor, primaryColor.withOpacity(.7)]),
            boxShadow: [BoxShadow(color: Color(0xFF4285F4).withOpacity(0.3), spreadRadius: 0, blurRadius: 6, offset: Offset(0, 2))],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade800,
          labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: 0.3),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          labelPadding: EdgeInsets.symmetric(vertical: 12),
          tabs: [
            _buildTab(title: "Single", subtitle: "For hours & days", icon: Icons.watch_later_outlined, isSelected: _tabController.index == 0),
            _buildTab(title: "Subscriptions", subtitle: "For months & years", icon: Icons.calendar_month_outlined, isSelected: _tabController.index == 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({required String title, required String subtitle, required IconData icon, required bool isSelected}) {
    return Tab(
      height: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.grey.shade700),
              SizedBox(width: 4),
              Text(title, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
            ],
          ),
          // SizedBox(height:5),
          // Text(
          //   subtitle,
          //   style: TextStyle(
          //     fontSize: 11,
          //     fontWeight: FontWeight.w400,
          //     color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
          //   ),
          // ),
        ],
      ),
    );
  }
}
