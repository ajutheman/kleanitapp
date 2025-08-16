import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppBookingListShimmer extends StatelessWidget {
  final int itemCount;

  const AppBookingListShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: itemCount,
      itemBuilder:
          (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + price row
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_shimmerBox(width: 160, height: 16), _shimmerBox(width: 60, height: 16)]),
                    const SizedBox(height: 12),
                    // Date row
                    Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.grey), const SizedBox(width: 8), _shimmerBox(width: 100, height: 14)]),
                    const SizedBox(height: 10),
                    // Time row
                    Row(children: [const Icon(Icons.access_time, size: 16, color: Colors.grey), const SizedBox(width: 8), _shimmerBox(width: 80, height: 14)]),
                    const SizedBox(height: 10),
                    // Description
                    _shimmerBox(width: 200, height: 14),
                    const SizedBox(height: 12),
                    // Chip Row
                    Row(children: [_chipShimmer(), const SizedBox(width: 8), _chipShimmer(width: 70)]),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _shimmerBox({double width = 100, double height = 14}) {
    return Container(width: width, height: height, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)));
  }

  Widget _chipShimmer({double width = 60, double height = 24}) {
    return Container(width: width, height: height, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)));
  }
}
