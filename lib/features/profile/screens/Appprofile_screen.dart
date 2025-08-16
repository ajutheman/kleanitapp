import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/sypd_color.dart';
import '../../../core/theme/resizer/sypdo_fetch_pixels.dart';
import '../../../core/theme/sypdo_widget_utils.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'Appedit_profile_screen.dart';

class AppProfileScreen extends StatelessWidget {
  const AppProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<ProfileBloc>().add(FetchProfile());

    return Scaffold(
      backgroundColor: backGroundColor,
      bottomNavigationBar: editProfileButton(context),
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(20)),
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileLoaded) {
                final user = state.customer;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getVerSpace(FetchPixels.getPixelHeight(20)),
                    withoutleftIconToolbar(context, istext: true, title: "Profile", weight: FontWeight.w800, fontsize: 24, textColor: Colors.black),
                    getVerSpace(FetchPixels.getPixelHeight(30)),
                    profilePicture(context),
                    getVerSpace(FetchPixels.getPixelHeight(40)),
                    getCustomFont("Name", 16, textColor, 1),
                    getVerSpace(6),
                    getCustomFont(user.name ?? "-", 16, Colors.black, 1),
                    getVerSpace(20),
                    getDivider(dividerColor, 0, 1),
                    getVerSpace(20),
                    getCustomFont("Email", 16, textColor, 1),
                    getVerSpace(6),
                    getCustomFont(user.email ?? "-", 16, Colors.black, 1),
                    getVerSpace(20),
                    getDivider(dividerColor, 0, 1),
                    getVerSpace(20),
                    getCustomFont("Phone No", 16, textColor, 1),
                    getVerSpace(6),
                    getCustomFont(user.mobile ?? "-", 16, Colors.black, 1),
                  ],
                );
              } else if (state is ProfileError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget profilePicture(BuildContext context) {
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

  Container editProfileButton(BuildContext context) {
    return Container(
      color: backGroundColor,
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 30),
      child: getButton(
        context,
        primaryColor,
        "Edit Profile",
        Colors.white,
        () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AppEditProfileScreen()));
        },
        18,
        weight: FontWeight.w600,
        buttonHeight: 60,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
