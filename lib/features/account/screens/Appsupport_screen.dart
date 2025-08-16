import 'package:flutter/material.dart';
import 'package:kleanitapp/core/constants/sypdo_legal_data.dart';

import 'Applegal_page_template.dart';

class AppSupportScreen extends StatelessWidget {
  const AppSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLegalPageTemplate(title: "Support", iconPath: "back.svg", content: supportContent);
  }
}
