import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../routes/app_routes..dart';
import '../Advertisement/model/advertisement_model.dart';
import '../SubAdvertisement/model/sub_advertisement_model.dart';

class SubAdvertisementList extends StatelessWidget {
  final List<SubAdvertisement> subAds;
  final void Function(SubAdvertisement) onBookTap;
  SubAdvertisementList({
    required this.subAds,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subAds.length,
        itemBuilder: (context, index) {
          final ad = subAds[index];
          return GestureDetector(
            onTap: () {
              onBookTap(ad);
              // Navigator.pushNamed(
              //   context,
              //   Routes.categoryDetail,
              //   arguments: {"main_category_id": ad.mainCategoryId ?? 2, "type": "single" ,"category": ad},
              //
              //   // arguments: {
              //   //   "main_category_id": ad.mainCategoryId ?? 1,  // ✅ If null pass 1
              //   //   "first_category_id": ad.firstCategoryId,
              //   //   "second_category_id": ad.secondCategoryId,
              //   //   "third_category_id": ad.thirdCategoryId,
              //   //   "ad_name": ad.name,
              //   //   "encrypted_id": ad.encryptedId,
              //   },
              // );
            },
            child: Container(
              width: 160,
              margin: EdgeInsets.only(
                  left: index == 0 ? 10 : 0, right: 15, bottom: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: Hero(
                          tag: '${ad.image}${ad.id}',
                          child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.darken,
                              child:
                                  // Image.network(
                                  //   ad.image,
                                  //   width: double.infinity,
                                  //   height: 130,
                                  //   fit: BoxFit.cover,
                                  // ),
                                  Image.network(
                                ad.image ??
                                    "https://via.placeholder.com/160x130?text=No+Image",
                                width: double.infinity,
                                height: 130,
                                fit: BoxFit.cover,
                              )),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ad.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: Colors.black87,
                          ),
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

class ShimmerSubAdvertisementLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: EdgeInsets.only(
                left: index == 0 ? 10 : 0, right: 15, bottom: 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 130,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 16,
                      width: 120,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
