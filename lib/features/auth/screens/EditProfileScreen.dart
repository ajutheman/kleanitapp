// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../core/constants/Constant.dart';
// import '../../../core/theme/color_data.dart';
// import '../../../core/theme/resizer/fetch_pixels.dart';
// import '../../../core/theme/widget_utils.dart';
// import '../../profile/bloc/profile_bloc.dart';
// import '../../profile/bloc/profile_event.dart';
// import '../../profile/bloc/profile_state.dart';
// import '../../profile/model/customer_model.dart';
//
// class EditProfileScreen extends StatefulWidget {
//   final bool isFirstTimeGoogleLogin;
//
//   const EditProfileScreen({super.key, this.isFirstTimeGoogleLogin = false});
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//   // final nameController = TextEditingController();
//   // final emailController = TextEditingController();
//   final phoneController = TextEditingController();
//
//   bool isLoading = false;
//   String? errorMessage;
//
//   @override
//   void initState() {
//     final state = context.read<ProfileBloc>().state;
//     if (state is ProfileLoaded) {
//       // nameController.text = state.customer.name ?? "";
//       // emailController.text = state.customer.email ?? "";
//       phoneController.text = state.customer.mobile ?? "";
//     }
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => !widget.isFirstTimeGoogleLogin,
//       child: BlocListener<ProfileBloc, ProfileState>(
//         listener: (context, state) {
//           if (state is ProfileLoading) {
//             setState(() => isLoading = true);
//           } else {
//             setState(() => isLoading = false);
//           }
//
//           if (state is ProfileError) {
//             setState(() => errorMessage = state.message);
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                   content: Text("Failed: ${state.message}"),
//                   backgroundColor: Colors.red),
//             );
//           }
//
//           if (state is ProfileLoaded) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                   content: Text("Profile updated successfully"),
//                   backgroundColor: Colors.green),
//             );
//
//             // ✅ Redirect to home if this was first-time login
//             if (widget.isFirstTimeGoogleLogin) {
//               Navigator.pushNamedAndRemoveUntil(
//                   context, '/home', (route) => false);
//             } else {
//               Navigator.pop(context);
//             }
//           }
//         },
//         child:
//         Scaffold(
//           backgroundColor: backGroundColor,
//           bottomNavigationBar: saveButton(context),
//           body: SafeArea(
//             child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onTap: () => FocusScope.of(context).unfocus(), // 🔑 dismiss keyboard
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: FetchPixels.getPixelWidth(20)),
//                 child: SingleChildScrollView(
//
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       getVerSpace(20),
//                       widget.isFirstTimeGoogleLogin
//                           ? getCustomFont("   Edit Profile", 24, Colors.black, 1,
//                               fontWeight: FontWeight.w800)
//                           : gettoolbarMenu(
//                               context,
//                               "back.svg",
//                               () => Constant.backToPrev(context),
//                               istext: true,
//                               title: "Edit Profile",
//                               weight: FontWeight.w800,
//                               fontsize: 24,
//                               textColor: Colors.black,
//                             ),
//                       getVerSpace(30),
//                       profilePictureEdit(context),
//                       getVerSpace(40),
//                       // getDefaultTextFiledWithLabel(
//                       //   context,
//                       //   "Name",
//                       //   nameController,
//                       //   Colors.grey,
//                       //   isEnable: !widget.isFirstTimeGoogleLogin ? true : false,
//                       //   withprefix: true,
//                       //   image: "profile.svg",
//                       // ),
//                       getVerSpace(20),
//                       // getDefaultTextFiledWithLabel(
//                       //   context,
//                       //   "Email",
//                       //   emailController,
//                       //   Colors.grey,
//                       //   isEnable: !widget.isFirstTimeGoogleLogin ? true : false,
//                       //   withprefix: true,
//                       //   image: "message.svg",
//                       // ),
//                       getVerSpace(20),
//                       // getDefaultTextFiledWithLabel(
//                       //   context,
//                       //   "Phone",
//                       //   phoneController,
//                       //   Colors.grey,
//                       //   isEnable: true,
//                       //   withprefix: true,
//                       //   image: "call.svg",
//                       // ),
//                       getDefaultTextFiledWithLabel(
//                         context,
//                         "Phone",
//                         phoneController,
//                         Colors.grey,
//                         isEnable: true,
//                         withprefix: true,
//                         image: "call.svg",
//                         maxLength: 9,
//                         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                         keyboardType: TextInputType.number,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Container saveButton(BuildContext context) {
//     return Container(
//       color: backGroundColor,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//       child: getButton(
//         context,
//         isLoading ? Colors.grey : primaryColor,
//         isLoading ? "Saving..." : "Save",
//         Colors.white,
//         isLoading ? () {} : _saveProfile,
//         18,
//         weight: FontWeight.w600,
//         buttonHeight: 60,
//         borderRadius: BorderRadius.circular(14),
//       ),
//     );
//   }
//
//   Widget profilePictureEdit(BuildContext context) {
//     return Align(
//       alignment: Alignment.topCenter,
//       child: Container(
//         height: FetchPixels.getPixelHeight(100),
//         width: FetchPixels.getPixelHeight(100),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.grey.shade200,
//         ),
//         child: Icon(
//           Icons.person,
//           size: FetchPixels.getPixelHeight(60),
//           color: Colors.grey,
//         ),
//       ),
//     );
//   }
//
//   // void _saveProfile() {
//   //   final phone = phoneController.text.trim();
//   //   final state = context.read<ProfileBloc>().state;
//   //
//   //   if (widget.isFirstTimeGoogleLogin && phone.isEmpty) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text("Phone number is required"),
//   //         backgroundColor: Colors.red,
//   //       ),
//   //     );
//   //     return;
//   //   }
//   //
//   //   final updatedCustomer = CustomerModel(
//   //     id: 0,
//   //     // name: nameController.text.trim(),
//   //     // email: emailController.text.trim(),
//   //     mobile: phone,
//   //     status: "active",
//   //     latitude: "0",
//   //     longitude: "0",
//   //   );
//   //
//   //   context.read<ProfileBloc>().add(UpdateProfile(updatedCustomer));
//   // }
//   void _saveProfile() {
//     final phone = phoneController.text.trim();
//     final state = context.read<ProfileBloc>().state;
//
//     if (phone.length != 9) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Phone number must be exactly 9 digits."),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     final name = (state is ProfileLoaded) ? state.customer.name ?? "" : "";
//     final email = (state is ProfileLoaded) ? state.customer.email ?? "" : "";
//
//     final updatedCustomer = CustomerModel(
//       id: (state is ProfileLoaded) ? state.customer.id : 0,
//       name: name,
//       email: email,
//       mobile: phone,
//       status: "active",
//       latitude: "0",
//       longitude: "0",
//     );
//
//     context.read<ProfileBloc>().add(UpdateProfile(updatedCustomer));
//   }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/color_data.dart';
import '../../../core/theme/resizer/fetch_pixels.dart';
import '../../../core/theme/widget_utils.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';
import '../../profile/bloc/profile_state.dart';
import '../../profile/model/customer_model.dart';

