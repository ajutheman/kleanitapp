import 'package:flutter/material.dart';
import 'package:kleanitapp/core/constants/legal_constants.dart';

import 'legal_page_template.dart';

class TermOfUseScreen extends StatelessWidget {
  const TermOfUseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LegalPageTemplate(title: "Terms of Use", iconPath: "back.svg", content: termsOfUseContent);
  }
}
