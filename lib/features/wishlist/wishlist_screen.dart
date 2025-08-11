import 'package:flutter/material.dart';

import '../../core/theme/color_data.dart';

class TabWishlist extends StatelessWidget {
  const TabWishlist({Key? key}) : super(key: key);

  static const List<Map<String, dynamic>> wishlistItems = [
    {
      'title': 'Full Home Deep Cleaning',
      'image': 'assets/images/deep_cleaning.png',
      'rating': 4.87,
      'reviews': 15000,
      'price': '₹5,999',
      'duration': '5 hours',
      'description': 'Includes all rooms, kitchen, washrooms, furniture, and floor scrubbing.',
    },
    {
      'title': '1 BHK Home Cleaning',
      'image': 'assets/images/home_cleaning.png',
      'rating': 4.79,
      'reviews': 8000,
      'price': '₹3,199',
      'duration': '3-4 hours',
      'description': 'Includes 1 bedroom, 1 bathroom, 1 hall, 1 kitchen & 1 balcony. Excludes terrace cleaning & paint marks removal.',
    },
    {
      'title': '2 BHK Home Cleaning',
      'image': 'assets/images/home_cleaning.png',
      'rating': 4.81,
      'reviews': 22000,
      'price': '₹3,499',
      'duration': '4-5 hours',
      'description': 'Includes 2 bedrooms, 2 bathrooms, 1 hall, 1 kitchen & 2 balconies. Excludes terrace cleaning & paint marks removal.',
    },
    {
      'title': 'Small Office Cleaning (up to 500 sq. ft.)',
      'image': 'assets/images/office_cleaning.png',
      'rating': 4.85,
      'reviews': 5000,
      'price': '₹2,999',
      'duration': '2-3 hours',
      'description': 'Includes workstations, chairs, desks, and floors. Excludes deep carpet cleaning.',
    },
    {
      'title': 'Move-in Cleaning',
      'image': 'assets/images/move_in_out.png',
      'rating': 4.80,
      'reviews': 9000,
      'price': '₹6,499',
      'duration': '6-7 hours',
      'description': 'Includes empty home deep cleaning before moving in. Excludes pest control services.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child:
              wishlistItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: wishlistItems.length,
                    itemBuilder: (context, index) {
                      return _buildWishlistItem(wishlistItems[index]);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Wishlists', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            // onPressed: () => Navigator.pushNamed(context, Routes.notificationRoutes),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and favorite button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(item['image'], height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
                      child: Text(item['price'], style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 18, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text('${item['rating']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(' (${item['reviews']} reviews)', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(item['duration'], style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 12),
                Text(item['description'], style: TextStyle(color: Colors.grey[600], height: 1.4)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Remove from wishlist
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text('Remove'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Book service
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Book Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Your Wishlist is Empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 8),
          Text('Save your favorite services here', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to services
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              backgroundColor: Colors.blue[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Explore Services'),
          ),
        ],
      ),
    );
  }
}
