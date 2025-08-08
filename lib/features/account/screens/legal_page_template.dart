import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/Constant.dart';
import '../../../core/theme/color_data.dart';
import '../../../core/theme/resizer/fetch_pixels.dart';
import '../../../core/theme/widget_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalPageTemplate extends StatelessWidget {
  final String title;
  final String iconPath;
  final String content;
  // final String userName;
  // final String userEmail;

  const LegalPageTemplate({
    Key? key,
    required this.title,
    required this.iconPath,
    required this.content,
    // required this.userName,
    // required this.userEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Constant.backToPrev(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: backGroundColor,
        body: SafeArea(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getVerSpace(FetchPixels.getPixelHeight(20)),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Constant.backToPrev(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: primaryColor,
                      ), //
                      // SvgPicture.asset("assets/images/$iconPath", height: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                getVerSpace(FetchPixels.getPixelHeight(20)),

                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        content,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                getVerSpace(FetchPixels.getPixelHeight(10)),

                if (title == "Support")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.all(18),
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _openWhatsApp(context, "+971501887853");
                          },
                          icon: Icon(Icons.chat, color: Colors.white),
                          label: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("Chat on WhatsApp",
                                style: TextStyle(fontSize: 16)),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: Size(160, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     // Container(margin: EdgeInsets.all(18),padding: EdgeInsets.all(18),
                //     //   // width: buttonWidth,
                //     //   height: 60,
                //     //   decoration: getButtonDecoration(
                //     //     primaryColor,
                //     //     borderRadius: BorderRadius.all(Radius.circular(18)),
                //     //     // shadow: boxShadow,
                //     //     // border: (18)
                //     //     //     ? Border.all(color: borderColor, width: 110!)
                //     //     //     : null,
                //     //   ),
                //     //   child: ElevatedButton.icon(
                //     //     onPressed: () {
                //     //       _openWhatsApp(context, "+917591971324");
                //     //     },
                //     //     icon: Icon(Icons.chat),
                //     //     label: Text("WhatsApp"),
                //     //     style: ElevatedButton.styleFrom(
                //     //       backgroundColor: primaryColor,
                //     //       foregroundColor: Colors.white,
                //     //     ),
                //     //   ),
                //     // ),
                //     Container(
                //       margin: EdgeInsets.all(18),
                //       padding: EdgeInsets.zero,
                //       decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(18),
                //         boxShadow: [
                //           BoxShadow(
                //             color: Colors.black.withOpacity(0.1),
                //             blurRadius: 10,
                //             offset: Offset(0, 4),
                //           ),
                //         ],
                //       ),
                //       child: ElevatedButton.icon(
                //         onPressed: () {
                //           _openWhatsApp(context, "+971501887853");
                //         },
                //         icon: Icon(Icons.chat, color: Colors.white),
                //         label: Padding(
                //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //           child: Text("Chat on WhatsApp", style: TextStyle(fontSize: 16)),
                //         ),
                //         style: ElevatedButton.styleFrom(
                //           elevation: 0,
                //           backgroundColor: primaryColor,
                //           foregroundColor: Colors.white,
                //           minimumSize: Size(160, 50),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(18),
                //           ),
                //         ),
                //       ),
                //     ),
                //
                //     SizedBox(width: 16),
                //     // ElevatedButton.icon(
                //     //   onPressed: () {
                //     //     _sendEmail(context, "ajmalmmundeth@gmail.com");
                //     //   },
                //     //   icon: Icon(Icons.email),
                //     //   label: Text("Email"),
                //     //   style: ElevatedButton.styleFrom(
                //     //     backgroundColor: Colors.blue,
                //     //     foregroundColor: Colors.white,
                //     //   ),
                //     // ),
                //   ],
                // ), getVerSpace(FetchPixels.getPixelHeight(10)), getVerSpace(FetchPixels.getPixelHeight(10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _openWhatsApp(BuildContext context, String phoneNumber) async {
  final String message =
      Uri.encodeComponent("Hello, I need support regarding your services.");
  final url = "https://wa.me/${phoneNumber.replaceAll("+", "")}?text=$message";

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Could not open WhatsApp")),
    );
  }
}

void _sendEmail(BuildContext context, String email) async {
  final Uri gmailUri = Uri.parse(
      "https://mail.google.com/mail/?view=cm&fs=1&to=$email"
      "&su=Kleanit%20Support%20Request"
      "&body=Hello%2C%20I%20need%20support%20regarding%20your%20services.%20Please%20assist.");

  // Try Gmail via explicit Android intent (best effort)
  final intentUri = Uri.parse(
      "intent://#Intent;action=android.intent.action.SENDTO;"
      "package=com.google.android.gm;scheme=mailto;"
      "S.email=$email;"
      "S.subject=Kleanit%20Support%20Request;"
      "S.body=Hello,%20I%20need%20support%20regarding%20your%20services.%20Please%20assist.;"
      "end");

  try {
    if (await canLaunchUrl(intentUri)) {
      await launchUrl(intentUri);
    } else if (await canLaunchUrl(gmailUri)) {
      await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No email app or Gmail browser support found.")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Could not open email client.")),
    );
  }
}
