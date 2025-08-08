import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kleanit/features/Referral/referal_advertisement.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/color_data.dart';
// import '../Referral/model/referal_advertisement.dart'; // Adjust the path as needed

class ReferralCarousel extends StatefulWidget {
  final List<ReferalAdvertisement> referalAds;
  final double height;
  const ReferralCarousel({
    Key? key,
    required this.referalAds,
    required this.height,
  }) : super(key: key);

  @override
  _ReferralCarouselState createState() => _ReferralCarouselState();
}

class _ReferralCarouselState extends State<ReferralCarousel> {
  late PageController _controller;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.referalAds.length > 1) {
      _autoScrollTimer =
          Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        _currentPage++;
        if (_currentPage >= widget.referalAds.length) {
          _currentPage = 0;
        }
        if (mounted) {
          _controller.animateToPage(
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.referalAds.length,
        itemBuilder: (context, index) {
          final referAd = widget.referalAds[index];
          return Container(
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(referAd.image),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          referAd.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          referAd.content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            // Handle refer action.

                            print(
                                "Refer Now pressed"); // <--- Confirm this shows
                            log("Refer Now pressed"); // <--- Confirm this shows
                            try {
                              final imageUrl = referAd.image;
                              final response =
                                  await http.get(Uri.parse(imageUrl));

                              if (response.statusCode == 200) {
                                final bytes = response.bodyBytes;
                                final tempDir = await getTemporaryDirectory();
                                // final file = await File('${tempDir.path}/refer_ad.jpg').writeAsBytes(bytes);
                                final file =
                                    File('${tempDir.path}/refer_ad.jpg');
                                await file.writeAsBytes(bytes);

                                final message =
                                    '${referAd.title}\n\n${referAd.title}\n\n${referAd.content}\n\nDownload App now:  https://play.google.com/store/apps/details?id=com.spydo.kleanit&pcampaignid=web_share \n ';

                                final xFile = XFile(file.path);

                                log("Sharing file: ${file.path}");
                                await Share.shareXFiles(
                                  [XFile(file.path)],
                                  text: message,
                                );
                              } else {
                                log("Image download failed with status ${response.statusCode}");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Failed to download image.")),
                                );
                              }
                            } catch (e) {
                              print("Share error: $e");
                              log("Sharing error: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "An error occurred while sharing.")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Refer Now'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
