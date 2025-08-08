import 'package:flutter/material.dart';
import 'package:kleanit/core/constants/legal_constants.dart';

import 'legal_page_template.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LegalPageTemplate(
      title: "Support",
      iconPath: "back.svg",
      content: supportContent,
    );
  }
}
