// Add this import at the top of the file
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kleanitapp/core/constants/Sypdo_constants.dart';
import 'package:kleanitapp/core/theme/sypd_color.dart';
import 'package:kleanitapp/features/cart/screens/widgets/Apporder_type_selector.dart';
import 'package:kleanitapp/features/home/Apphome_main.dart';
import 'package:kleanitapp/features/order/presentation/Apporder_screen.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../model/Appcart.dart';

class AppCartListScreen extends StatefulWidget {
  const AppCartListScreen({Key? key}) : super(key: key);

  @override
  State<AppCartListScreen> createState() => _AppCartListScreenState();
}

class _AppCartListScreenState extends State<AppCartListScreen> {
  String _selectedServiceType = AppSubscriptionType.SINGLE;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocConsumer<CartBloc, CartState>(
          listener: (ctx, state) {
            if (state is CartActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart updated successfully'), duration: Duration(seconds: 2)));
            } else if (state is CartError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
            }
          },
          builder: (ctx, state) {
            if (state is CartInitial) {
              // Load cart when screen initializes
              context.read<CartBloc>().add(FetchCartList());
              return const Center(child: CircularProgressIndicator());
            } else if (state is CartLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CartLoaded) {
              final allCartItems = state.cartItems;
              final filteredCartItems = allCartItems.where((e) => e.type == _selectedServiceType).toList();

              return Column(
                children: [
                  _buildHeader(context),
                  AppOrderTypeSelector(initialSelection: _selectedServiceType, onTypeSelected: _updateServiceType),
                  Expanded(
                    child:
                        filteredCartItems.isEmpty
                            ? _buildEmptyState(context)
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: filteredCartItems.length,
                              itemBuilder: (context, index) {
                                return _buildCartItem(context, filteredCartItems[index]);
                              },
                            ),
                  ),
                  if (filteredCartItems.isNotEmpty && _selectedServiceType == AppSubscriptionType.SINGLE) _buildCheckoutBar(context, filteredCartItems),
                ],
              );
            } else if (state is CartError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CartBloc>().add(FetchCartList());
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            // Default fallback
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('My Cart', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          // IconButton(
          //   icon: const Icon(Icons.refresh, size: 28),
          //   onPressed: () {
          //     context.read<CartBloc>().add(FetchCartList());
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, AppCart cart) {
    // Format subscription frequency
    // String frequencyText = '';
    // if (cart.type == SubscriptionType.SINGLE) {
    //   frequencyText = 'Single';
    // } else {
    //   frequencyText = '${cart.subscriptionFrequency}  in a week';
    // }
    // Format subscription frequency
    String frequencyText = '';
    if (cart.type == AppSubscriptionType.SINGLE) {
      frequencyText = 'Single';
    } else {
      switch (cart.subscriptionFrequency) {
        case "7":
          frequencyText = 'Once per month';
          break;
        case "8":
          frequencyText = 'Twice per month';
          break;
        case "9":
          frequencyText = 'Three times per month';
          break;
        default:
          frequencyText = '${cart.subscriptionFrequency} in a week';
      }
    }

    // Format price
    final priceField = double.tryParse(cart.thirdCategory.price) ?? 0;
    final formattedPrice = ' ${priceField.toInt()}';

    // Employee count text
    final employeeText = cart.employeeCount > 1 ? '${cart.employeeCount} Employees' : ' Employee';

    // Service schedule extraction
    Map<String, dynamic> schedule = {};
    try {
      if (cart.thirdCategory.schedule != null) {
        schedule = Map<String, dynamic>.from(
          cart.thirdCategory.schedule is String
              ? Map<String, dynamic>.from(Map<String, dynamic>.from(jsonDecode(cart.thirdCategory.schedule as String)))
              : cart.thirdCategory.schedule as Map<String, dynamic>,
        );
      }
    } catch (e) {
      // Handle parsing error
      print('Error parsing schedule: $e');
    }

    // Calculate estimated duration
    String duration = '1 hour';
    if (schedule.isNotEmpty) {
      int totalMinutes = 0;
      schedule.forEach((key, value) {
        if (value is String && value.contains('min')) {
          totalMinutes += int.tryParse(value.replaceAll('min', '').trim()) ?? 0;
        }
      });

      if (totalMinutes > 0) {
        int hours = totalMinutes ~/ 60;
        int minutes = totalMinutes % 60;

        if (hours > 0) {
          duration = '$hours hour${hours > 1 ? 's' : ''}';
          if (minutes > 0) {
            duration += ' $minutes min';
          }
        } else {
          duration = '$minutes min';
        }
      }
    }

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
          // Image section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child:
                    cart.thirdCategory.image != null && cart.thirdCategory.image!.isNotEmpty
                        ? Image.network(
                          cart.thirdCategory.image!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Icon(Icons.cleaning_services, size: 60, color: Colors.grey),
                            );
                          },
                        )
                        : Container(
                          height: 180,
                          width: double.infinity,
                          color: primaryColor.withOpacity(.1),
                          child: Icon(Icons.cleaning_services, size: 60, color: primaryColor.withOpacity(.4)),
                        ),
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
                  child: InkWell(
                    onTap: () {
                      _showDeleteConfirmation(context, cart);
                    },
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
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
                    Expanded(child: Text(cart.thirdCategory.name ?? 'Unnamed Service', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: primaryColor.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
                      child:
                      // Row(
                      //   children: [
                      //     Text(
                      //       formattedPrice,
                      //       style: TextStyle(
                      //         color: primaryColor,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icon/aed_symbol.png',
                            width: 14,
                            height: 14,
                            fit: BoxFit.contain,
                            // color: primaryColor, // optional: tint the symbol
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(double.tryParse(formattedPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0).toInt()}',
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(employeeText, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                    const SizedBox(width: 16),
                    // Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    // Text(
                    //   duration,
                    //   style: TextStyle(
                    //     color: Colors.grey[700],
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: [Icon(Icons.repeat, size: 18, color: Colors.grey[600]), const SizedBox(width: 4), Text(frequencyText, style: TextStyle(color: Colors.grey[700]))]),
                const SizedBox(height: 12),
                if (schedule.isNotEmpty) ...[
                  Text('Service Schedule:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 4),
                  ...schedule.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 16, color: Colors.green[600]),
                          const SizedBox(width: 4),
                          Text('${entry.key}: ${entry.value}', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showDeleteConfirmation(context, cart);
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
                          _gotoBookScreen(context, [cart]);
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Your Cart is Empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 8),
          Text('Add services to your cart', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to services
              // Goto home screen
              currentHomeIndexNotifier.value = 0;
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Explore Services'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, List<AppCart> cartItems) {
    // Calculate total price
    double totalPrice = 0;
    for (var cart in cartItems) {
      final price = double.tryParse(cart.thirdCategory.price ?? '0') ?? 0;
      // Adjust price based on employee count and subscription frequency
      double netPrice = price * cart.employeeCount;
      totalPrice += netPrice;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Total: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[800])),
                  // Text(
                  //   'AED ${totalPrice.toInt()}',
                  //   style: TextStyle(
                  //     fontSize: 22,
                  //     fontWeight: FontWeight.bold,
                  //     color: primaryColor,
                  //   ),
                  // ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icon/aed_symbol.png',
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                        // color: primaryColor, // Optional: apply color tint
                      ),
                      const SizedBox(width: 4),
                      Text('${totalPrice.toInt()}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                ],
              ),
              Text('${cartItems.length} item${cartItems.length > 1 ? 's' : ''}', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Proceed to checkout
                _gotoBookScreen(context, cartItems);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Proceed to Checkout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppCart cart) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);

        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: curvedAnimation,
            child: AlertDialog(
              backgroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Remove from Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: Icon(Icons.remove_shopping_cart, color: Colors.red, size: 40),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Are you sure you want to remove "${cart.thirdCategory.name}" from your cart?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
              contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: Text('Cancel', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _deleteCart(context, cart),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Remove', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _gotoBookScreen(BuildContext context, List<AppCart> carts) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AppOrderConfirmationScreen(carts: carts)));
  }

  void _deleteCart(BuildContext context, AppCart cart) {
    Navigator.pop(context);
    context.read<CartBloc>().add(DeleteCartItem(cartId: cart.id));
  }

  void _updateServiceType(String type) {
    setState(() {
      _selectedServiceType = type;
    });
  }
}
