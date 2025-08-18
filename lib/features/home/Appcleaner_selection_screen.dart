import 'package:flutter/material.dart';

import '../../routes/app_routes..dart';
import '../categories/modle/Appcategory_model.dart';

class AppCleanerServiceSelectionScreen extends StatelessWidget {
  final AppMainCategory category;

  const AppCleanerServiceSelectionScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Part-Time Cleaners', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        actions: [IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            Container(
              width: double.infinity,
              color: const Color(0xFF077975),
              padding: const EdgeInsets.all(24),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('We deliver\nspotless homes', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2)),
                      SizedBox(height: 12),
                      Text('Professionals trained\nfor 100+ hours', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                  // const Positioned(
                  //   right: 0,
                  //   bottom: 0,
                  //   child: Image(
                  //     image: AssetImage('assets/cleaner.png'),
                  //     width: 100,
                  //     height: 130,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                ],
              ),
            ),

            // Section title
            const Padding(padding: EdgeInsets.fromLTRB(16, 24, 16, 16), child: Text('Choose your requirement', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),

            // Service options
            _buildServiceOption(
              context,
              icon: 'assets/images/cleaning_bucket.png',
              title: 'Single visit',
              description: 'Pay per service for\none-time cleaning needs',
              badge: null,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.categoryDetail, arguments: {"main_category_id": category.id, "type": "single", "category": category});
              },
            ),

            const Divider(height: 1),

            _buildServiceOption(
              context,
              icon: 'assets/images/calendar.jpg',
              title: 'Monthly subscription',
              description: '1 to 6 times a week\nSame cleaner on each visit',
              badge: 'RMD SPECIAL: 25% OFF',
              badgeColor: Colors.green[100]!,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.categoryDetail, arguments: {"main_category_id": category.id, "type": "subscribe", "category": category});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceOption(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required String? badge,
    Color badgeColor = Colors.green,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            // Icon
            Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Image.asset(icon, width: 50, height: 50),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(4)),
                      child: Text(badge, style: TextStyle(color: Colors.green[800], fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.3)),
                ],
              ),
            ),

            // Arrow
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}
