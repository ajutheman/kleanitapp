import 'package:flutter/material.dart';

import '../../core/theme/color_data.dart';
import '../account/screens/account_screen.dart';
import '../bookings/screens/tab_booking.dart';
import '../cart/screens/carts_screen.dart';
import 'homescreen.dart';

// Use ValueNotifier instead of global int
final ValueNotifier<int> currentHomeIndexNotifier = ValueNotifier<int>(0);

class HomeMainView extends StatelessWidget {
  HomeMainView({super.key});

  final List<IconData> _icons = [Icons.home, Icons.calendar_today, Icons.shopping_cart, Icons.account_circle];

  final List<String> _labels = ["Home", "Bookings", "Carts", "Account"];

  final List<Widget> _screens = const [HomeScreen(), TabBookings(), CartListScreen(), TabProfile()];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentHomeIndexNotifier,
      builder: (context, currentIndex, _) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(child: SafeArea(child: _screens[currentIndex])),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_icons.length, (index) {
                    final isSelected = currentIndex == index;
                    return GestureDetector(
                      onTap: () {
                        currentHomeIndexNotifier.value = index;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Icon(_icons[index], color: isSelected ? primaryColor : Colors.grey),
                            const SizedBox(width: 5),
                            if (isSelected) Text(_labels[index], style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500, fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
