import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kleanitapp/features/account/screens/Appprivacy_screen.dart';
import 'package:kleanitapp/features/account/screens/Appsupport_screen.dart';
import 'package:kleanitapp/features/account/screens/Appterm_of_use_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/Spydo_pref_resources.dart';
import '../../../core/theme/sypd_color.dart';
import '../../../core/theme/resizer/sypdo_fetch_pixels.dart';
import '../../../core/theme/sypdo_widget_utils.dart';
import '../../../presentation/screens/AppSplashScreen.dart';
import '../../address/screens/Appaddress_list_screen.dart';
import '../../notification/screen/Appnotification_screen.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';
import '../../profile/bloc/profile_state.dart';
import '../../profile/screens/Appprofile_screen.dart';
import '../widgets/Applogout_confirm_dialog.dart';

class AppTabProfile extends StatefulWidget {
  const AppTabProfile({super.key});

  @override
  State<AppTabProfile> createState() => _AppTabProfileState();
}

class _AppTabProfileState extends State<AppTabProfile> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchProfile()); // 👈 Trigger on init
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(20)),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _profilePictureView(),
            const SizedBox(height: 10),
            _buildProfileOption(context, "My Profile", "profile.svg", AppProfileScreen()),
            _buildProfileOption(context, "My Address", "location.svg", AppAddressListScreen()),
            _buildProfileOption(context, "Privacy and policy", "privacy.svg", AppPrivacyScreen()),
            _buildProfileOption(context, "Terms and condition", "termuse.svg", AppTermOfUseScreen()),
            _buildProfileOption(context, "Contact support", "question.svg", AppSupportScreen()),
            // _buildProfileOption(context, "My Wallet", "wallet.svg", Routes.myWalletRoute),
            // _buildProfileOption(context, "My Subscriptions", "subscription.svg", Routes.mySubscriptionsRoute),
            // _buildProfileOption(context, "My Referrals", "refer_and_earn.svg", Routes.mySubscriptionsRoute),
            // _buildProfileOption(context, "Settings", "setting.svg", Routes.settingRoute),
            // const SizedBox(height: 30),
            const SizedBox(height: 5),

            _logoutButton(context),
            const SizedBox(height: 20),
            _deleteAccountButton(context),
          ],
        ),
      ),
    );
  }

  Widget _deleteAccountButton(BuildContext context) {
    return getButton(
      context,
      Colors.redAccent,
      "Delete Account",
      Colors.white,
      _showDeleteAccountConfirmationDialog,
      18,
      weight: FontWeight.w600,
      borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(14)),
      buttonHeight: FetchPixels.getPixelHeight(60),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Account', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AppNotificationListScreen()));
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to permanently delete your account? This action cannot be undone."),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _deleteAccount(); // Call deletion method
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _logoutButton(BuildContext context) {
    return getButton(
      context,
      primaryColor,
      "Logout",
      Colors.white,
      _showLogoutConfirmationDialog,
      18,
      weight: FontWeight.w600,
      borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(14)),
      buttonHeight: FetchPixels.getPixelHeight(60),
    );
  }

  Widget _buildProfileOption(BuildContext context, String title, String icon, Widget screen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: getButtonWithIcon(
        context,
        Colors.white,
        title,
        Colors.black,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        16,
        weight: FontWeight.w400,
        buttonHeight: FetchPixels.getPixelHeight(60),
        borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
        prefixIcon: true,
        prefixImage: icon,
        sufixIcon: true,
        suffixImage: "arrow_right.svg",
      ),
    );
  }

  // Widget _profilePictureView() {
  //   return Container(
  //     height: FetchPixels.getPixelHeight(100),
  //     width: FetchPixels.getPixelHeight(100),
  //     decoration: BoxDecoration(
  //       shape: BoxShape.circle,
  //       color: Colors.grey.shade200, // Optional background color
  //     ),
  //     child: Icon(
  //       Icons.person,
  //       size: FetchPixels.getPixelHeight(60),
  //       color: Colors.grey,
  //     ),
  //   );
  // }
  Widget _profilePictureView() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final user = state.customer;
          return Column(
            children: [
              Container(
                height: FetchPixels.getPixelHeight(130),
                width: FetchPixels.getPixelHeight(126),
                decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.grey.shade200),
                clipBehavior: Clip.antiAlias,
                child:
                // user.image != null && user.image!.isNotEmpty
                //     ? Image.network(user.image!, fit: BoxFit.cover)
                //     :
                Image.asset("assets/icon/default-avatar.png", fit: BoxFit.fill),
              ),
              const SizedBox(height: 12),
              Text((user.name ?? "-").toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: Colors.black)),
              const SizedBox(height: 2),
              Text((user.email ?? "-"), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey[800], letterSpacing: 0.2)),
              const SizedBox(height: 2),
              Text("+971 ${(user.mobile ?? "-")}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey[800], letterSpacing: 0.2)),
            ],
          );
        } else if (state is ProfileLoading) {
          return const CircularProgressIndicator();
        } else if (state is ProfileError) {
          return Text("Failed to load profile", style: TextStyle(color: Colors.red));
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLogoutConfirmationDialog(onConfirm: _logout);
      },
    );
  }

  _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      GoogleSignIn _googleSignIn = GoogleSignIn();

      prefs.remove(AppPrefResources.USER_ACCESS_TOCKEN);

      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
    } finally {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => AppSplashScreen()), (predict) => false);
    }
  }

  Future<void> _deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete(); // Deletes Firebase account
      }

      // Clear token
      prefs.remove(AppPrefResources.USER_ACCESS_TOCKEN);

      // Sign out from providers
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      // Navigate to Splash
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => AppSplashScreen()), (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showReauthRequiredDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account deletion failed: ${e.message}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showReauthRequiredDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Re-authentication Required"),
            content: const Text("Please log in again to confirm your identity before deleting your account."),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK"))],
          ),
    );
  }
}
