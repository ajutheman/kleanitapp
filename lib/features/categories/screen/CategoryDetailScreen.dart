import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kleanitapp/features/cart/model/cart.dart';
import 'package:kleanitapp/features/categories/modle/category_model.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/color_data.dart';
import '../../cart/bloc/cart_bloc.dart';
import '../../cart/bloc/cart_event.dart';
import '../../cart/bloc/cart_state.dart';
import '../../home/ReviewSection.dart';
import '../../home/home_main.dart';
import '../../order/presentation/order_screen.dart';
import '../bloc/categorydetails/category_detail_bloc.dart';
import '../modle/category_detail_model.dart';
import '../respository/category_detail_repository.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String type;
  final MainCategory category;

  const CategoryDetailScreen({Key? key, required this.type, required this.category}) : super(key: key);

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> sectionKeys = {};

  @override
  void initState() {
    super.initState();
  }

  loadKeys(List<FirstCategory> categorys) {
    for (var service in categorys) {
      sectionKeys[service.id] = GlobalKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: primaryColor), onPressed: () => Navigator.pop(context)),
        title: Text(widget.category.name, style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),

        // actions: [
        // IconButton(
        //   icon: const Icon(Icons.search, color: Colors.black),
        //   onPressed: () {},
        // ),
        // IconButton(
        //   icon: const Icon(Icons.share, color: Colors.black),
        //   onPressed: () {},
        // ),
        // ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartActionLoading) {
            showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
          } else if (state is CartAddActionSuccess) {
            Navigator.of(context).pop(); // Close the dialog

            // if press booking direct will go order screen otherwise stay this screen and show success snackbar
            if (state.isDirectBooking) {
              _gotoBookScreen(context, state.cartThirdId);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to cart successfully!'), action: SnackBarAction(label: 'View', onPressed: _gotoCartScreen)));
            }
          } else if (state is CartError) {
            Navigator.of(context).pop(); // Close the dialog
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, cartState) {
          List<Cart> carts = [];
          if (cartState is CartLoaded) carts = cartState.cartItems;
          return BlocProvider<CategoryDetailBloc>(
            create: (context) => CategoryDetailBloc(repository: CategoryDetailRepository(), mainCategoryId: widget.category.id, type: widget.type)..add(LoadCategoryDetail()),
            child: BlocBuilder<CategoryDetailBloc, CategoryDetailState>(
              builder: (context, state) {
                if (state is CategoryDetailLoading) {
                  return Center(child: SpinKitCircle(color: primaryColor));
                } else if (state is CategoryDetailError) {
                  return Center(child: Text("Error: ${state.error}"));
                } else if (state is CategoryDetailLoaded) {
                  final detail = state.detail;
                  loadKeys(detail.firstCategories);
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.category.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Row(
                                children: [Icon(Icons.star, color: Colors.black, size: 16), SizedBox(width: 4), Text('4.7 (1.2 K bookings)', style: TextStyle(fontSize: 14))],
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: const EdgeInsets.only(top: 8, bottom: 20), child: Divider(thickness: 7, color: Colors.grey.shade200)),
                        _buildCategoryGrid(detail.firstCategories),
                        Padding(padding: const EdgeInsets.only(top: 10, bottom: 15), child: Divider(thickness: 7, color: Colors.grey.shade200)),
                        _buildItems(detail.firstCategories, carts: carts),
                        Padding(padding: const EdgeInsets.only(bottom: 15), child: Divider(thickness: 7, color: Colors.grey.shade200)),
                        // WriteReviewSection(secondCatId: 2),
                        // const SizedBox(height: 24),
                        // ReviewSection(secondCatId: 2),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is! CartLoaded || state.cartItems.isEmpty) return SizedBox();
          return FloatingActionButton(onPressed: _gotoCartScreen, foregroundColor: Colors.white, backgroundColor: primaryColor, child: Icon(Icons.card_travel));
        },
      ),
    );
  }

  Widget _buildCategoryGrid(List<FirstCategory> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.1),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryItem(category: categories[index]);
      },
    );
  }

  Widget _buildCategoryItem({required FirstCategory category}) {
    return GestureDetector(
      onTap: () {
        _scrollToSection(category.id);
      },
      child: Column(
        children: [
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(category.image, fit: BoxFit.cover))),
          const SizedBox(height: 8),
          SizedBox(height: 40, child: Text(category.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildItems(List<FirstCategory> categories, {required List<Cart> carts}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      // primary: false,
      itemCount: categories.length,
      itemBuilder: (ctx, index) {
        return _buildApartmentList(categories[index], carts);
      },
      separatorBuilder: (ctx, index) {
        return Padding(padding: const EdgeInsets.only(bottom: 15), child: Divider(thickness: 7, color: Colors.grey.shade200));
      },
    );
  }

  Widget _buildApartmentList(FirstCategory category, List<Cart> carts) {
    return KeyedSubtree(
      key: sectionKeys[category.id],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(left: 20), child: Text(category.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: category.secondCategories.length,
            separatorBuilder: (ctx, index) {
              return Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Divider(color: Colors.grey.shade200));
            },
            itemBuilder: (ctx, index) {
              final apartment = category.secondCategories[index];
              if (apartment.thirdCategories.isEmpty) return SizedBox();
              return _buildApartmentCard(context, apartment, carts);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApartmentCard(BuildContext context, SecondCategory category, List<Cart> carts) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Stack(
                  children: [
                    Image.network(category.image, height: 200, width: double.infinity, fit: BoxFit.cover),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber[600]),
                            const SizedBox(width: 4),
                            Text('4.3', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(' (8k Reviews)', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Content Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                      // Details Section
                      ...category.thirdCategories.map<Widget>((thirdCat) {
                        bool isCarted = carts.any((e) => e.thirdCategory.id == thirdCat.id);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(thirdCat.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                    child: Row(
                                      children: [
                                        Text('From ', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                        Image.asset(
                                          "assets/icon/aed_symbol.png",
                                          width: 12,
                                          height: 12,
                                          fit: BoxFit.contain,
                                          // color: primaryColor, // optional if you want it tinted
                                        ),
                                        const SizedBox(width: 4),
                                        Text(' ${thirdCat.price}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Details Section
                              ...thirdCat.materials.map<Widget>(
                                (material) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(material.name, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4))),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 5),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => _viewDetailsBottomSheet(thirdCat, category, isCarted),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        backgroundColor: Colors.grey[100],
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('View', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      // onPressed: () => _addToCart(context),
                                      onPressed: () => _showPriceOrViewToCart(context, thirdCat, isCarted, isDirectBooking: false),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Text(isCarted ? 'View Cart' : 'Add to Cart', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToSection(int id) {
    final key = sectionKeys[id];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(key!.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void _showPriceOrViewToCart(BuildContext context, ThirdCategory thirdCat, bool isCarted, {required bool isDirectBooking}) {
    if (!isCarted) {
      if (widget.type == SubscriptionType.SINGLE) {
        _showPriceDetailsBottomSheetSingle(context, thirdCat, isDirectBooking: isDirectBooking);
      } else {
        _showPriceDetailsBottomSheetSubscription(context, thirdCat, isDirectBooking: isDirectBooking);
      }
    } else {
      _gotoCartScreen();
    }
  }

  // void _addToCart({required int thirdCategoryId, required String type, int? subscriptionFrequency, required bool isDirectBooking}) {
  //   context.read<CartBloc>().add(
  //         AddToCart(
  //           thirdCategoryId: thirdCategoryId,
  //           // Employee count not defined
  //           employeeCount: 1,
  //           type: type,
  //           subscriptionFrequency: subscriptionFrequency ?? 0,
  //           isDirectBooking: isDirectBooking,
  //         ),
  //       );
  //
  //   // Close bottom sheet
  //   Navigator.pop(context);
  // }
  void _addToCart({required int thirdCategoryId, required String type, int? subscriptionFrequency, required bool isDirectBooking}) {
    // Validate parameters and ensure non-null
    int safeFrequency;

    if (type == SubscriptionType.SUBSCRIPTION) {
      if (subscriptionFrequency == null || subscriptionFrequency <= 0) {
        throw ArgumentError('subscriptionFrequency must be provided and >0 when type is subscription.');
      }
      safeFrequency = subscriptionFrequency;
    } else {
      safeFrequency = 0; // force 0 for single purchases
    }

    context.read<CartBloc>().add(
      AddToCart(
        thirdCategoryId: thirdCategoryId,
        employeeCount: 1,
        type: type,
        subscriptionFrequency: safeFrequency,
        // now always int, never null
        isDirectBooking: isDirectBooking,
      ),
    );

    Navigator.pop(context);
  }

  // void _showPriceDetailsBottomSheetSubscription(BuildContext context, ThirdCategory thirdCategory, {required bool isDirectBooking}) {
  //   // Example pricing data for different rental periods
  //   // final pricingData = [
  //   //   {'weeks': 1, 'price': thirdCategory.oneInWeekPrice},
  //   //   {'weeks': 2, 'price': thirdCategory.twoInWeekPrice},
  //   //   {'weeks': 3, 'price': thirdCategory.threeInWeekPrice},
  //   //   {'weeks': 4, 'price': thirdCategory.fourInWeekPrice},
  //   //   {'weeks': 5, 'price': thirdCategory.fiveInWeekPrice},
  //   //   {'weeks': 6, 'price': thirdCategory.sixInWeekPrice},
  //   // ];
  //
  //   final pricingData = <Map<String, dynamic>>[
  //     if (thirdCategory.oneInWeekPrice != null)
  //       {'label': '1 time per week', 'frequency': 1, 'price': thirdCategory.oneInWeekPrice},
  //     if (thirdCategory.twoInWeekPrice != null)
  //       {'label': '2 times per week', 'frequency': 2, 'price': thirdCategory.twoInWeekPrice},
  //     if (thirdCategory.threeInWeekPrice != null)
  //       {'label': '3 times per week', 'frequency': 3, 'price': thirdCategory.threeInWeekPrice},
  //     if (thirdCategory.fourInWeekPrice != null)
  //       {'label': '4 times per week', 'frequency': 4, 'price': thirdCategory.fourInWeekPrice},
  //     if (thirdCategory.fiveInWeekPrice != null)
  //       {'label': '5 times per week', 'frequency': 5, 'price': thirdCategory.fiveInWeekPrice},
  //     if (thirdCategory.sixInWeekPrice != null)
  //       {'label': '6 times per week', 'frequency': 6, 'price': thirdCategory.sixInWeekPrice},
  //     if (thirdCategory.onceInMonthPrice != null)
  //       {'label': 'Once per month', 'frequency': 7, 'price': thirdCategory.onceInMonthPrice},
  //     if (thirdCategory.twiceInMonthPrice != null)
  //       {'label': 'Twice per month', 'frequency': 8, 'price': thirdCategory.twiceInMonthPrice},
  //     if (thirdCategory.thriceInMonthPrice != null)
  //       {'label': 'Three times per month', 'frequency': 9, 'price': thirdCategory.thriceInMonthPrice},
  //   ];
  //
  //   double firstWeekPrice = double.tryParse(thirdCategory.oneInWeekPrice.toString()) ?? 0;
  //
  //   // State for selected pricing option
  //   int selectedPricingIndex = 0;
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => StatefulBuilder(
  //       builder: (context, setState) => Container(
  //         height: MediaQuery.of(context).size.height * 0.7,
  //         padding: const EdgeInsets.only(top: 16),
  //         decoration: const BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(24),
  //             topRight: Radius.circular(24),
  //           ),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Bottom sheet header with decoration
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 16),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // Drag indicator
  //                   Center(
  //                     child: Container(
  //                       width: 40,
  //                       height: 4,
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey[300],
  //                         borderRadius: BorderRadius.circular(2),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 16),
  //
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         'Price Details',
  //                         style: const TextStyle(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       IconButton(
  //                         icon: Icon(Icons.close, color: Colors.grey[700]),
  //                         onPressed: () => Navigator.pop(context),
  //                       ),
  //                     ],
  //                   ),
  //
  //                   // Item name and description with shadow divider
  //                   Text(
  //                     thirdCategory.name,
  //                     style: TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w500,
  //                       color: Colors.grey[800],
  //                     ),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     'Select your preferred rental period',
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       color: Colors.grey[600],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //
  //             const SizedBox(height: 16),
  //             Container(
  //               height: 8,
  //               color: Colors.grey[50],
  //             ),
  //             const SizedBox(height: 16),
  //
  //             // Pricing options list - scrollable
  //             Expanded(
  //               child: ListView(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16),
  //                 children: [
  //                   // Title for pricing options
  //                   Text(
  //                     'Available Rental Periods',
  //                     style: TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.grey[800],
  //                     ),
  //                   ),
  //                   const SizedBox(height: 16),
  //
  //                   // Selectable pricing options
  //                   ...pricingData.asMap().entries.map((entry) {
  //                     final index = entry.key;
  //                     final isSelected = index == selectedPricingIndex;
  //
  //                     // int week = int.tryParse(entry.value['weeks'].toString()) ?? 0;
  //                     // double amount = double.tryParse(entry.value['price'].toString()) ?? 0;
  //                     //
  //                     // int savePercentage = ((((firstWeekPrice * week) / (amount * week)) * 100) - 100).toInt();
  //
  //                     final label = entry.value['label'];
  //                     final price = double.tryParse(entry.value['price'].toString()) ?? 0;
  //
  //                     return Padding(
  //                       padding: const EdgeInsets.only(bottom: 12),
  //                       child: InkWell(
  //                         onTap: () {
  //                           setState(() {
  //                             selectedPricingIndex = index;
  //                           });
  //                         },
  //                         borderRadius: BorderRadius.circular(12),
  //                         child: Container(
  //                           padding: const EdgeInsets.all(16),
  //                           decoration: BoxDecoration(
  //                             color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
  //                             borderRadius: BorderRadius.circular(12),
  //                             border: Border.all(
  //                               color: isSelected ? primaryColor : Colors.grey[300]!,
  //                               width: isSelected ? 2 : 1,
  //                             ),
  //                             boxShadow: isSelected
  //                                 ? [
  //                                     BoxShadow(
  //                                       color: primaryColor.withOpacity(0.2),
  //                                       blurRadius: 8,
  //                                       offset: const Offset(0, 4),
  //                                     )
  //                                   ]
  //                                 : null,
  //                           ),
  //                           child: Row(
  //                             children: [
  //                               // Radio button
  //                               Container(
  //                                 width: 24,
  //                                 height: 24,
  //                                 decoration: BoxDecoration(
  //                                   shape: BoxShape.circle,
  //                                   border: Border.all(
  //                                     color: isSelected ? primaryColor : Colors.grey[400]!,
  //                                     width: 2,
  //                                   ),
  //                                 ),
  //                                 child: Center(
  //                                   child: isSelected
  //                                       ? Container(
  //                                           width: 12,
  //                                           height: 12,
  //                                           decoration: BoxDecoration(
  //                                             shape: BoxShape.circle,
  //                                             color: primaryColor,
  //                                           ),
  //                                         )
  //                                       : null,
  //                                 ),
  //                               ),
  //                               const SizedBox(width: 16),
  //
  //                               // Pricing details
  //                               Expanded(
  //                                 child: Column(
  //                                   crossAxisAlignment: CrossAxisAlignment.start,
  //                                   children: [
  //                                     // // Text(
  //                                     // //   // '$week ${week == 1 ? 'week' : 'weeks'}',
  //                                     // //   // '$week in a week',
  //                                     // //   label,
  //                                     // //   style: TextStyle(
  //                                     // //     fontSize: 16,
  //                                     // //     fontWeight: FontWeight.w600,
  //                                     // //     color: isSelected ? primaryColor : Colors.grey[800],
  //                                     // //   ),
  //                                     // // ),
  //                                     // // if (week > 1)
  //                                     // //   Text(
  //                                     // //     'Save ${savePercentage}% compared to weekly rate \n per session',
  //                                     // //     style: TextStyle(
  //                                     // //       fontSize: 13,
  //                                     // //       color: isSelected ? primaryColor : Colors.grey[600],
  //                                     // //     ),
  //                                     // //   ),
  //                                     // // Label
  //                                     // Text(
  //                                     //   label,
  //                                     //   style: TextStyle(
  //                                     //     fontSize: 16,
  //                                     //     fontWeight: FontWeight.w600,
  //                                     //     color: isSelected ? primaryColor : Colors.grey[800],
  //                                     //   ),
  //                                     // ),
  //                                     //
  //                                     // // Price
  //                                     // Text(
  //                                     //   'AED ${price.toInt()}',
  //                                     //   style: TextStyle(
  //                                     //     fontSize: 18,
  //                                     //     fontWeight: FontWeight.bold,
  //                                     //     color: isSelected ? primaryColor : Colors.grey[800],
  //                                     //   ),
  //                                     // ),
  //                                     Row(
  //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                                       children: [
  //                                         Flexible(
  //                                           child: Text(
  //                                             label,
  //                                             style: TextStyle(
  //                                               fontSize: 16,
  //                                               fontWeight: FontWeight.w600,
  //                                               color: isSelected ? primaryColor : Colors.grey[800],
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         Text(
  //                                           'AED ${price.toInt()}',
  //                                           style: TextStyle(
  //                                             fontSize: 18,
  //                                             fontWeight: FontWeight.bold,
  //                                             color: isSelected ? primaryColor : Colors.grey[800],
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //
  //                                   ],
  //                                 ),
  //                               ),
  //
  //                               // Price
  //                               // Text(
  //                               //   'AED ${amount.toInt()}',
  //                               //   style: TextStyle(
  //                               //     fontSize: 18,
  //                               //     fontWeight: FontWeight.bold,
  //                               //     color: isSelected ? primaryColor : Colors.grey[800],
  //                               //   ),
  //                               // ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     );
  //                   }).toList(),
  //
  //                   // Additional information
  //                   Container(
  //                     margin: const EdgeInsets.symmetric(vertical: 16),
  //                     padding: const EdgeInsets.all(16),
  //                     decoration: BoxDecoration(
  //                       color: Colors.blue[50],
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(color: Colors.blue[100]!),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
  //                         const SizedBox(width: 12),
  //                         Expanded(
  //                           child: Text(
  //                             'Longer rental periods offer better value with significant discounts.',
  //                             style: TextStyle(
  //                               color: Colors.blue[700],
  //                               fontSize: 14,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //
  //             // Bottom action area with total and button
  //             Container(
  //               padding: const EdgeInsets.all(16),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.grey[200]!,
  //                     blurRadius: 10,
  //                     offset: const Offset(0, -4),
  //                   ),
  //                 ],
  //               ),
  //               child: Column(
  //                 children: [
  //                   // Total amount
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         'Total Amount:',
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w500,
  //                           color: Colors.grey[800],
  //                         ),
  //                       ),
  //                       Text(
  //                         'AED ${(double.tryParse(pricingData[selectedPricingIndex]['price'].toString()) ?? 0).toInt()}',
  //                         style: TextStyle(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.bold,
  //                           color: primaryColor,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 16),
  //
  //                   // Action button
  //                   ElevatedButton(
  //                     onPressed: () => _addToCart(
  //                       thirdCategoryId: thirdCategory.id,
  //                       type: widget.type,
  //                       subscriptionFrequency: (double.tryParse(pricingData[selectedPricingIndex]['weeks'].toString()) ?? 0).toInt(),
  //                       isDirectBooking: isDirectBooking,
  //                     ),
  //                     style: ElevatedButton.styleFrom(
  //                       elevation: 0,
  //                       padding: const EdgeInsets.symmetric(vertical: 16),
  //                       backgroundColor: primaryColor,
  //                       foregroundColor: Colors.white,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       minimumSize: const Size(double.infinity, 50),
  //                     ),
  //                     child: const Text(
  //                       'Add to Cart',
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _showPriceDetailsBottomSheetSubscription(BuildContext context, ThirdCategory thirdCategory, {required bool isDirectBooking}) {
    final pricingData = <Map<String, dynamic>>[
      if (thirdCategory.oneInWeekPrice != null) {'label': '1 time per week', 'frequency': 1, 'price': thirdCategory.oneInWeekPrice},
      if (thirdCategory.twoInWeekPrice != null) {'label': '2 times per week', 'frequency': 2, 'price': thirdCategory.twoInWeekPrice},
      if (thirdCategory.threeInWeekPrice != null) {'label': '3 times per week', 'frequency': 3, 'price': thirdCategory.threeInWeekPrice},
      if (thirdCategory.fourInWeekPrice != null) {'label': '4 times per week', 'frequency': 4, 'price': thirdCategory.fourInWeekPrice},
      if (thirdCategory.fiveInWeekPrice != null) {'label': '5 times per week', 'frequency': 5, 'price': thirdCategory.fiveInWeekPrice},
      if (thirdCategory.sixInWeekPrice != null) {'label': '6 times per week', 'frequency': 6, 'price': thirdCategory.sixInWeekPrice},

      // if (thirdCategory.onceInMonthPrice != null)
      //   {'label': 'Once per month', 'frequency': 1, 'price': thirdCategory.onceInMonthPrice},
      // if (thirdCategory.twiceInMonthPrice != null)
      //   {'label': 'Twice per month', 'frequency': 1, 'price': thirdCategory.twiceInMonthPrice},
      // if (thirdCategory.thriceInMonthPrice != null)
      //   {'label': 'Three times per month', 'frequency': 1, 'price': thirdCategory.thriceInMonthPrice},
      if (thirdCategory.onceInMonthPrice != null) {'label': 'Once per month', 'frequency': 7, 'price': thirdCategory.onceInMonthPrice},
      if (thirdCategory.twiceInMonthPrice != null) {'label': 'Twice per month', 'frequency': 8, 'price': thirdCategory.twiceInMonthPrice},
      if (thirdCategory.thriceInMonthPrice != null) {'label': 'Three times per month', 'frequency': 9, 'price': thirdCategory.thriceInMonthPrice},
    ];

    int selectedPricingIndex = -1;
    int customMonthFrequency = 1;
    int employeeCount = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  padding: const EdgeInsets.only(top: 16),
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag indicator
                      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('    Price Details', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              IconButton(icon: Icon(Icons.close, color: Colors.grey[700]), onPressed: () => Navigator.pop(context)),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(thirdCategory.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[800])),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Item name and description with shadow divider
                      const SizedBox(height: 4),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('Select your preferred rental period', style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
                      // Header
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       const Text(
                      //         'Select Frequency & Employees',
                      //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      //       ),
                      //       IconButton(
                      //         icon: const Icon(Icons.close),
                      //         onPressed: () => Navigator.pop(context),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const Divider(),
                      Container(height: 8, color: Colors.grey[50]),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            const Text('Available Rental Periods', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 12),
                            ...pricingData.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final isSelected = index == selectedPricingIndex;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedPricingIndex = index;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
                                      border: Border.all(color: isSelected ? primaryColor : Colors.grey[300]!, width: isSelected ? 2 : 1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? primaryColor : Colors.grey[400]!, width: 2)),
                                              child: Center(
                                                child: isSelected ? Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor)) : null,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(item['label'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? primaryColor : Colors.black)),
                                                  if ((item['frequency'] as int) > 1)
                                                    Text(
                                                      'Save ${_calculateSavePercentage(pricingData, item)}% compared to weekly rate \nper session',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        // fontWeight: FontWeight.bold,
                                                        color: isSelected ? primaryColor : Colors.grey[600],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            // Text(
                                            //     'AED ${double.tryParse(item['price'].toString())?.toInt() ?? 0}',
                                            //     style: TextStyle(
                                            //         fontSize: 18,
                                            //         fontWeight: FontWeight.bold,
                                            //         color: isSelected
                                            //             ? primaryColor
                                            //             : Colors.black)),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                  "assets/icon/aed_symbol.png",
                                                  width: 16,
                                                  height: 16,
                                                  fit: BoxFit.contain,
                                                  // color: isSelected ? primaryColor : Colors.black, // optional tint
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${double.tryParse(item['price'].toString())?.toInt() ?? 0}',
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? primaryColor : Colors.black),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                          ],
                                        ),

                                        // Row(
                                        //   children: [
                                        //     if ((item['frequency'] as int) > 1)
                                        //     Text(
                                        //       'Save ${_calculateSavePercentage(pricingData, item)}% compared to weekly rate \nper session',
                                        //       style: TextStyle(
                                        //         fontSize: 13,
                                        //                                   // fontWeight: FontWeight.bold,
                                        //                                   color:  isSelected ? primaryColor : Colors.grey[600],
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue[100]!)),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text('Longer rental periods offer better value with significant discounts.', style: TextStyle(color: Colors.blue[700], fontSize: 14)),
                                  ),
                                ],
                              ),
                            ),
                            // const Divider(),
                            // const SizedBox(height: 8),
                            // const Text('Or select custom month frequency:',
                            //     style: TextStyle(fontWeight: FontWeight.w500)),
                            // const SizedBox(height: 8),
                            // Container(
                            //   decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.grey[300]!),
                            //     borderRadius: BorderRadius.circular(12),
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       IconButton(
                            //         icon: const Icon(Icons.remove_circle_outline),
                            //         color: Colors.red,
                            //         onPressed: () {
                            //           setState(() {
                            //             if (customMonthFrequency > 1) customMonthFrequency--;
                            //             selectedPricingIndex = -1;
                            //           });
                            //         },
                            //       ),
                            //       Expanded(
                            //         child: Center(
                            //           child: Text(
                            //             '$customMonthFrequency Month${customMonthFrequency > 1 ? 's' : ''}',
                            //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            //           ),
                            //         ),
                            //       ),
                            //       IconButton(
                            //         icon: const Icon(Icons.add_circle_outline),
                            //         color: Colors.green,
                            //         onPressed: () {
                            //           setState(() {
                            //             if (customMonthFrequency < 6) customMonthFrequency++;
                            //             selectedPricingIndex = -1;
                            //           });
                            //         },
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // const SizedBox(height: 20),
                            // const Text('Employee Count:', style: TextStyle(fontWeight: FontWeight.w500)),
                            // const SizedBox(height: 8),
                            // Container(
                            //   decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.grey[300]!),
                            //     borderRadius: BorderRadius.circular(12),
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       IconButton(
                            //         icon: const Icon(Icons.remove_circle_outline),
                            //         color: Colors.red,
                            //         onPressed: () {
                            //           setState(() {
                            //             if (employeeCount > 1) employeeCount--;
                            //           });
                            //         },
                            //       ),
                            //       Expanded(
                            //         child: Center(
                            //           child: Text(
                            //             '$employeeCount Employee${employeeCount > 1 ? 's' : ''}',
                            //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            //           ),
                            //         ),
                            //       ),
                            //       IconButton(
                            //         icon: const Icon(Icons.add_circle_outline),
                            //         color: Colors.green,
                            //         onPressed: () {
                            //           setState(() {
                            //             if (employeeCount < 4) employeeCount++;
                            //           });
                            //         },
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // // Total amount
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text(
                            //       'Total Amount:',
                            //       style: TextStyle(
                            //         fontSize: 16,
                            //         fontWeight: FontWeight.w500,
                            //         color: Colors.grey[800],
                            //       ),
                            //     ),
                            //     Text(
                            //       selectedPricingIndex >= 0
                            //           ? 'AED ${(double.tryParse(pricingData[selectedPricingIndex]['price'].toString()) ?? 0).toInt()}'
                            //           : 'Select frequency',
                            //       style: TextStyle(
                            //         fontSize: 20,
                            //         fontWeight: FontWeight.bold,
                            //         color: primaryColor,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800])),
                                selectedPricingIndex >= 0
                                    ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/icon/aed_symbol.png',
                                          width: 16,
                                          height: 16,
                                          fit: BoxFit.contain,
                                          // color: primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${(double.tryParse(pricingData[selectedPricingIndex]['price'].toString()) ?? 0).toInt()}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            // color: primaryColor,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Text('Select frequency', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                              ],
                            ),

                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                int frequency;
                                if (selectedPricingIndex >= 0) {
                                  frequency = pricingData[selectedPricingIndex]['frequency'] as int;
                                } else {
                                  frequency = customMonthFrequency;
                                }
                                if (frequency <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a frequency.')));
                                  return;
                                }

                                context.read<CartBloc>().add(
                                  AddToCart(
                                    thirdCategoryId: thirdCategory.id,
                                    employeeCount: employeeCount,
                                    type: widget.type,
                                    subscriptionFrequency: frequency,
                                    isDirectBooking: isDirectBooking,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              style:
                              // ElevatedButton.styleFrom(
                              //   minimumSize: const Size.fromHeight(50),
                              //   backgroundColor: primaryColor,
                              // ),
                              ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  // Simple add-to-cart for a service (first or third category)

  void _showPriceDetailsBottomSheetSingle(BuildContext context, ThirdCategory thirdCategory, {required bool isDirectBooking}) {
    // For single items, we only need the price
    final singlePrice = double.tryParse(thirdCategory.price.toString()) ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7, // Smaller height since fewer options
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bottom sheet header with decoration
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag indicator
                      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Price Details', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(icon: Icon(Icons.close, color: Colors.grey[700]), onPressed: () => Navigator.pop(context)),
                        ],
                      ),

                      // Item name and description
                      Text(thirdCategory.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800])),
                      const SizedBox(height: 4),
                      Text('One-time purchase', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Container(height: 8, color: Colors.grey[50]),
                const SizedBox(height: 16),

                // Item details
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Price details container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [BoxShadow(color: Colors.grey[200]!, blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Item Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                            const SizedBox(height: 12),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text(
                            //       'Base Price:',
                            //       style: TextStyle(
                            //         fontSize: 14,
                            //         color: Colors.grey[600],
                            //       ),
                            //     ),
                            //     Text(
                            //       'AED ${singlePrice.toInt()}',
                            //       style: TextStyle(
                            //         fontSize: 16,
                            //         fontWeight: FontWeight.w600,
                            //         color: Colors.grey[800],
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Base Price:', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/icon/aed_symbol.png',
                                      width: 14,
                                      height: 14,
                                      fit: BoxFit.contain,
                                      // color: Colors.grey[800], // matches text color
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${singlePrice.toInt()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                                  ],
                                ),
                              ],
                            ),

                            // You can add more pricing details here if needed
                            // For example, taxes, discounts, etc.
                            const SizedBox(height: 8),
                            Divider(),
                            const SizedBox(height: 8),

                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text(
                            //       'Total:',
                            //       style: TextStyle(
                            //         fontSize: 16,
                            //         fontWeight: FontWeight.bold,
                            //         color: Colors.grey[800],
                            //       ),
                            //     ),
                            //     Text(
                            //       'AED ${singlePrice.toInt()}',
                            //       style: TextStyle(
                            //         fontSize: 18,
                            //         fontWeight: FontWeight.bold,
                            //         color: primaryColor,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/icon/aed_symbol.png',
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.contain,
                                      // color: primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${singlePrice.toInt()}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Additional information
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue[100]!)),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This is a one-time purchase. Consider subscription options for better value on regular needs.',
                                style: TextStyle(color: Colors.blue[700], fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom action area with total and button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey[200]!, blurRadius: 10, offset: const Offset(0, -4))]),
                  child: Column(
                    children: [
                      // // Total amount
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       'Total Amount:',
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.w500,
                      //         color: Colors.grey[800],
                      //       ),
                      //     ),
                      //     Text(
                      //       'AED ${singlePrice.toInt()}',
                      //       style: TextStyle(
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.bold,
                      //         color: primaryColor,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // Total amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800])),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icon/aed_symbol.png',
                                width: 16,
                                height: 16,
                                fit: BoxFit.contain,
                                // color: primaryColor, // Optional: tint to match the theme
                              ),
                              const SizedBox(width: 4),
                              Text('${singlePrice.toInt()}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Action button
                      ElevatedButton(
                        onPressed:
                            () => _addToCart(
                              thirdCategoryId: thirdCategory.id,
                              type: widget.type,
                              subscriptionFrequency: 0, // 0 to indicate single purchase, not subscription
                              isDirectBooking: isDirectBooking,
                            ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _gotoCartScreen() {
    currentHomeIndexNotifier.value = 2;
    Navigator.pop(context);
  }

  void _viewDetailsBottomSheet(ThirdCategory thirdCat, SecondCategory secondCat, bool isCarted) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (_, scrollController) => Container(
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),

                      // Content
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            // Header section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Service Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                              ],
                            ),

                            // Service image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                thirdCat.image, // Replace with actual image URL
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Container(height: 200, color: Colors.grey[200], child: const Center(child: Icon(Icons.image, size: 60, color: Colors.grey))),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Service title and rating
                            Text(
                              thirdCat.name, // Replace with actual service name
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber[600], size: 18),
                                const SizedBox(width: 4),
                                Text('4.3', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(' (324 Reviews)', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Price section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Starting from', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Row(children: [Text('AED ${thirdCat.price}', style: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.bold))]),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryColor)),
                                    child: Text('Best Value', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                            // const SizedBox(height: 24),
                            // // Description section
                            // const Text(
                            //   'Description',
                            //   style: TextStyle(
                            //     fontSize: 18,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // const SizedBox(height: 12),
                            // Text(
                            //   'This service includes a comprehensive cleaning of your space with top-quality products and professional tools. Our experienced team will ensure your satisfaction with attention to detail.',
                            //   style: TextStyle(
                            //     fontSize: 14,
                            //     color: Colors.grey[700],
                            //     height: 1.5,
                            //   ),
                            // ),
                            const SizedBox(height: 24),

                            // What's included section
                            const Text('What\'s Included', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ...thirdCat.materials.map<Widget>((material) => _buildServiceItem(material.name, material.comment)),
                            const SizedBox(height: 24),

                            ReviewSection(secondCatId: secondCat.id),
                          ],
                        ),
                      ),

                      // Fixed bottom buttons
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, -4))],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showPriceOrViewToCart(context, thirdCat, isCarted, isDirectBooking: false);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: primaryColor),
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(isCarted ? 'View Cart' : 'Add to Cart', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (isCarted) {
                                    _gotoBookScreen(context, thirdCat.id);
                                  } else {
                                    _showPriceOrViewToCart(context, thirdCat, isCarted, isDirectBooking: true);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  // Widget _buildServiceItem(String text,String? comment) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 8),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Icon(Icons.check_circle, color: primaryColor, size: 20),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 // "text ${text}",
  //                 text,
  //                 style: TextStyle(
  //                   fontSize: 15,
  //                   color: Colors.grey[700], fontWeight: FontWeight.w600,
  //                   height: 1.5,
  //                 ),
  //               ),
  //               if (comment != null && comment.isNotEmpty)
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 2),
  //                   child: Text(
  //                     comment,
  //                     style: TextStyle(
  //                       fontSize: 13,
  //                       color: Colors.grey[600],
  //                       height: 1.4,
  //                     ),
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildServiceItem(String name, String? comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFF19D4D4).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Color(0xFF19D4D4).withOpacity(0.08), blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E3A47), // matches dark tone
                letterSpacing: 0.3,
              ),
            ),
            if (comment != null && comment.trim().isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 6), child: Text(comment, style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600, height: 1.5))),
          ],
        ),
      ),
    );
  }
}

int _calculateSavePercentage(List<Map<String, dynamic>> pricingData, Map<String, dynamic> item) {
  try {
    final oneWeek = pricingData.firstWhere((e) => e['frequency'] == 1);
    final oneWeekPrice = double.tryParse(oneWeek['price'].toString()) ?? 0;
    final multiPrice = double.tryParse(item['price'].toString()) ?? 0;

    if (oneWeekPrice <= 0 || multiPrice <= 0) return 0;

    // Directly compare per-week prices
    final savings = ((1 - (multiPrice / oneWeekPrice)) * 100).round();
    return savings > 0 ? savings : 0;
  } catch (e) {
    return 0;
  }
}

void _gotoBookScreen(BuildContext context, int cartThirdId) async {
  showDialog(context: context, builder: (_) => Center(child: CircularProgressIndicator()));

  final cartBloc = context.read<CartBloc>();
  cartBloc.add(FetchCartList());

  await for (var state in cartBloc.stream) {
    if (state is CartLoaded) {
      var carts = state.cartItems;
      var cart = carts.firstWhere((e) => e.thirdCategory.id == cartThirdId);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
      } // Close loading dialog

      Navigator.push(context, MaterialPageRoute(builder: (_) => OrderConfirmationScreen(carts: [cart])));
      break;
    }
  }
}

