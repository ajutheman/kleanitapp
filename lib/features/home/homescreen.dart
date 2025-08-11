import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kleanitapp/core/constants/constants.dart';
import 'package:kleanitapp/core/constants/pref_resources.dart';
import 'package:kleanitapp/core/theme/color_data.dart';
import 'package:kleanitapp/core/theme/resizer/fetch_pixels.dart';
import 'package:kleanitapp/core/theme/widget_utils.dart';
import 'package:kleanitapp/features/home/bloc/wallet/wallet_bloc.dart';
import 'package:kleanitapp/features/home/faq_section.dart';
import 'package:kleanitapp/features/home/refer_advertisement_list.dart';
import 'package:kleanitapp/features/home/repo/WalletScreen.dart';
import 'package:kleanitapp/features/home/service_type_selector.dart';
import 'package:kleanitapp/features/home/sub_advertisement_list.dart';
import 'package:kleanitapp/features/notification/screen/notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/widgets/internet_connection.dart';
import '../../routes/app_routes..dart';
import '../Advertisement/Bloc/advertisement_bloc.dart';
import '../Advertisement/Bloc/advertisement_event.dart';
import '../Advertisement/Bloc/advertisement_state.dart';
import '../Advertisement/Repository/advertisement_repository.dart';
import '../Advertisement/screen/AdvertisementCarousel.dart';
import '../Referral/referal_advertisement_repository.dart';
import '../Referral/referral_bloc.dart';
import '../Referral/referral_event.dart';
import '../Referral/referral_state.dart';
import '../SubAdvertisement/Bloc/sub_advertisement_bloc.dart';
import '../SubAdvertisement/Bloc/sub_advertisement_event.dart';
import '../SubAdvertisement/Bloc/sub_advertisement_state.dart';
import '../SubAdvertisement/Repository/sub_advertisement_repository.dart';
import '../categories/bloc/categories_bloc.dart';
import 'bloc/home_bloc.dart';
import 'category_list.dart';
import 'home_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? customerData;
  String _selectedServiceType = SubscriptionType.SINGLE;

  Future<void> _getCustomerData() async {
    final prefs = await SharedPreferences.getInstance();
    final customerStr = prefs.getString("customer_data");
    if (customerStr != null) {
      setState(() {
        customerData = jsonDecode(customerStr);
      });
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefResources.USER_ACCESS_TOCKEN) ?? "";
  }

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(LoadWalletBalance());
    context.read<CategoriesBloc>().add(LoadCategories(type: _selectedServiceType));
    _getCustomerData();
  }

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    return FutureBuilder<String>(
      future: _getToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final token = snapshot.data!;
        return MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>(create: (context) => HomeBloc(repository: HomeRepository())..add(LoadHomeData())),
            BlocProvider<AdvertisementBloc>(create: (context) => AdvertisementBloc(repository: AdvertisementRepository(), token: token)..add(LoadAdvertisements())),
            BlocProvider<SubAdvertisementBloc>(create: (context) => SubAdvertisementBloc(repository: SubAdvertisementRepository(), token: token)..add(LoadSubAdvertisements())),
            BlocProvider<ReferalAdvertisementBloc>(
              create: (context) => ReferalAdvertisementBloc(repository: ReferalAdvertisementRepository(), token: token)..add(LoadReferalAdvertisements()),
            ),
          ],
          child: CheckInternetConnection(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                // backgroundColor: Colors.white,
                backgroundColor: const Color.fromRGBO(0, 58, 69, 1), // OR
                title: Row(
                  children: [
                    Image.asset(
                      "assets/icon/logo_dark.png",
                      // "assets/icon/logo_light.png",
                      height: 30,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        getSvgImage("location.svg"),
                        getHorSpace(FetchPixels.getPixelWidth(4)),
                        getCustomFont("Dubai, UAE", 14, Colors.white, 1, fontWeight: FontWeight.w400),
                      ],
                    ),
                    const Spacer(),
                    ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                        },
                        child: Row(
                          children: [
                            BlocBuilder<WalletBloc, WalletState>(
                              builder: (ctx, state) {
                                if (state is WalletLoading) {
                                  return SpinKitThreeBounce(
                                    size: 8,
                                    itemBuilder: (BuildContext context, int index) {
                                      return DecoratedBox(decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(30)));
                                    },
                                  );
                                } else if (state is WalletLoaded) {
                                  return getCustomFont(state.balance.toString(), 15, Colors.white, 1, fontWeight: FontWeight.w500);
                                } else {
                                  return SizedBox();
                                }
                              },
                            ),
                            SizedBox(width: 5),
                            getSvgImage('coin.svg', width: 20, height: 20),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationListScreen()));
                        },
                        child: getSvgImage("notification.svg", color: Colors.white, height: FetchPixels.getPixelHeight(24), width: FetchPixels.getPixelHeight(24)),
                      ),
                    ],
                  ],
                ),
              ),
              body: Column(
                children: [
                  // Add the service type selector here
                  ServiceTypeSelector(onTypeSelected: _updateServiceType, initialSelection: _selectedServiceType),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(FetchPixels.getPixelWidth(16)),
                      children: [
                        // Main Advertisements Section using AdvertisementCarousel.
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "New offer",
                            // "Advertisements",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(height: 10),
                        BlocBuilder<AdvertisementBloc, AdvertisementState>(
                          builder: (context, state) {
                            if (state is AdvertisementLoading) {
                              return ShimmerAdvertisementLoader();
                            } else if (state is AdvertisementLoaded) {
                              final advertisements = state.advertisements;
                              return AdvertisementCarousel(
                                advertisements: advertisements,
                                onBookTap: (advertisement) {
                                  final categoryBLoc = context.read<CategoriesBloc>().state;
                                  if (categoryBLoc is CategoriesLoaded) {
                                    try {
                                      var cat = categoryBLoc.categories.firstWhere((e) => e.id == advertisement.mainCategoryId);
                                      Navigator.pushNamed(
                                        context,
                                        Routes.categoryDetail,
                                        arguments: {"type": _selectedServiceType, "category": cat},
                                        // arguments: {"main_category_id": cat.id, "type": _selectedServiceType, "category": cat},
                                      );
                                    } catch (e) {
                                      print("No Element");
                                    }
                                  }
                                },
                              );
                            } else if (state is AdvertisementError) {
                              return Center(child: Text("Error: ${state.error}"));
                            }
                            return Container();
                          },
                        ),
                        getVerSpace(FetchPixels.getPixelHeight(32)),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: getCustomFont("Categories", 20, Colors.black, 1, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        // Categories Section
                        SizedBox(
                          height: 200,
                          child: BlocBuilder<CategoriesBloc, CategoriesState>(
                            builder: (context, state) {
                              if (state is CategoriesLoading) {
                                return ShimmerCategoriesLoader(); // Shimmer effect while loading
                              } else if (state is CategoriesLoaded) {
                                return CategoriesList(categories: state.categories, selectedType: _selectedServiceType);
                              } else if (state is CategoriesError) {
                                return Center(child: Text("Error: ${state.error}"));
                              }
                              return Container();
                            },
                          ),
                        ),
                        // getVerSpace(FetchPixels.getPixelHeight(32)),

                        // Sub Advertisements Section (showing 2 small items).
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Special Promotion",
                            // "More Offers",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // BlocBuilder<SubAdvertisementBloc, SubAdvertisementState>(
                        //   builder: (context, state) {
                        //     if (state is SubAdvertisementLoading) {
                        //       return ShimmerSubAdvertisementLoader(); // Shimmer effect while loading
                        //     } else if (state is SubAdvertisementLoaded) {
                        //       // ✅ Sort by position before passing to SubAdvertisementList
                        //       final sortedAds = List<SubAdvertisement>.from(state.subAdvertisements)
                        //         ..sort((a, b) => a.position.compareTo(b.position));
                        //
                        //       return SubAdvertisementList(subAds: state.subAdvertisements,     onBookTap: (advertisement) {
                        //         final categoryBLoc = context.read<CategoriesBloc>().state;
                        //         if (categoryBLoc is CategoriesLoaded) {
                        //           try {
                        //             var cat = categoryBLoc.categories.firstWhere((e) => e.id == advertisement.mainCategoryId);
                        //             Navigator.pushNamed(
                        //               context,
                        //               Routes.categoryDetail,
                        //               arguments: {"type": _selectedServiceType, "category": cat},
                        //               // arguments: {"main_category_id": cat.id, "type": _selectedServiceType, "category": cat},
                        //             );
                        //           } catch (e) {
                        //             print("No Element");
                        //           }
                        //         }
                        //       },);
                        //     } else if (state is SubAdvertisementError) {
                        //       return Center(child: Text("Error: ${state.error}"));
                        //     }
                        //     return Container();
                        //   },
                        // ),
                        BlocBuilder<SubAdvertisementBloc, SubAdvertisementState>(
                          builder: (context, state) {
                            if (state is SubAdvertisementLoading) {
                              return ShimmerSubAdvertisementLoader(); // Shimmer effect while loading
                            } else if (state is SubAdvertisementLoaded) {
                              // // ✅ Sort by position before passing to SubAdvertisementList
                              // final sortedAds = List<SubAdvertisement>.from(state.subAdvertisements)
                              //   ..sort((a, b) => a.position.compareTo(b.position));
                              // ✅ Filter out ads that are marked as used
                              final activeAds = state.subAdvertisements.where((ad) => !ad.isUsed).toList();

                              // ✅ Sort them by position
                              activeAds.sort((a, b) => a.position.compareTo(b.position));

                              return SubAdvertisementList(
                                subAds: activeAds,
                                // sortedAds,
                                onBookTap: (advertisement) {
                                  final categoryBlocState = context.read<CategoriesBloc>().state;
                                  if (categoryBlocState is CategoriesLoaded) {
                                    try {
                                      var cat = categoryBlocState.categories.firstWhere((e) => e.id == advertisement.mainCategoryId);
                                      Navigator.pushNamed(context, Routes.categoryDetail, arguments: {"type": _selectedServiceType, "category": cat});
                                    } catch (e) {
                                      print("No matching category found.");
                                    }
                                  }
                                },
                              );
                            } else if (state is SubAdvertisementError) {
                              return Center(child: Text("Error: ${state.error}"));
                            }
                            return Container();
                          },
                        ),

                        getVerSpace(FetchPixels.getPixelHeight(5)),
                        // Referral Advertisement Section
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text("Refer & Earn", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                        const SizedBox(height: 10),
                        BlocBuilder<ReferalAdvertisementBloc, ReferalAdvertisementState>(
                          builder: (context, state) {
                            if (state is ReferalAdvertisementLoading) {
                              return ShimmerReferalAdvertisementLoader(); // Shimmer effect while loading
                            } else if (state is ReferalAdvertisementLoaded) {
                              return ReferalAdvertisementList(referals: state.referalAdvertisements);
                            } else if (state is ReferalAdvertisementError) {
                              return Center(child: Text("Error: ${state.error}"));
                            }
                            return Container();
                          },
                        ),

                        FAQSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //   );
  // }

  void _updateServiceType(String type) {
    setState(() {
      _selectedServiceType = type;
      // 👇 Dispatch LoadCategories with new type
      //       context.read<CategoriesBloc>().add(LoadCategories(type: type));
      //  context.load<>.load
    });
    // ✨ Delay Bloc event dispatch until widget build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesBloc>().add(LoadCategories(type: type));
    }); // no crash now!
  }
}
