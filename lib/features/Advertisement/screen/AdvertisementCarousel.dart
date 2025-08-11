import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kleanitapp/core/theme/resizer/fetch_pixels.dart';
import 'package:kleanitapp/core/theme/widget_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/color_data.dart';
import '../model/advertisement_model.dart';

class AdvertisementCarousel extends StatefulWidget {
  final List<Advertisement> advertisements;
  final void Function(Advertisement) onBookTap;

  const AdvertisementCarousel({Key? key, required this.advertisements, required this.onBookTap}) : super(key: key);

  @override
  _AdvertisementCarouselState createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<AdvertisementCarousel> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.advertisements.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _currentPage++;
        if (_currentPage >= widget.advertisements.length) {
          _currentPage = 0;
        }
        if (mounted) {
          _pageController.animateToPage(
            // timer=Timer(duration, callback)
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: FetchPixels.getPixelHeight(184),
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.advertisements.length,
        itemBuilder: (context, index) {
          final ad = widget.advertisements[index];
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: Container(
                  height: FetchPixels.getPixelHeight(180),
                  width: FetchPixels.getPixelWidth(374),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      getPaddingWidget(
                        EdgeInsets.only(left: FetchPixels.getPixelWidth(20), top: FetchPixels.getPixelHeight(20), bottom: FetchPixels.getPixelHeight(20)),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: FetchPixels.getPixelWidth(130),
                              child: getMultilineCustomFont(ad.name, 16, Colors.black, fontWeight: FontWeight.w800, maxLine: 3, txtHeight: FetchPixels.getPixelHeight(1.3)),
                            ),
                            getVerSpace(FetchPixels.getPixelHeight(8)),
                            getCustomFont("Check out our offers", 14, Colors.black, 1, fontWeight: FontWeight.w400),
                            Spacer(),
                            getButton(
                              context,
                              primaryColor,
                              "Book Now",
                              Colors.white,
                              () {
                                widget.onBookTap(ad);
                              },
                              14,
                              weight: FontWeight.w600,
                              buttonWidth: FetchPixels.getPixelWidth(108),
                              borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(10)),
                              insetsGeometrypadding: EdgeInsets.symmetric(vertical: FetchPixels.getPixelHeight(12)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: FetchPixels.getPixelWidth(21)),
                        height: FetchPixels.getPixelHeight(175),
                        width: FetchPixels.getPixelHeight(142),
                        color: Colors.transparent,
                        child: Image.network(ad.image, fit: BoxFit.cover),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ShimmerAdvertisementLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: FetchPixels.getPixelHeight(184),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3, // Show 3 shimmer placeholders
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(10)),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: FetchPixels.getPixelWidth(374),
                height: FetchPixels.getPixelHeight(180),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              ),
            ),
          );
        },
      ),
    );
  }
}
