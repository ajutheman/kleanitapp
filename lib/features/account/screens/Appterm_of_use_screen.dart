import 'package:flutter/material.dart';
import 'package:kleanitapp/core/constants/sypdo_legal_data.dart';

import 'Applegal_page_template.dart';

class AppTermOfUseScreen extends StatelessWidget {
  const AppTermOfUseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLegalPageTemplate(title: "Terms of Use", iconPath: "back.svg", content: termsOfUseContent);
  }
}
