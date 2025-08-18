// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:kleanitapp/core/constants/Sypdo_stripe_key.dart';
import 'package:kleanitapp/core/utils/Spydo_hepler.dart';
import 'package:kleanitapp/features/address/bloc/address_bloc.dart';
import 'package:kleanitapp/features/address/repo/Appaddress_repository.dart';
import 'package:kleanitapp/features/auth/bloc/token/token_bloc.dart';
import 'package:kleanitapp/features/auth/respository/Apptoken_repository.dart';
import 'package:kleanitapp/features/bookings/repo/Appbooking_repository.dart';
import 'package:kleanitapp/features/home/bloc/wallet/wallet_bloc.dart';
import 'package:kleanitapp/features/home/repo/Appwallet_repository.dart';
import 'package:kleanitapp/features/notification/bloc/notification_bloc.dart';
import 'package:kleanitapp/features/notification/repo/Appnotification_repository.dart';
import 'package:kleanitapp/features/order/bloc/coupon/coupon_bloc.dart';
import 'package:kleanitapp/features/profile/bloc/profile_bloc.dart';
import 'package:kleanitapp/features/profile/repo/Appprofile_repository.dart';
import 'package:kleanitapp/services/AppNetworkService.dart';

import 'features/auth/bloc/auth/auth_bloc.dart';
import 'features/auth/respository/Appauth_repository.dart';
import 'features/bookings/bloc/booking_bloc.dart';
import 'features/bookings/bloc/booking_detail_bloc.dart';
import 'features/bookings/bloc/weekly_schedule_bloc.dart';
import 'features/cart/bloc/cart_bloc.dart';
import 'features/cart/bloc/cart_event.dart';
import 'features/cart/repo/Appcart_repository.dart';
import 'features/categories/bloc/categories_bloc.dart';
import 'features/categories/bloc/review/review_bloc.dart';
import 'features/categories/respository/Appcategory_repository.dart';
import 'features/categories/respository/Appreview_repository.dart';
import 'features/order/bloc/order_bloc.dart';
import 'features/order/repo/Apporder_repository.dart';
import 'firebase_options.dart';
import 'routes/Approute_builder.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // if (kDebugMode) {
  //   HttpOverrides.global = MyHttpOverrides();
  // }

  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Ask for iOS notification permission
  await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

  FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Setup Stripe
  Stripe.publishableKey = StripeKeys.publishableKey;

  await setupFlutterNotifications();
  await Firebase.initializeApp(); // <-- required
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository: AppAuthRepository(networkService: AppNetworkService()))),
        BlocProvider<TokenBloc>(create: (_) => TokenBloc(repository: TokenRepository())),

        BlocProvider(create: (context) => CartBloc(cartRepository: AppCartRepository())..add(FetchCartList())),
        BlocProvider(create: (context) => AddressBloc(AppAddressRepository())),
        BlocProvider(create: (context) => OrderBloc(orderRepository: AppOrderRepository())),
        BlocProvider(create: (context) => BookingBloc(repository: AppBookingRepository())),
        BlocProvider(create: (context) => ProfileBloc(repository: AppProfileRepository())),
        BlocProvider(create: (_) => WeeklyScheduleBloc(bookingRepository: AppBookingRepository())),
        BlocProvider(create: (_) => ReviewBloc(repository: AppReviewRepository())),
        BlocProvider(create: (ctx) => BookingDetailBloc(AppBookingRepository())),
        BlocProvider(create: (ctx) => WalletBloc(AppWalletRepository())),
        BlocProvider(create: (ctx) => NotificationBloc(repository: AppNotificationRepository())),
        BlocProvider<CategoriesBloc>(create: (context) => CategoriesBloc(categoryRepository: AppCategoryRepository())),
        BlocProvider<CouponBloc>(create: (context) => CouponBloc(orderRepository: AppOrderRepository())),
        // Provide additional blocs here.
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        // ✅ add this line
        title: 'Kleanit App',
        theme: ThemeData(primarySwatch: Colors.green),
        initialRoute: '/',
        onGenerateRoute: AppRouteBuilder.generateRoute,
      ),
    );
  }
}

Future<void> setupFlutterNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  showFlutterNotification(message);
}

Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  showFlutterNotification(message);
}

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }
