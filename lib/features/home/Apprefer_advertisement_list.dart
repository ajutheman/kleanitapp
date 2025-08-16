import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kleanitapp/core/theme/resizer/sypdo_fetch_pixels.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';

import '../../core/theme/sypd_color.dart';
import '../Referral/Appreferal_advertisement.dart';
import '../Referral/Appreferral_carousel.dart';

class AppReferalAdvertisementList extends StatelessWidget {
  final List<AppReferalAdvertisement> referals;

  AppReferalAdvertisementList({required this.referals});

  @override
  Widget build(BuildContext context) {
    if (referals.isEmpty) {
      return Container();
    } else if (referals.length == 1) {
      return AppReferralCarousel(referalAds: referals, height: FetchPixels.getPixelHeight(188));
    } else {
      // final referAd = referals.first;
      return _buildSingleReferalAd(context, referals.first);
      //   Container(
      //   height: 184,
      //   padding: const EdgeInsets.symmetric(horizontal: 20),
      //   child: Container(
      //     decoration: BoxDecoration(
      //       borderRadius: BorderRadius.circular(20),
      //       image: DecorationImage(
      //         image: NetworkImage(referAd.image),
      //         fit: BoxFit.cover,
      //       ),
      //     ),
      //     child: Stack(
      //       children: [
      //         Container(
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(20),
      //             gradient: LinearGradient(
      //               begin: Alignment.centerLeft,
      //               end: Alignment.centerRight,
      //               colors: [
      //                 Colors.black.withOpacity(0.6),
      //                 Colors.transparent,
      //               ],
      //             ),
      //           ),
      //         ),
      //         Padding(
      //           padding: const EdgeInsets.all(10),
      //           child: SizedBox(height: 120,
      //             child: SingleChildScrollView(
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 // mainAxisAlignment: MainAxisAlignment.center,
      //                 // mainAxisSize: MainAxisSize.min,
      //                 children: [
      //                   Text(
      //                     referAd.title,
      //                     style: const TextStyle(
      //                       color: Colors.white,
      //                       fontSize: 24,
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                   ),
      //                   const SizedBox(height: 8),
      //                   // Text(
      //                   //   referAd.content,
      //                   //   style: const TextStyle(
      //                   //     color: Colors.white,
      //                   //     fontSize: 16,
      //                   //   ),
      //                   // ),
      //                   Text(
      //                     referAd.content,
      //                     overflow: TextOverflow.ellipsis,
      //                     maxLines: 2,  style: const TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 16,
      //                   ),
      //                   ),
      //                   const SizedBox(height: 10),
      //                   // ElevatedButton(
      //                   //   onPressed: () {
      //                   //     // Handle refer action.
      //                   //   },
      //                   //   style: ElevatedButton.styleFrom(
      //                   //     backgroundColor: Colors.white,
      //                   //     foregroundColor: primaryColor,
      //                   //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      //                   //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      //                   //   ),
      //                   //   child: const Text('Refer Now'),
      //                   // ),
      //                   ElevatedButton(
      //                     onPressed: () async {
      //                       print("Refer Now pressed"); // <--- Confirm this shows
      //                       log("Refer Now pressed"); // <--- Confirm this shows
      //                       try {
      //                         final imageUrl = referAd.image;
      //                         final response = await http.get(Uri.parse(imageUrl));
      //
      //                         if (response.statusCode == 200) {
      //                           final bytes = response.bodyBytes;
      //                           final tempDir = await getTemporaryDirectory();
      //                           // final file = await File('${tempDir.path}/refer_ad.jpg').writeAsBytes(bytes);
      //                           final file = File('${tempDir.path}/refer_ad.jpg');
      //                           await file.writeAsBytes(bytes);
      //
      //
      //                           final message = '${referAd.title}\n\n${referAd.content}\n\nDownload now: https://www.kleanit.ae';
      //
      //                           final xFile = XFile(file.path);
      //
      //                           log("Sharing file: ${file.path}");
      //                           await Share.shareXFiles(
      //                             [XFile(file.path)],
      //                             text: message,
      //                           );
      //                         } else {
      //                           log("Image download failed with status ${response.statusCode}");
      //                           ScaffoldMessenger.of(context).showSnackBar(
      //                             SnackBar(content: Text("Failed to download image.")),
      //                           );
      //                         }
      //                       } catch (e) {
      //                         print("Share error: $e");
      //                         log("Sharing error: $e");
      //                         ScaffoldMessenger.of(context).showSnackBar(
      //                           SnackBar(content: Text("An error occurred while sharing.")),
      //                         );
      //                       }
      //                     }
      //               ,
      //
      //                     style: ElevatedButton.styleFrom(
      //                       backgroundColor: Colors.white,
      //                       foregroundColor: primaryColor,
      //                       padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 10),
      //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      //                     ),
      //                     child: Text('Refer Now', style: TextStyle(
      //                       color: primaryColor, // ✅ Use primaryColor to make text visible
      //                       fontSize: 12,         // Slightly larger font for better readability
      //                     ),),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // );
    }
  }

  Widget _buildSingleReferalAd(BuildContext context, AppReferalAdvertisement referAd) {
    return GestureDetector(
      onTap: () => _shareReferal(context, referAd),
      child: Container(
        height: 184,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: NetworkImage(referAd.image), fit: BoxFit.cover)),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.black.withOpacity(0.6), Colors.transparent]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  height: 120,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(referAd.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        // Text(
                        //   referAd.content,
                        //   style: const TextStyle(
                        //     color: Colors.white,
                        //     fontSize: 16,
                        //   ),
                        // ),
                        Text(referAd.content, overflow: TextOverflow.ellipsis, maxLines: 2, style: const TextStyle(color: Colors.white, fontSize: 15)),
                        const SizedBox(height: 10),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     // Handle refer action.
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: Colors.white,
                        //     foregroundColor: primaryColor,
                        //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        //   ),
                        //   child: const Text('Refer Now'),
                        // ),
                        ElevatedButton(
                          onPressed: () async {
                            print("Refer Now pressed"); // <--- Confirm this shows
                            log("Refer Now pressed"); // <--- Confirm this shows

                            print(referAd.title);
                            print(referAd.content);
                            print(referAd.referralAdCode);
                            print(referAd.welcomeNote);
                            log(referAd.title);
                            log(referAd.content);
                            // log(referAd.referralAdCode);
                            // log(referAd.welcomeNote);
                            try {
                              final imageUrl = referAd.image;
                              final response = await http.get(Uri.parse(imageUrl));

                              if (response.statusCode == 200) {
                                final bytes = response.bodyBytes;
                                final tempDir = await getTemporaryDirectory();
                                // final file = await File('${tempDir.path}/refer_ad.jpg').writeAsBytes(bytes);
                                final file = File('${tempDir.path}/refer_ad.jpg');
                                await file.writeAsBytes(bytes);
                                print(referAd.title);
                                print(referAd.content);
                                print(referAd.referralAdCode);
                                print(referAd.welcomeNote);

                                final message =
                                    '${referAd.title}\n\n${referAd.content}\n\n${referAd.welcomeNote}\n${referAd.referralAdCode}\n}\n\nDownload now: https://www.kleanit.ae';

                                final xFile = XFile(file.path);

                                log("Sharing file: ${file.path}");
                                await Share.shareXFiles([XFile(file.path)], text: message);
                              } else {
                                log("Image download failed with status ${response.statusCode}");
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to download image.")));
                              }
                            } catch (e) {
                              print("Share error: $e");
                              log("Sharing error: $e");
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occurred while sharing.")));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            'Refer Now',
                            style: TextStyle(
                              color: primaryColor, // ✅ Use primaryColor to make text visible
                              fontSize: 12, // Slightly larger font for better readability
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _shareReferal(BuildContext context, AppReferalAdvertisement referAd) async {
  try {
    log("Card tapped - sharing referral");

    final response = await http.get(Uri.parse(referAd.image));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/refer_ad.jpg');
      await file.writeAsBytes(bytes);

      final message = '${referAd.title}\n\n${referAd.content}\n\nDownload now: https://www.kleanit.ae';

      await SocialSharingPlus.shareToSocialMedia(
        SocialPlatform.whatsapp, // or instagram, facebook, etc.
        message,
        media: file.path,
        isOpenBrowser: true,
        onAppNotInstalled: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("App not installed.")));
        },
      );
    } else {
      log("Image download failed: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to download image.")));
    }
  } catch (e) {
    log("Sharing error: $e");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("An error occurred while sharing.")));
  }
}

class ShimmerReferalAdvertisementLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 184,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white)),
      ),
    );
  }
}