class EditProfileScreen extends StatefulWidget {
  final bool isFirstTimeGoogleLogin;

  const EditProfileScreen({super.key, this.isFirstTimeGoogleLogin = false});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    final state = context.read<ProfileBloc>().state;
    // if (state is ProfileLoaded) {
    //   nameController.text = state.customer.name ?? "";
    //   emailController.text = state.customer.email ?? "";
    //   phoneController.text = state.customer.mobile ?? "";
    // }
    if (state is ProfileLoaded) {
      _setFormData(state.customer);
    } else {
      // Fallback: try to load from SharedPreferences (Google login case)
      _loadCustomerFromLocal();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !widget.isFirstTimeGoogleLogin,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          setState(() => isLoading = state is ProfileLoading);

          if (state is ProfileError) {
            setState(() => errorMessage = state.message);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: ${state.message}"), backgroundColor: Colors.red));
          }

          if (state is ProfileLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully"), backgroundColor: Colors.green));

            if (widget.isFirstTimeGoogleLogin) {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
            } else {
              Navigator.pop(context);
            }
          }
        },
        child: Scaffold(
          backgroundColor: backGroundColor,
          resizeToAvoidBottomInset: true,
          bottomNavigationBar: saveButton(context),
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getVerSpace(20),
                    Center(child: getCustomFont("Edit Profile", 26, Colors.black, 1, fontWeight: FontWeight.bold)),
                    getVerSpace(30),
                    Center(child: profilePictureEdit(context)),
                    Center(child: Text("Contact Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87))),
                    getVerSpace(40),
                    getVerSpace(20),
                    getDefaultTextFiledWithLabel(
                      context,
                      "Name",
                      nameController,
                      Colors.grey.shade600,
                      isEnable: false,
                      // !widget.isFirstTimeGoogleLogin,
                      withprefix: true,
                      image: "profile.svg",
                    ),
                    getVerSpace(20),
                    getDefaultTextFiledWithLabel(
                      context,
                      "Email",
                      emailController,
                      Colors.grey.shade600,
                      isEnable: false,
                      // !widget.isFirstTimeGoogleLogin,
                      withprefix: true,
                      image: "message.svg",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    getVerSpace(20),
                    getDefaultTextFiledWithLabel(
                      context,
                      "Phone",
                      phoneController,
                      Colors.grey.shade600,
                      isEnable: true,
                      withprefix: true,
                      image: "call.svg",
                      maxLength: 9,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    ),

                    getVerSpace(40),

                    getVerSpace(10),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(12),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.black12,
                    //         blurRadius: 8,
                    //         offset: Offset(0, 2),
                    //       ),
                    //     ],
                    //   ),
                    //   child: getDefaultTextFiledWithLabel(
                    //     context,
                    //     "Phone",
                    //     phoneController,
                    //     Colors.grey.shade600,
                    //     isEnable: true,
                    //     withprefix: true,
                    //     image: "call.svg",
                    //     maxLength: 9,
                    //     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    //     keyboardType: TextInputType.number,
                    //     textInputAction: TextInputAction.done,
                    //     onSubmitted: (_) =>
                    //         FocusScope.of(context).unfocus(),
                    //   ),
                    // ),
                    getVerSpace(100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container saveButton(BuildContext context) {
    return Container(
      color: backGroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? Colors.grey : primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(double.infinity, 56),
          elevation: 4,
        ),
        onPressed: isLoading ? null : _saveProfile,
        child:
            isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget profilePictureEdit(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          height: FetchPixels.getPixelHeight(110),
          width: FetchPixels.getPixelHeight(110),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            image: const DecorationImage(image: AssetImage("assets/icon/default-avatar.png"), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.edit, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // void _saveProfile() {
  //   final phone = phoneController.text.trim();
  //   final state = context.read<ProfileBloc>().state;
  //
  //   if (phone.length != 9) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Phone number must be exactly 9 digits."),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }
  //
  //   final name = (state is ProfileLoaded) ? state.customer.name ?? "" : "";
  //   final email = (state is ProfileLoaded) ? state.customer.email ?? "" : "";
  //
  //   final updatedCustomer = CustomerModel(
  //     id: (state is ProfileLoaded) ? state.customer.id : 0,
  //     name: name,
  //     email: email,
  //     mobile: phone,
  //     status: "active",
  //     latitude: "0",
  //     longitude: "0",
  //   );
  //
  //   context.read<ProfileBloc>().add(UpdateProfile(updatedCustomer));
  // }
  void _saveProfile() {
    final phone = phoneController.text.trim();
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (phone.length != 9) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Phone number must be exactly 9 digits."), backgroundColor: Colors.red));
      return;
    }

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name and email must not be empty."), backgroundColor: Colors.red));
      return;
    }

    final state = context.read<ProfileBloc>().state;

    final updatedCustomer = CustomerModel(
      id: (state is ProfileLoaded) ? state.customer.id : 0,
      name: name,
      email: email,
      mobile: phone,
      status: "active",
      latitude: "0",
      longitude: "0",
    );

    context.read<ProfileBloc>().add(UpdateProfile(updatedCustomer));
  }

  void _setFormData(CustomerModel customer) {
    nameController.text = customer.name ?? "";
    emailController.text = customer.email ?? "";
    phoneController.text = customer.mobile ?? "";
  }

  Future<void> _loadCustomerFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("customer_data");
    if (jsonString != null) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final customer = CustomerModel.fromJson(json);
      _setFormData(customer);
    }
  }
}
