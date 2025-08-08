import 'package:flutter/cupertino.dart';
import 'package:kleanit/core/constants/legal_constants.dart';

import 'legal_page_template.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LegalPageTemplate(
      title: "Privacy Policy",
      iconPath: "back.svg",
      content: privacyPolicyContent,
    );
  }
}
