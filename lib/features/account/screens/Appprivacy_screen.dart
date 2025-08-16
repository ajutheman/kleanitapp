import 'package:flutter/cupertino.dart';
import 'package:kleanitapp/core/constants/sypdo_legal_data.dart';

import 'Applegal_page_template.dart';

class AppPrivacyScreen extends StatelessWidget {
  const AppPrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLegalPageTemplate(title: "Privacy Policy", iconPath: "back.svg", content: privacyPolicyContent);
  }
}
