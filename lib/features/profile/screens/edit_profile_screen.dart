import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/Constant.dart';
import '../../../core/theme/color_data.dart';
import '../../../core/theme/resizer/fetch_pixels.dart';
import '../../../core/theme/widget_utils.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../model/customer_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

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
    if (state is ProfileLoaded) {
      nameController.text = state.customer.name ?? "";
      emailController.text = state.customer.email ?? "";
      phoneController.text = state.customer.mobile ?? "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoading) {
          setState(() => isLoading = true);
        } else {
          setState(() => isLoading = false);
        }

        if (state is ProfileError) {
          setState(() => errorMessage = state.message);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: ${state.message}"), backgroundColor: Colors.red));
        }

        if (state is ProfileLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully"), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: backGroundColor,
        bottomNavigationBar: saveButton(context),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getVerSpace(20),
                gettoolbarMenu(
                  context,
                  "back.svg",
                  () => Constant.backToPrev(context),
                  istext: true,
                  title: "Edit Profile",
                  weight: FontWeight.w800,
                  fontsize: 24,
                  textColor: Colors.black,
                ),
                getVerSpace(30),
                profilePictureEdit(context),
                getVerSpace(40),
                getDefaultTextFiledWithLabel(context, "Name", nameController, Colors.grey, isEnable: true, withprefix: true, image: "profile.svg"),
                getVerSpace(20),
                getDefaultTextFiledWithLabel(context, "Email", emailController, Colors.grey, isEnable: true, withprefix: true, image: "message.svg"),
                getVerSpace(20),
                getDefaultTextFiledWithLabel(context, "Phone", phoneController, Colors.grey, isEnable: true, withprefix: true, image: "call.svg"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container saveButton(BuildContext context) {
    return Container(
      color: backGroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: getButton(
        context,
        isLoading ? Colors.grey : primaryColor,
        isLoading ? "Saving..." : "Save",
        Colors.white,
        isLoading ? () {} : _saveProfile,
        18,
        weight: FontWeight.w600,
        buttonHeight: 60,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget profilePictureEdit(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: FetchPixels.getPixelHeight(100),
        width: FetchPixels.getPixelHeight(100),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200, // Optional background color
        ),
        child: Icon(Icons.person, size: FetchPixels.getPixelHeight(60), color: Colors.grey),
      ),
    );
  }

  void _saveProfile() {
    final updatedCustomer = CustomerModel(
      id: 0,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      mobile: phoneController.text.trim(),
      status: "active",
      latitude: "0",
      longitude: "0",
    );

    context.read<ProfileBloc>().add(UpdateProfile(updatedCustomer));
  }
}
