// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:kleanitapp/core/constants/stripe_key.dart';
import 'package:kleanitapp/core/utils/hepler.dart';
import 'package:kleanitapp/features/address/bloc/address_bloc.dart';
import 'package:kleanitapp/features/address/repo/address_repository.dart';
import 'package:kleanitapp/features/auth/bloc/token/token_bloc.dart';
import 'package:kleanitapp/features/auth/respository/token_repository.dart';
import 'package:kleanitapp/features/bookings/repo/booking_repository.dart';
import 'package:kleanitapp/features/home/bloc/wallet/wallet_bloc.dart';
import 'package:kleanitapp/features/home/repo/wallet_repository.dart';
import 'package:kleanitapp/features/notification/bloc/notification_bloc.dart';
import 'package:kleanitapp/features/notification/repo/notification_repository.dart';
import 'package:kleanitapp/features/order/bloc/coupon/coupon_bloc.dart';
import 'package:kleanitapp/features/profile/bloc/profile_bloc.dart';
import 'package:kleanitapp/features/profile/repo/profile_repository.dart';
import 'package:kleanitapp/services/NetworkService.dart';

import 'features/auth/bloc/auth/auth_bloc.dart';
import 'features/auth/respository/auth_repository.dart';
import 'features/bookings/bloc/booking_bloc.dart';
import 'features/bookings/bloc/booking_detail_bloc.dart';
import 'features/bookings/bloc/weekly_schedule_bloc.dart';
import 'features/cart/bloc/cart_bloc.dart';
import 'features/cart/bloc/cart_event.dart';
import 'features/cart/repo/cart_repository.dart';
import 'features/categories/bloc/categories_bloc.dart';
import 'features/categories/bloc/review/review_bloc.dart';
import 'features/categories/respository/category_repository.dart';
import 'features/categories/respository/review_repository.dart';
import 'features/order/bloc/order_bloc.dart';
import 'features/order/repo/order_repository.dart';
import 'firebase_options.dart';
import 'routes/route_builder.dart';

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
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository: AuthRepository(networkService: NetworkService()))),
        BlocProvider<TokenBloc>(create: (_) => TokenBloc(repository: TokenRepository())),

        BlocProvider(create: (context) => CartBloc(cartRepository: CartRepository())..add(FetchCartList())),
        BlocProvider(create: (context) => AddressBloc(AddressRepository())),
        BlocProvider(create: (context) => OrderBloc(orderRepository: OrderRepository())),
        BlocProvider(create: (context) => BookingBloc(repository: BookingRepository())),
        BlocProvider(create: (context) => ProfileBloc(repository: ProfileRepository())),
        BlocProvider(create: (_) => WeeklyScheduleBloc(bookingRepository: BookingRepository())),
        BlocProvider(create: (_) => ReviewBloc(repository: ReviewRepository())),
        BlocProvider(create: (ctx) => BookingDetailBloc(BookingRepository())),
        BlocProvider(create: (ctx) => WalletBloc(WalletRepository())),
        BlocProvider(create: (ctx) => NotificationBloc(repository: NotificationRepository())),
        BlocProvider<CategoriesBloc>(create: (context) => CategoriesBloc(categoryRepository: CategoryRepository())),
        BlocProvider<CouponBloc>(create: (context) => CouponBloc(orderRepository: OrderRepository())),
        // Provide additional blocs here.
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        // ✅ add this line
        title: 'Kleanit App',
        theme: ThemeData(primarySwatch: Colors.green),
        initialRoute: '/',
        onGenerateRoute: RouteBuilder.generateRoute,
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