// class ShimmerCategoryDetailLoading extends StatelessWidget {
//   const ShimmerCategoryDetailLoading({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Shimmer.fromColors(
//                 baseColor: Colors.grey[300]!,
//                 highlightColor: Colors.grey[100]!,
//                 child: Container(
//                   width: 150,
//                   height: 24,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Icon(Icons.star, color: Colors.grey[300], size: 16),
//                   const SizedBox(width: 4),
//                   Shimmer.fromColors(
//                     baseColor: Colors.grey[300]!,
//                     highlightColor: Colors.grey[100]!,
//                     child: Container(
//                       width: 100,
//                       height: 14,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 8, bottom: 20),
//           child: Divider(thickness: 7, color: Colors.grey.shade200),
//         ),
//         _buildShimmerGrid(),
//         Padding(
//           padding: const EdgeInsets.only(top: 10, bottom: 15),
//           child: Divider(thickness: 7, color: Colors.grey.shade200),
//         ),
//         _buildShimmerItems(),
//       ],
//     );
//   }
//
//   Widget _buildShimmerGrid() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       child: Shimmer.fromColors(
//         baseColor: Colors.grey[300]!,
//         highlightColor: Colors.grey[100]!,
//         child: GridView.builder(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//             childAspectRatio: 1.5,
//           ),
//           itemCount: 4,
//           itemBuilder: (context, index) {
//             return Container(
//               height: 100,
//               color: Colors.white,
//             );
//           },
//         ),
//       ),
//     );import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:kleanitapp/core/theme/resizer/fetch_pixels.dart';
// import 'package:kleanitapp/features/cart/model/cart.dart';
// import 'package:kleanitapp/features/categories/modle/category_model.dart';
//
// import '../../../core/constants/constants.dart';
// import '../../../core/theme/color_data.dart';
// import '../../cart/bloc/cart_bloc.dart';
// import '../../cart/bloc/cart_event.dart';
// import '../../cart/bloc/cart_state.dart';
// import '../../home/ReviewSection.dart';
// import '../../home/home_main.dart';
// import '../../home/write_review_section.dart';
// import '../../order/presentation/order_screen.dart';
// import '../bloc/categorydetails/category_detail_bloc.dart';
// import '../modle/category_detail_model.dart';
// import '../respository/category_detail_repository.dart';
//
// class CategoryDetailScreen extends StatefulWidget {
//   final String type;
//   final MainCategory category;
//
//   const CategoryDetailScreen({
//     Key? key,
//     required this.type,
//     required this.category,
//   }) : super(key: key);
//
//   @override
//   State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
// }
//
// class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final Map<int, GlobalKey> sectionKeys = {};
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   loadKeys(List<FirstCategory> categorys) {
//     for (var service in categorys) {
//       sectionKeys[service.id] = GlobalKey();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         // backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: primaryColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           widget.category.name,
//           style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
//         ),
//
//         // actions: [
//         // IconButton(
//         //   icon: const Icon(Icons.search, color: Colors.black),
//         //   onPressed: () {},
//         // ),
//         // IconButton(
//         //   icon: const Icon(Icons.share, color: Colors.black),
//         //   onPressed: () {},
//         // ),
//         // ],
//       ),
//       body: BlocConsumer<CartBloc, CartState>(
//         listener: (context, state) {
//           if (state is CartActionLoading) {
//             showDialog(
//               context: context,
//               barrierDismissible: false,
//               builder: (context) => const Center(child: CircularProgressIndicator()),
//             );
//           } else if (state is CartAddActionSuccess) {
//             Navigator.of(context).pop(); // Close the dialog
//
//             // if press booking direct will go order screen otherwise stay this screen and show success snackbar
//             if (state.isDirectBooking) {
//               _gotoBookScreen(context, state.cartThirdId);
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: Text('Added to cart successfully!'),
//                 action: SnackBarAction(
//                   label: 'View',
//                   onPressed: _gotoCartScreen,
//                 ),
//               ));
//             }
//           } else if (state is CartError) {
//             Navigator.of(context).pop(); // Close the dialog
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//           }
//         },
//         builder: (context, cartState) {
//           List<Cart> carts = [];
//           if (cartState is CartLoaded) carts = cartState.cartItems;
//           return BlocProvider<CategoryDetailBloc>(
//             create: (context) => CategoryDetailBloc(
//               repository: CategoryDetailRepository(),
//               mainCategoryId: widget.category.id,
//               type: widget.type,
//             )..add(LoadCategoryDetail()),
//             child: BlocBuilder<CategoryDetailBloc, CategoryDetailState>(
//               builder: (context, state) {
//                 if (state is CategoryDetailLoading) {
//                   return Center(child: SpinKitCircle(color: primaryColor));
//                 } else if (state is CategoryDetailError) {
//                   return Center(child: Text("Error: ${state.error}"));
//                 } else if (state is CategoryDetailLoaded) {
//                   final detail = state.detail;
//                   loadKeys(detail.firstCategories);
//                   return SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(widget.category.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//                               const SizedBox(height: 8),
//                               const Row(
//                                 children: [
//                                   Icon(Icons.star, color: Colors.black, size: 16),
//                                   SizedBox(width: 4),
//                                   Text('4.7 (1.2 K bookings)', style: TextStyle(fontSize: 14))
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(padding: const EdgeInsets.only(top: 8, bottom: 20), child: Divider(thickness: 7, color: Colors.grey.shade200)),
//                         _buildCategoryGrid(detail.firstCategories),
//                         Padding(padding: const EdgeInsets.only(top: 10, bottom: 15), child: Divider(thickness: 7, color: Colors.grey.shade200)),
//                         _buildItems(detail.firstCategories, carts: carts),
//                         Padding(padding: const EdgeInsets.only(bottom: 15), child: Divider(thickness: 7, color: Colors.grey.shade200)),
//                         // WriteReviewSection(secondCatId: 2),
//                         // const SizedBox(height: 24),
//                         // ReviewSection(secondCatId: 2),
//                       ],
//                     ),
//                   );
//                 }
//                 return Container();
//               },
//             ),
//           );
//         },
//       ),
//       floatingActionButton: BlocBuilder<CartBloc, CartState>(builder: (context, state) {
//         if (state is! CartLoaded || state.cartItems.isEmpty) return SizedBox();
//         return FloatingActionButton(
//           onPressed: _gotoCartScreen,
//           foregroundColor: Colors.white,
//           backgroundColor: primaryColor,
//           child: Icon(Icons.card_travel),
//         );
//       }),
//     );
//   }
//
//   Widget _buildCategoryGrid(List<FirstCategory> categories) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//         childAspectRatio: 1.1,
//       ),
//       itemCount: categories.length,
//       itemBuilder: (context, index) {
//         return _buildCategoryItem(category: categories[index]);
//       },
//     );
//   }
//
//   Widget _buildCategoryItem({required FirstCategory category}) {
//     return GestureDetector(
//       onTap: () {
//         _scrollToSection(category.id);
//       },
//       child: Column(
//         children: [
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 category.image,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           SizedBox(
//             height: 40,
//             child: Text(
//               category.name,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItems(List<FirstCategory> categories, {required List<Cart> carts}) {
//     return ListView.separated(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//
//       // primary: false,
//       itemCount: categories.length,
//       itemBuilder: (ctx, index) {
//         return _buildApartmentList(categories[index], carts);
//       },
//       separatorBuilder: (ctx, index) {
//         return Padding(padding: const EdgeInsets.only(bottom: 15), child: Divider(thickness: 7, color: Colors.grey.shade200));
//       },
//     );
//   }
//
//   Widget _buildApartmentList(FirstCategory category, List<Cart> carts) {
//     return KeyedSubtree(
//       key: sectionKeys[category.id],
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 20),
//             child: Text(
//               category.name,
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(8),
//             itemCount: category.secondCategories.length,
//             separatorBuilder: (ctx, index) {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Divider(color: Colors.grey.shade200),
//               );
//             },
//             itemBuilder: (ctx, index) {
//               final apartment = category.secondCategories[index];
//               if (apartment.thirdCategories.isEmpty) return SizedBox();
//               return _buildApartmentCard(context, apartment, carts);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildApartmentCard(BuildContext context, SecondCategory category, List<Cart> carts) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Stack(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Image Section
//                 Stack(
//                   children: [
//                     Image.network(
//                       category.image,
//                       height: 200,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                     Positioned(
//                       top: 16,
//                       right: 16,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.9),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.star, size: 16, color: Colors.amber[600]),
//                             const SizedBox(width: 4),
//                             Text(
//                               '4.3',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             Text(
//                               ' (8k Reviews)',
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 // Content Section
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         category.name,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//
//                       // Details Section
//                       ...category.thirdCategories.map<Widget>(
//                         (thirdCat) {
//                           bool isCarted = carts.any((e) => e.thirdCategory.id == thirdCat.id);
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(height: 20),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         thirdCat.name,
//                                         style: const TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                       decoration: BoxDecoration(
//                                         color: primaryColor.withOpacity(0.1),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Text(
//                                         'From AED ${thirdCat.price}',
//                                         style: TextStyle(
//                                           color: primaryColor,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
//
//                                 // Details Section
//                                 ...thirdCat.materials.map<Widget>((material) => Padding(
//                                       padding: const EdgeInsets.only(bottom: 8),
//                                       child: Row(
//                                         children: [
//                                           Container(
//                                             width: 6,
//                                             height: 6,
//                                             decoration: BoxDecoration(
//                                               color: Colors.grey[400],
//                                               shape: BoxShape.circle,
//                                             ),
//                                           ),
//                                           const SizedBox(width: 12),
//                                           Expanded(
//                                             child: Text(
//                                               material.name,
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.grey[600],
//                                                 height: 1.4,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     )),
//
//                                 const SizedBox(height: 5),
//
//                                 // Action Buttons
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: TextButton(
//                                         onPressed: () => _viewDetailsBottomSheet(thirdCat, category, isCarted),
//                                         style: TextButton.styleFrom(
//                                           padding: const EdgeInsets.symmetric(vertical: 12),
//                                           backgroundColor: Colors.grey[100],
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                         ),
//                                         child: const Text(
//                                           'View',
//                                           style: TextStyle(
//                                             color: Colors.black87,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: ElevatedButton(
//                                         // onPressed: () => _addToCart(context),
//                                         onPressed: () => _showPriceOrViewToCart(context, thirdCat, isCarted, isDirectBooking: false),
//                                         style: ElevatedButton.styleFrom(
//                                           padding: const EdgeInsets.symmetric(vertical: 12),
//                                           backgroundColor: primaryColor,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                         ),
//                                         child: Text(
//                                           isCarted ? 'View Cart' : 'Add to Cart',
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 10),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _scrollToSection(int id) {
//     final key = sectionKeys[id];
//     if (key?.currentContext != null) {
//       Scrollable.ensureVisible(
//         key!.currentContext!,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
//
//   void _showPriceOrViewToCart(BuildContext context, ThirdCategory thirdCat, bool isCarted, {required bool isDirectBooking}) {
//     if (!isCarted) {
//       if (widget.type == SubscriptionType.SINGLE) {
//         _showPriceDetailsBottomSheetSingle(context, thirdCat, isDirectBooking: isDirectBooking);
//       } else {
//         _showPriceDetailsBottomSheetSubscription(context, thirdCat, isDirectBooking: isDirectBooking);
//       }
//     } else {
//       _gotoCartScreen();
//     }
//   }
//
//   // void _addToCart({required int thirdCategoryId, required String type, int? subscriptionFrequency, required bool isDirectBooking}) {
//   //   context.read<CartBloc>().add(
//   //         AddToCart(
//   //           thirdCategoryId: thirdCategoryId,
//   //           // Employee count not defined
//   //           employeeCount: 1,
//   //           type: type,
//   //           subscriptionFrequency: subscriptionFrequency ?? 0,
//   //           isDirectBooking: isDirectBooking,
//   //         ),
//   //       );
//   //
//   //   // Close bottom sheet
//   //   Navigator.pop(context);
//   // }
//   void _addToCart({
//     required int thirdCategoryId,
//     required String type,
//     int? subscriptionFrequency,
//     required bool isDirectBooking,
//   }) {
//     // Validate parameters and ensure non-null
//     int safeFrequency;
//
//     if (type == SubscriptionType.SUBSCRIPTION) {
//       if (subscriptionFrequency == null || subscriptionFrequency <= 0) {
//         throw ArgumentError(
//             'subscriptionFrequency must be provided and >0 when type is subscription.');
//       }
//       safeFrequency = subscriptionFrequency;
//     } else {
//       safeFrequency = 0; // force 0 for single purchases
//     }
//
//     context.read<CartBloc>().add(
//       AddToCart(
//         thirdCategoryId: thirdCategoryId,
//         employeeCount: 1,
//         type: type,
//         subscriptionFrequency: safeFrequency, // now always int, never null
//         isDirectBooking: isDirectBooking,
//       ),
//     );
//
//     Navigator.pop(context);
//   }
//
//
//   // void _showPriceDetailsBottomSheetSubscription(BuildContext context, ThirdCategory thirdCategory, {required bool isDirectBooking}) {
//   //   // Example pricing data for different rental periods
//   //   // final pricingData = [
//   //   //   {'weeks': 1, 'price': thirdCategory.oneInWeekPrice},
//   //   //   {'weeks': 2, 'price': thirdCategory.twoInWeekPrice},
//   //   //   {'weeks': 3, 'price': thirdCategory.threeInWeekPrice},
//   //   //   {'weeks': 4, 'price': thirdCategory.fourInWeekPrice},
//   //   //   {'weeks': 5, 'price': thirdCategory.fiveInWeekPrice},
//   //   //   {'weeks': 6, 'price': thirdCategory.sixInWeekPrice},
//   //   // ];
//   //
//   //   final pricingData = <Map<String, dynamic>>[
//   //     if (thirdCategory.oneInWeekPrice != null)
//   //       {'label': '1 time per week', 'frequency': 1, 'price': thirdCategory.oneInWeekPrice},
//   //     if (thirdCategory.twoInWeekPrice != null)
//   //       {'label': '2 times per week', 'frequency': 2, 'price': thirdCategory.twoInWeekPrice},
//   //     if (thirdCategory.threeInWeekPrice != null)
//   //       {'label': '3 times per week', 'frequency': 3, 'price': thirdCategory.threeInWeekPrice},
//   //     if (thirdCategory.fourInWeekPrice != null)
//   //       {'label': '4 times per week', 'frequency': 4, 'price': thirdCategory.fourInWeekPrice},
//   //     if (thirdCategory.fiveInWeekPrice != null)
//   //       {'label': '5 times per week', 'frequency': 5, 'price': thirdCategory.fiveInWeekPrice},
//   //     if (thirdCategory.sixInWeekPrice != null)
//   //       {'label': '6 times per week', 'frequency': 6, 'price': thirdCategory.sixInWeekPrice},
//   //     if (thirdCategory.onceInMonthPrice != null)
//   //       {'label': 'Once per month', 'frequency': 7, 'price': thirdCategory.onceInMonthPrice},
//   //     if (thirdCategory.twiceInMonthPrice != null)
//   //       {'label': 'Twice per month', 'frequency': 8, 'price': thirdCategory.twiceInMonthPrice},
//   //     if (thirdCategory.thriceInMonthPrice != null)
//   //       {'label': 'Three times per month', 'frequency': 9, 'price': thirdCategory.thriceInMonthPrice},
//   //   ];
//   //
//   //   double firstWeekPrice = double.tryParse(thirdCategory.oneInWeekPrice.toString()) ?? 0;
//   //
//   //   // State for selected pricing option
//   //   int selectedPricingIndex = 0;
//   //
//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     backgroundColor: Colors.transparent,
//   //     builder: (context) => StatefulBuilder(
//   //       builder: (context, setState) => Container(
//   //         height: MediaQuery.of(context).size.height * 0.7,
//   //         padding: const EdgeInsets.only(top: 16),
//   //         decoration: const BoxDecoration(
//   //           color: Colors.white,
//   //           borderRadius: BorderRadius.only(
//   //             topLeft: Radius.circular(24),
//   //             topRight: Radius.circular(24),
//   //           ),
//   //         ),
//   //         child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             // Bottom sheet header with decoration
//   //             Container(
//   //               padding: const EdgeInsets.symmetric(horizontal: 16),
//   //               child: Column(
//   //                 crossAxisAlignment: CrossAxisAlignment.start,
//   //                 children: [
//   //                   // Drag indicator
//   //                   Center(
//   //                     child: Container(
//   //                       width: 40,
//   //                       height: 4,
//   //                       decoration: BoxDecoration(
//   //                         color: Colors.grey[300],
//   //                         borderRadius: BorderRadius.circular(2),
//   //                       ),
//   //                     ),
//   //                   ),
//   //                   const SizedBox(height: 16),
//   //
//   //                   Row(
//   //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                     children: [
//   //                       Text(
//   //                         'Price Details',
//   //                         style: const TextStyle(
//   //                           fontSize: 20,
//   //                           fontWeight: FontWeight.bold,
//   //                         ),
//   //                       ),
//   //                       IconButton(
//   //                         icon: Icon(Icons.close, color: Colors.grey[700]),
//   //                         onPressed: () => Navigator.pop(context),
//   //                       ),
//   //                     ],
//   //                   ),
//   //
//   //                   // Item name and description with shadow divider
//   //                   Text(
//   //                     thirdCategory.name,
//   //                     style: TextStyle(
//   //                       fontSize: 16,
//   //                       fontWeight: FontWeight.w500,
//   //                       color: Colors.grey[800],
//   //                     ),
//   //                   ),
//   //                   const SizedBox(height: 4),
//   //                   Text(
//   //                     'Select your preferred rental period',
//   //                     style: TextStyle(
//   //                       fontSize: 14,
//   //                       color: Colors.grey[600],
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //
//   //             const SizedBox(height: 16),
//   //             Container(
//   //               height: 8,
//   //               color: Colors.grey[50],
//   //             ),
//   //             const SizedBox(height: 16),
//   //
//   //             // Pricing options list - scrollable
//   //             Expanded(
//   //               child: ListView(
//   //                 padding: const EdgeInsets.symmetric(horizontal: 16),
//   //                 children: [
//   //                   // Title for pricing options
//   //                   Text(
//   //                     'Available Rental Periods',
//   //                     style: TextStyle(
//   //                       fontSize: 16,
//   //                       fontWeight: FontWeight.bold,
//   //                       color: Colors.grey[800],
//   //                     ),
//   //                   ),
//   //                   const SizedBox(height: 16),
//   //
//   //                   // Selectable pricing options
//   //                   ...pricingData.asMap().entries.map((entry) {
//   //                     final index = entry.key;
//   //                     final isSelected = index == selectedPricingIndex;
//   //
//   //                     // int week = int.tryParse(entry.value['weeks'].toString()) ?? 0;
//   //                     // double amount = double.tryParse(entry.value['price'].toString()) ?? 0;
//   //                     //
//   //                     // int savePercentage = ((((firstWeekPrice * week) / (amount * week)) * 100) - 100).toInt();
//   //
//   //                     final label = entry.value['label'];
//   //                     final price = double.tryParse(entry.value['price'].toString()) ?? 0;
//   //
//   //                     return Padding(
//   //                       padding: const EdgeInsets.only(bottom: 12),
//   //                       child: InkWell(
//   //                         onTap: () {
//   //                           setState(() {
//   //                             selectedPricingIndex = index;
//   //                           });
//   //                         },
//   //                         borderRadius: BorderRadius.circular(12),
//   //                         child: Container(
//   //                           padding: const EdgeInsets.all(16),
//   //                           decoration: BoxDecoration(
//   //                             color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
//   //                             borderRadius: BorderRadius.circular(12),
//   //                             border: Border.all(
//   //                               color: isSelected ? primaryColor : Colors.grey[300]!,
//   //                               width: isSelected ? 2 : 1,
//   //                             ),
//   //                             boxShadow: isSelected
//   //                                 ? [
//   //                                     BoxShadow(
//   //                                       color: primaryColor.withOpacity(0.2),
//   //                                       blurRadius: 8,
//   //                                       offset: const Offset(0, 4),
//   //                                     )
//   //                                   ]
//   //                                 : null,
//   //                           ),
//   //                           child: Row(
//   //                             children: [
//   //                               // Radio button
//   //                               Container(
//   //                                 width: 24,
//   //                                 height: 24,
//   //                                 decoration: BoxDecoration(
//   //                                   shape: BoxShape.circle,
//   //                                   border: Border.all(
//   //                                     color: isSelected ? primaryColor : Colors.grey[400]!,
//   //                                     width: 2,
//   //                                   ),
//   //                                 ),
//   //                                 child: Center(
//   //                                   child: isSelected
//   //                                       ? Container(
//   //                                           width: 12,
//   //                                           height: 12,
//   //                                           decoration: BoxDecoration(
//   //                                             shape: BoxShape.circle,
//   //                                             color: primaryColor,
//   //                                           ),
//   //                                         )
//   //                                       : null,
//   //                                 ),
//   //                               ),
//   //                               const SizedBox(width: 16),
//   //
//   //                               // Pricing details
//   //                               Expanded(
//   //                                 child: Column(
//   //                                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                                   children: [
//   //                                     // // Text(
//   //                                     // //   // '$week ${week == 1 ? 'week' : 'weeks'}',
//   //                                     // //   // '$week in a week',
//   //                                     // //   label,
//   //                                     // //   style: TextStyle(
//   //                                     // //     fontSize: 16,
//   //                                     // //     fontWeight: FontWeight.w600,
//   //                                     // //     color: isSelected ? primaryColor : Colors.grey[800],
//   //                                     // //   ),
//   //                                     // // ),
//   //                                     // // if (week > 1)
//   //                                     // //   Text(
//   //                                     // //     'Save ${savePercentage}% compared to weekly rate \n per session',
//   //                                     // //     style: TextStyle(
//   //                                     // //       fontSize: 13,
//   //                                     // //       color: isSelected ? primaryColor : Colors.grey[600],
//   //                                     // //     ),
//   //                                     // //   ),
//   //                                     // // Label
//   //                                     // Text(
//   //                                     //   label,
//   //                                     //   style: TextStyle(
//   //                                     //     fontSize: 16,
//   //                                     //     fontWeight: FontWeight.w600,
//   //                                     //     color: isSelected ? primaryColor : Colors.grey[800],
//   //                                     //   ),
//   //                                     // ),
//   //                                     //
//   //                                     // // Price
//   //                                     // Text(
//   //                                     //   'AED ${price.toInt()}',
//   //                                     //   style: TextStyle(
//   //                                     //     fontSize: 18,
//   //                                     //     fontWeight: FontWeight.bold,
//   //                                     //     color: isSelected ? primaryColor : Colors.grey[800],
//   //                                     //   ),
//   //                                     // ),
//   //                                     Row(
//   //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                                       children: [
//   //                                         Flexible(
//   //                                           child: Text(
//   //                                             label,
//   //                                             style: TextStyle(
//   //                                               fontSize: 16,
//   //                                               fontWeight: FontWeight.w600,
//   //                                               color: isSelected ? primaryColor : Colors.grey[800],
//   //                                             ),
//   //                                           ),
//   //                                         ),
//   //                                         Text(
//   //                                           'AED ${price.toInt()}',
//   //                                           style: TextStyle(
//   //                                             fontSize: 18,
//   //                                             fontWeight: FontWeight.bold,
//   //                                             color: isSelected ? primaryColor : Colors.grey[800],
//   //                                           ),
//   //                                         ),
//   //                                       ],
//   //                                     ),
//   //
//   //                                   ],
//   //                                 ),
//   //                               ),
//   //
//   //                               // Price
//   //                               // Text(
//   //                               //   'AED ${amount.toInt()}',
//   //                               //   style: TextStyle(
//   //                               //     fontSize: 18,
//   //                               //     fontWeight: FontWeight.bold,
//   //                               //     color: isSelected ? primaryColor : Colors.grey[800],
//   //                               //   ),
//   //                               // ),
//   //                             ],
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     );
//   //                   }).toList(),
//   //
//   //                   // Additional information
//   //                   Container(
//   //                     margin: const EdgeInsets.symmetric(vertical: 16),
//   //                     padding: const EdgeInsets.all(16),
//   //                     decoration: BoxDecoration(
//   //                       color: Colors.blue[50],
//   //                       borderRadius: BorderRadius.circular(12),
//   //                       border: Border.all(color: Colors.blue[100]!),
//   //                     ),
//   //                     child: Row(
//   //                       children: [
//   //                         Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
//   //                         const SizedBox(width: 12),
//   //                         Expanded(
//   //                           child: Text(
//   //                             'Longer rental periods offer better value with significant discounts.',
//   //                             style: TextStyle(
//   //                               color: Colors.blue[700],
//   //                               fontSize: 14,
//   //                             ),
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //
//   //             // Bottom action area with total and button
//   //             Container(
//   //               padding: const EdgeInsets.all(16),
//   //               decoration: BoxDecoration(
//   //                 color: Colors.white,
//   //                 boxShadow: [
//   //                   BoxShadow(
//   //                     color: Colors.grey[200]!,
//   //                     blurRadius: 10,
//   //                     offset: const Offset(0, -4),
//   //                   ),
//   //                 ],
//   //               ),
//   //               child: Column(
//   //                 children: [
//   //                   // Total amount
//   //                   Row(
//   //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                     children: [
//   //                       Text(
//   //                         'Total Amount:',
//   //                         style: TextStyle(
//   //                           fontSize: 16,
//   //                           fontWeight: FontWeight.w500,
//   //                           color: Colors.grey[800],
//   //                         ),
//   //                       ),
//   //                       Text(
//   //                         'AED ${(double.tryParse(pricingData[selectedPricingIndex]['price'].toString()) ?? 0).toInt()}',
//   //                         style: TextStyle(
//   //                           fontSize: 20,
//   //                           fontWeight: FontWeight.bold,
//   //                           color: primaryColor,
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                   const SizedBox(height: 16),
//   //
//   //                   // Action button
//   //                   ElevatedButton(
//   //                     onPressed: () => _addToCart(
//   //                       thirdCategoryId: thirdCategory.id,
//   //                       type: widget.type,
//   //                       subscriptionFrequency: (double.tryParse(pricingData[selectedPricingIndex]['weeks'].toString()) ?? 0).toInt(),
//   //                       isDirectBooking: isDirectBooking,
//   //                     ),
//   //                     style: ElevatedButton.styleFrom(
//   //                       elevation: 0,
//   //                       padding: const EdgeInsets.symmetric(vertical: 16),
//   //                       backgroundColor: primaryColor,
//   //                       foregroundColor: Colors.white,
//   //                       shape: RoundedRectangleBorder(
//   //                         borderRadius: BorderRadius.circular(12),
//   //                       ),
//   //                       minimumSize: const Size(double.infinity, 50),
//   //                     ),
//   //                     child: const Text(
//   //                       'Add to Cart',
//   //                       style: TextStyle(
//   //                         fontSize: 16,
//   //                         fontWeight: FontWeight.bold,
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   void _showPriceDetailsBottomSheetSubscription(
//       BuildContext context,
//       ThirdCategory thirdCategory, {
//         required bool isDirectBooking,
//       }) {
//     final pricingData = <Map<String, dynamic>>[
//       if (thirdCategory.oneInWeekPrice != null)
//         {'label': '1 time per week', 'frequency': 1, 'price': thirdCategory.oneInWeekPrice},
//       if (thirdCategory.twoInWeekPrice != null)
//         {'label': '2 times per week', 'frequency': 2, 'price': thirdCategory.twoInWeekPrice},
//       if (thirdCategory.threeInWeekPrice != null)
//         {'label': '3 times per week', 'frequency': 3, 'price': thirdCategory.threeInWeekPrice},
//       if (thirdCategory.fourInWeekPrice != null)
//         {'label': '4 times per week', 'frequency': 4, 'price': thirdCategory.fourInWeekPrice},
//       if (thirdCategory.fiveInWeekPrice != null)
//         {'label': '5 times per week', 'frequency': 5, 'price': thirdCategory.fiveInWeekPrice},
//  if (thirdCategory.sixInWeekPrice != null)
//         {'label': '6 times per week', 'frequency': 6, 'price': thirdCategory.sixInWeekPrice},
//
//       // if (thirdCategory.onceInMonthPrice != null)
//       //   {'label': 'Once per month', 'frequency': 1, 'price': thirdCategory.onceInMonthPrice},
//       // if (thirdCategory.twiceInMonthPrice != null)
//       //   {'label': 'Twice per month', 'frequency': 1, 'price': thirdCategory.twiceInMonthPrice},
//       // if (thirdCategory.thriceInMonthPrice != null)
//       //   {'label': 'Three times per month', 'frequency': 1, 'price': thirdCategory.thriceInMonthPrice},
//       if (thirdCategory.onceInMonthPrice != null)
//         {'label': 'Once per month', 'frequency': 7, 'price': thirdCategory.onceInMonthPrice},
//       if (thirdCategory.twiceInMonthPrice != null)
//         {'label': 'Twice per month', 'frequency': 8, 'price': thirdCategory.twiceInMonthPrice},
//       if (thirdCategory.thriceInMonthPrice != null)
//         {'label': 'Three times per month', 'frequency': 9, 'price': thirdCategory.thriceInMonthPrice},
//
//     ];
//
//     int selectedPricingIndex = -1;
//     int customMonthFrequency = 1;
//     int employeeCount = 1;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) => Container(
//           height: MediaQuery.of(context).size.height * 0.75,
//           padding: const EdgeInsets.only(top: 16),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(24),
//               topRight: Radius.circular(24),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Drag indicator
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '    Price Details',
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.close, color: Colors.grey[700]),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           thirdCategory.name,
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               // Item name and description with shadow divider
//
//               const SizedBox(height: 4),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   'Select your preferred rental period',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ),
//               // Header
//               // Padding(
//               //   padding: const EdgeInsets.symmetric(horizontal: 16),
//               //   child: Row(
//               //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //     children: [
//               //       const Text(
//               //         'Select Frequency & Employees',
//               //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               //       ),
//               //       IconButton(
//               //         icon: const Icon(Icons.close),
//               //         onPressed: () => Navigator.pop(context),
//               //       ),
//               //     ],
//               //   ),
//               // ),
//               // const Divider(),
//               Container(
//                 height: 8,
//                 color: Colors.grey[50],
//               ),
//               Expanded(
//                 child: ListView(
//                   padding: const EdgeInsets.all(16),
//                   children: [
//                     const Text('Available Rental Periods', style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,)),
//                     const SizedBox(height: 12),
//                     ...pricingData.asMap().entries.map((entry) {
//                       final index = entry.key;
//                       final item = entry.value;
//                       final isSelected = index == selectedPricingIndex;
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 12),
//                         child: InkWell(
//                           onTap: () {
//                             setState(() {
//                               selectedPricingIndex = index;
//                             });
//                           },
//                           borderRadius: BorderRadius.circular(12),
//                           child: Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
//                               border: Border.all(
//                                 color: isSelected ? primaryColor : Colors.grey[300]!,
//                                 width: isSelected ? 2 : 1,
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     Container(
//                                                                       width: 24,
//                                                                       height: 24,
//                                                                       decoration: BoxDecoration(
//                                                                         shape: BoxShape.circle,
//                                                                         border: Border.all(
//                                                                           color: isSelected ? primaryColor : Colors.grey[400]!,
//                                                                           width: 2,
//                                                                         ),
//                                                                       ),
//                                                                       child: Center(
//                                                                         child: isSelected
//                                                                             ? Container(
//                                                                                 width: 12,
//                                                                                 height: 12,
//                                                                                 decoration: BoxDecoration(
//                                                                                   shape: BoxShape.circle,
//                                                                                   color: primaryColor,
//                                                                                 ),
//                                                                               )
//                                                                             : null,
//                                                                       ),
//                                                                     ),const SizedBox(width: 16),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//
//                                           Text(item['label'],
//                                               style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w600,
//                                                   color: isSelected ? primaryColor : Colors.black)),
//                                           if ((item['frequency'] as int) > 1)
//                                             Text(
//                                               'Save ${_calculateSavePercentage(pricingData, item)}% compared to weekly rate \nper session',
//                                               style: TextStyle(
//                                                 fontSize: 13,
//                                                 // fontWeight: FontWeight.bold,
//                                                 color:  isSelected ? primaryColor : Colors.grey[600],
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                     Text('AED ${double.tryParse(item['price'].toString())?.toInt() ?? 0}',
//                                         style: TextStyle(fontSize: 18,
//                                             fontWeight: FontWeight.bold,
//                                             color: isSelected ? primaryColor : Colors.black)),
//                                     const SizedBox(height: 4),
//
//
//                                   ],
//                                 ),
//
//                                   // Row(
//                                   //   children: [
//                                   //     if ((item['frequency'] as int) > 1)
//                                   //     Text(
//                                   //       'Save ${_calculateSavePercentage(pricingData, item)}% compared to weekly rate \nper session',
//                                   //       style: TextStyle(
//                                   //         fontSize: 13,
//                                   //                                   // fontWeight: FontWeight.bold,
//                                   //                                   color:  isSelected ? primaryColor : Colors.grey[600],
//                                   //       ),
//                                   //     ),
//                                   //   ],
//                                   // ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     }),
//                     Container(
//                       margin: const EdgeInsets.symmetric(vertical: 16),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.blue[100]!),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               'Longer rental periods offer better value with significant discounts.',
//                               style: TextStyle(
//                                 color: Colors.blue[700],
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // const Divider(),
//                     // const SizedBox(height: 8),
//                     // const Text('Or select custom month frequency:',
//                     //     style: TextStyle(fontWeight: FontWeight.w500)),
//                     // const SizedBox(height: 8),
//                     // Container(
//                     //   decoration: BoxDecoration(
//                     //     border: Border.all(color: Colors.grey[300]!),
//                     //     borderRadius: BorderRadius.circular(12),
//                     //   ),
//                     //   child: Row(
//                     //     children: [
//                     //       IconButton(
//                     //         icon: const Icon(Icons.remove_circle_outline),
//                     //         color: Colors.red,
//                     //         onPressed: () {
//                     //           setState(() {
//                     //             if (customMonthFrequency > 1) customMonthFrequency--;
//                     //             selectedPricingIndex = -1;
//                     //           });
//                     //         },
//                     //       ),
//                     //       Expanded(
//                     //         child: Center(
//                     //           child: Text(
//                     //             '$customMonthFrequency Month${customMonthFrequency > 1 ? 's' : ''}',
//                     //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                     //           ),
//                     //         ),
//                     //       ),
//                     //       IconButton(
//                     //         icon: const Icon(Icons.add_circle_outline),
//                     //         color: Colors.green,
//                     //         onPressed: () {
//                     //           setState(() {
//                     //             if (customMonthFrequency < 6) customMonthFrequency++;
//                     //             selectedPricingIndex = -1;
//                     //           });
//                     //         },
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ),
//                     // const SizedBox(height: 20),
//                     // const Text('Employee Count:', style: TextStyle(fontWeight: FontWeight.w500)),
//                     // const SizedBox(height: 8),
//                     // Container(
//                     //   decoration: BoxDecoration(
//                     //     border: Border.all(color: Colors.grey[300]!),
//                     //     borderRadius: BorderRadius.circular(12),
//                     //   ),
//                     //   child: Row(
//                     //     children: [
//                     //       IconButton(
//                     //         icon: const Icon(Icons.remove_circle_outline),
//                     //         color: Colors.red,
//                     //         onPressed: () {
//                     //           setState(() {
//                     //             if (employeeCount > 1) employeeCount--;
//                     //           });
//                     //         },
//                     //       ),
//                     //       Expanded(
//                     //         child: Center(
//                     //           child: Text(
//                     //             '$employeeCount Employee${employeeCount > 1 ? 's' : ''}',
//                     //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                     //           ),
//                     //         ),
//                     //       ),
//                     //       IconButton(
//                     //         icon: const Icon(Icons.add_circle_outline),
//                     //         color: Colors.green,
//                     //         onPressed: () {
//                     //           setState(() {
//                     //             if (employeeCount < 4) employeeCount++;
//                     //           });
//                     //         },
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     // Total amount
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Total Amount:',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                         Text(
//                           selectedPricingIndex >= 0
//                               ? 'AED ${(double.tryParse(pricingData[selectedPricingIndex]['price'].toString()) ?? 0).toInt()}'
//                               : 'Select frequency',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: primaryColor,
//                           ),
//                         ),
//
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         int frequency;
//                         if (selectedPricingIndex >= 0) {
//                           frequency = pricingData[selectedPricingIndex]['frequency'] as int;
//                         } else {
//                           frequency = customMonthFrequency;
//                         }
//                         if (frequency <= 0) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('Please select a frequency.')));
//                           return;
//                         }
//
//                         context.read<CartBloc>().add(
//                           AddToCart(
//                             thirdCategoryId: thirdCategory.id,
//                             employeeCount: employeeCount,
//                             type: widget.type,
//                             subscriptionFrequency: frequency,
//                             isDirectBooking: isDirectBooking,
//                           ),
//                         );
//                         Navigator.pop(context);
//                       },
//                       style:
//                       // ElevatedButton.styleFrom(
//                       //   minimumSize: const Size.fromHeight(50),
//                       //   backgroundColor: primaryColor,
//                       // ),
//                       ElevatedButton.styleFrom(
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         backgroundColor: primaryColor,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         minimumSize: const Size(double.infinity, 50),
//                       ),
//                       child: const Text(
//                         'Add to Cart',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   // Simple add-to-cart for a service (first or third category)
//
//   void _showPriceDetailsBottomSheetSingle(BuildContext context, ThirdCategory thirdCategory, {required bool isDirectBooking}) {
//     // For single items, we only need the price
//     final singlePrice = double.tryParse(thirdCategory.price.toString()) ?? 0;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.7, // Smaller height since fewer options
//         padding: const EdgeInsets.only(top: 16),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(24),
//             topRight: Radius.circular(24),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Bottom sheet header with decoration
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Drag indicator
//                   Center(
//                     child: Container(
//                       width: 40,
//                       height: 4,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Price Details',
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.close, color: Colors.grey[700]),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ],
//                   ),
//
//                   // Item name and description
//                   Text(
//                     thirdCategory.name,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'One-time purchase',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//             Container(
//               height: 8,
//               color: Colors.grey[50],
//             ),
//             const SizedBox(height: 16),
//
//             // Item details
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 children: [
//                   // Price details container
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.grey[300]!,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey[200]!,
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Item Price',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Base Price:',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             Text(
//                               'AED ${singlePrice.toInt()}',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey[800],
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         // You can add more pricing details here if needed
//                         // For example, taxes, discounts, etc.
//                         const SizedBox(height: 8),
//                         Divider(),
//                         const SizedBox(height: 8),
//
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Total:',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey[800],
//                               ),
//                             ),
//                             Text(
//                               'AED ${singlePrice.toInt()}',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: primaryColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Additional information
//                   Container(
//                     margin: const EdgeInsets.symmetric(vertical: 16),
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[50],
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.blue[100]!),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             'This is a one-time purchase. Consider subscription options for better value on regular needs.',
//                             style: TextStyle(
//                               color: Colors.blue[700],
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Bottom action area with total and button
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey[200]!,
//                     blurRadius: 10,
//                     offset: const Offset(0, -4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   // Total amount
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Total Amount:',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.grey[800],
//                         ),
//                       ),
//                       Text(
//                         'AED ${singlePrice.toInt()}',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: primaryColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//
//                   // Action button
//                   ElevatedButton(
//                     onPressed: () => _addToCart(
//                         thirdCategoryId: thirdCategory.id,
//                         type: widget.type,
//                         subscriptionFrequency: 0, // 0 to indicate single purchase, not subscription
//                         isDirectBooking: isDirectBooking),
//                     style: ElevatedButton.styleFrom(
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       backgroundColor: primaryColor,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       minimumSize: const Size(double.infinity, 50),
//                     ),
//                     child: const Text(
//                       'Add to Cart',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _gotoCartScreen() {
//     currentHomeIndexNotifier.value = 2;
//     Navigator.pop(context);
//   }
//
//   void _viewDetailsBottomSheet(ThirdCategory thirdCat, SecondCategory secondCat, bool isCarted) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         builder: (_, scrollController) => Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(24),
//               topRight: Radius.circular(24),
//             ),
//           ),
//           child: Column(
//             children: [
//               // Drag handle
//               Container(
//                 margin: const EdgeInsets.only(top: 12, bottom: 8),
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//
//               // Content
//               Expanded(
//                 child: ListView(
//                   controller: scrollController,
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   children: [
//                     // Header section
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Service Details',
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ],
//                     ),
//
//                     // Service image
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: Image.network(
//                         thirdCat.image, // Replace with actual image URL
//                         height: 200,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) => Container(
//                           height: 200,
//                           color: Colors.grey[200],
//                           child: const Center(
//                             child: Icon(Icons.image, size: 60, color: Colors.grey),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//
//                     // Service title and rating
//                     Text(
//                       thirdCat.name, // Replace with actual service name
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Icon(Icons.star, color: Colors.amber[600], size: 18),
//                         const SizedBox(width: 4),
//                         Text(
//                           '4.3',
//                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         Text(
//                           ' (324 Reviews)',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//
//                     // Price section
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: primaryColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Starting from',
//                                 style: TextStyle(
//                                   color: Colors.grey[700],
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Row(
//                                 children: [
//                                   Text(
//                                     'AED ${thirdCat.price}',
//                                     style: TextStyle(
//                                       color: primaryColor,
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(color: primaryColor),
//                             ),
//                             child: Text(
//                               'Best Value',
//                               style: TextStyle(
//                                 color: primaryColor,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // const SizedBox(height: 24),
//                     // // Description section
//                     // const Text(
//                     //   'Description',
//                     //   style: TextStyle(
//                     //     fontSize: 18,
//                     //     fontWeight: FontWeight.bold,
//                     //   ),
//                     // ),
//                     // const SizedBox(height: 12),
//                     // Text(
//                     //   'This service includes a comprehensive cleaning of your space with top-quality products and professional tools. Our experienced team will ensure your satisfaction with attention to detail.',
//                     //   style: TextStyle(
//                     //     fontSize: 14,
//                     //     color: Colors.grey[700],
//                     //     height: 1.5,
//                     //   ),
//                     // ),
//                     const SizedBox(height: 24),
//
//                     // What's included section
//                     const Text(
//                       'What\'s Included',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     ...thirdCat.materials.map<Widget>((material) => _buildServiceItem(material.name,material.comment)),
//                     const SizedBox(height: 24),
//
//                     ReviewSection(secondCatId: secondCat.id),
//                   ],
//                 ),
//               ),
//
//               // Fixed bottom buttons
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.2),
//                       spreadRadius: 1,
//                       blurRadius: 10,
//                       offset: const Offset(0, -4),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           _showPriceOrViewToCart(context, thirdCat, isCarted, isDirectBooking: false);
//                         },
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           side: BorderSide(color: primaryColor),
//                           backgroundColor: Colors.white,
//                           foregroundColor: primaryColor,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: Text(
//                           isCarted ? 'View Cart' : 'Add to Cart',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           if (isCarted) {
//                             _gotoBookScreen(context, thirdCat.id);
//                           } else {
//                             _showPriceOrViewToCart(context, thirdCat, isCarted, isDirectBooking: true);
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           backgroundColor: primaryColor,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           'Book Now',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Widget _buildServiceItem(String text,String? comment) {
//   //   return Padding(
//   //     padding: const EdgeInsets.only(bottom: 8),
//   //     child: Row(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         Icon(Icons.check_circle, color: primaryColor, size: 20),
//   //         const SizedBox(width: 12),
//   //         Expanded(
//   //           child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Text(
//   //                 // "text ${text}",
//   //                 text,
//   //                 style: TextStyle(
//   //                   fontSize: 15,
//   //                   color: Colors.grey[700], fontWeight: FontWeight.w600,
//   //                   height: 1.5,
//   //                 ),
//   //               ),
//   //               if (comment != null && comment.isNotEmpty)
//   //                 Padding(
//   //                   padding: const EdgeInsets.only(top: 2),
//   //                   child: Text(
//   //                     comment,
//   //                     style: TextStyle(
//   //                       fontSize: 13,
//   //                       color: Colors.grey[600],
//   //                       height: 1.4,
//   //                     ),
//   //                   ),
//   //                 ),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//   Widget _buildServiceItem(String name, String? comment) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Color(0xFF19D4D4).withOpacity(0.3)),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Color(0xFF19D4D4).withOpacity(0.08),
//               blurRadius: 8,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               name,
//               style: const TextStyle(
//                 fontSize: 15.5,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF0E3A47), // matches dark tone
//                 letterSpacing: 0.3,
//               ),
//             ),
//             if (comment != null && comment.trim().isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 6),
//                 child: Text(
//                   comment,
//                   style: TextStyle(
//                     fontSize: 13.5,
//                     color: Colors.grey.shade600,
//                     height: 1.5,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
// }
//
// int _calculateSavePercentage(
//     List<Map<String, dynamic>> pricingData,
//     Map<String, dynamic> item,
//     ) {
//   try {
//     final oneWeek = pricingData.firstWhere((e) => e['frequency'] == 1);
//     final oneWeekPrice = double.tryParse(oneWeek['price'].toString()) ?? 0;
//     final multiPrice = double.tryParse(item['price'].toString()) ?? 0;
//
//     if (oneWeekPrice <= 0 || multiPrice <= 0) return 0;
//
//     // Directly compare per-week prices
//     final savings = ((1 - (multiPrice / oneWeekPrice)) * 100).round();
//     return savings > 0 ? savings : 0;
//   } catch (e) {
//     return 0;
//   }
// }
//
//
//
// void _gotoBookScreen(BuildContext context, int cartThirdId) async {
//   showDialog(
//     context: context,
//     builder: (_) => Center(child: CircularProgressIndicator()),
//   );
//
//   final cartBloc = context.read<CartBloc>();
//   cartBloc.add(FetchCartList());
//
//   await for (var state in cartBloc.stream) {
//     if (state is CartLoaded) {
//       var carts = state.cartItems;
//       var cart = carts.firstWhere((e) => e.thirdCategory.id == cartThirdId);
//
//       if (context.mounted) {
//         Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
//       } // Close loading dialog
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => OrderConfirmationScreen(carts: [cart])),
//       );
//       break;
//     }
//   }
// }
//
// // class ShimmerCategoryDetailLoading extends StatelessWidget {
// //   const ShimmerCategoryDetailLoading({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Shimmer.fromColors(
// //                 baseColor: Colors.grey[300]!,
// //                 highlightColor: Colors.grey[100]!,
// //                 child: Container(
// //                   width: 150,
// //                   height: 24,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Row(
// //                 children: [
// //                   Icon(Icons.star, color: Colors.grey[300], size: 16),
// //                   const SizedBox(width: 4),
// //                   Shimmer.fromColors(
// //                     baseColor: Colors.grey[300]!,
// //                     highlightColor: Colors.grey[100]!,
// //                     child: Container(
// //                       width: 100,
// //                       height: 14,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //         Padding(
// //           padding: const EdgeInsets.only(top: 8, bottom: 20),
// //           child: Divider(thickness: 7, color: Colors.grey.shade200),
// //         ),
// //         _buildShimmerGrid(),
// //         Padding(
// //           padding: const EdgeInsets.only(top: 10, bottom: 15),
// //           child: Divider(thickness: 7, color: Colors.grey.shade200),
// //         ),
// //         _buildShimmerItems(),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildShimmerGrid() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 15),
// //       child: Shimmer.fromColors(
// //         baseColor: Colors.grey[300]!,
// //         highlightColor: Colors.grey[100]!,
// //         child: GridView.builder(
// //           shrinkWrap: true,
// //           physics: NeverScrollableScrollPhysics(),
// //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //             crossAxisCount: 2,
// //             crossAxisSpacing: 10,
// //             mainAxisSpacing: 10,
// //             childAspectRatio: 1.5,
// //           ),
// //           itemCount: 4,
// //           itemBuilder: (context, index) {
// //             return Container(
// //               height: 100,
// //               color: Colors.white,
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildShimmerItems() {
// //     return Shimmer.fromColors(
// //       baseColor: Colors.grey[300]!,
// //       highlightColor: Colors.grey[100]!,
// //       child: ListView.builder(
// //         shrinkWrap: true,
// //         physics: NeverScrollableScrollPhysics(),
// //         itemCount: 3,
// //         itemBuilder: (context, index) {
// //           return Padding(
// //             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
// //             child: Container(
// //               height: 80,
// //               color: Colors.white,
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
//   }
//
//   Widget _buildShimmerItems() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: ListView.builder(
//         shrinkWrap: true,
//         physics: NeverScrollableScrollPhysics(),
//         itemCount: 3,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             child: Container(
//               height: 80,
//               color: Colors.white,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
