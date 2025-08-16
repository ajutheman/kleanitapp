import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kleanitapp/core/theme/resizer/fetch_pixels.dart';

// import 'package:flutter_svg/flutter_svg.dart';

import '../constants/Constant.dart';
import 'color_data.dart';

Widget getVerSpace(double verSpace) {
  return SizedBox(height: verSpace);
}

Widget getAssetImage(String image, double width, double height, {Color? color, BoxFit boxFit = BoxFit.fill}) {
  return Image.asset(Constant.assetImagePath + image, color: color, width: width, height: height, fit: boxFit, scale: FetchPixels.getScale());
}

Widget getSvgImage(String image, {double? width, double? height, Color? color, BoxFit boxFit = BoxFit.contain}) {
  return SvgPicture.asset(Constant.assetImagePath + image, color: color, width: width, height: height, fit: boxFit);
}

Widget getPaddingWidget(EdgeInsets edgeInsets, Widget widget) {
  return Padding(padding: edgeInsets, child: widget);
}

DecorationImage getDecorationAssetImage(BuildContext buildContext, String image, {BoxFit fit = BoxFit.contain}) {
  return DecorationImage(image: AssetImage((Constant.assetImagePath) + image), fit: fit, scale: FetchPixels.getScale());
}

Widget getCustomFont(
  String text,
  double fontSize,
  Color fontColor,
  int maxLine, {
  String fontFamily = Constant.fontsFamily,
  TextOverflow overflow = TextOverflow.ellipsis,
  TextDecoration decoration = TextDecoration.none,
  FontWeight fontWeight = FontWeight.normal,
  TextAlign textAlign = TextAlign.start,
  txtHeight,
}) {
  return Text(
    text,
    overflow: overflow,
    style: TextStyle(decoration: decoration, fontSize: fontSize, fontStyle: FontStyle.normal, color: fontColor, fontFamily: fontFamily, height: txtHeight, fontWeight: fontWeight),
    maxLines: maxLine,
    softWrap: true,
    textAlign: textAlign,
    textScaleFactor: FetchPixels.getTextScale(),
  );
}

Widget getMultilineCustomFont(
  String text,
  double fontSize,
  Color fontColor, {
  String fontFamily = Constant.fontsFamily,
  TextOverflow overflow = TextOverflow.ellipsis,
  TextDecoration decoration = TextDecoration.none,
  FontWeight fontWeight = FontWeight.normal,
  TextAlign textAlign = TextAlign.start,
  int? maxLine,
  txtHeight = 1.0,
}) {
  return Text(
    text,
    maxLines: maxLine,
    style: TextStyle(
      decoration: decoration,
      fontSize: fontSize,
      fontStyle: FontStyle.normal,
      color: fontColor,
      fontFamily: fontFamily,
      height: txtHeight,
      fontWeight: fontWeight,
      overflow: TextOverflow.ellipsis,
    ),
    textAlign: textAlign,
    textScaleFactor: FetchPixels.getTextScale(),
  );
}

BoxDecoration getButtonDecoration(Color bgColor, {BorderRadius? borderRadius, Border? border, List<BoxShadow> shadow = const [], DecorationImage? image}) {
  return BoxDecoration(color: bgColor, borderRadius: borderRadius, border: border, boxShadow: shadow, image: image);
}

Widget getButton(
  BuildContext context,
  Color bgColor,
  String text,
  Color textColor,
  Function function,
  double fontsize, {
  bool isBorder = false,
  EdgeInsetsGeometry? insetsGeometry,
  borderColor = Colors.transparent,
  FontWeight weight = FontWeight.bold,
  bool isIcon = false,
  String? image,
  Color? imageColor,
  double? imageWidth,
  double? imageHeight,
  bool smallFont = false,
  double? buttonHeight,
  double? buttonWidth,
  List<BoxShadow> boxShadow = const [],
  EdgeInsetsGeometry? insetsGeometrypadding,
  BorderRadius? borderRadius,
  double? borderWidth,
}) {
  return InkWell(
    onTap: () {
      function();
    },
    child: Container(
      margin: insetsGeometry,
      padding: insetsGeometrypadding,
      width: buttonWidth,
      height: buttonHeight,
      decoration: getButtonDecoration(bgColor, borderRadius: borderRadius, shadow: boxShadow, border: (isBorder) ? Border.all(color: borderColor, width: borderWidth!) : null),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (isIcon) ? getSvgImage(image!) : getHorSpace(0),
          (isIcon) ? getHorSpace(FetchPixels.getPixelWidth(10)) : getHorSpace(0),
          getCustomFont(text, fontsize, textColor, 1, textAlign: TextAlign.center, fontWeight: weight, fontFamily: Constant.fontsFamily),
        ],
      ),
    ),
  );
}

Widget getButtonWithIcon(
  BuildContext context,
  Color bgColor,
  String text,
  Color textColor,
  Function function,
  double fontsize, {
  bool isBorder = false,
  EdgeInsetsGeometry? insetsGeometry,
  borderColor = Colors.transparent,
  FontWeight weight = FontWeight.bold,
  bool prefixIcon = false,
  bool sufixIcon = false,
  String? prefixImage,
  String? suffixImage,
  Color? imageColor,
  double? imageWidth,
  double? imageHeight,
  bool smallFont = false,
  double? buttonHeight,
  double? buttonWidth,
  List<BoxShadow> boxShadow = const [],
  EdgeInsetsGeometry? insetsGeometrypadding,
  BorderRadius? borderRadius,
  double? borderWidth,
  String fontFamily = Constant.fontsFamily,
}) {
  return InkWell(
    onTap: () {
      function();
    },
    child: Container(
      margin: insetsGeometry,
      padding: insetsGeometrypadding,
      width: buttonWidth,
      height: buttonHeight,
      decoration: getButtonDecoration(bgColor, borderRadius: borderRadius, shadow: boxShadow, border: (isBorder) ? Border.all(color: borderColor, width: borderWidth!) : null),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              getHorSpace(FetchPixels.getPixelWidth(18)),
              (prefixIcon) ? getSvgImage(prefixImage!) : getHorSpace(0),
              (prefixIcon) ? getHorSpace(FetchPixels.getPixelWidth(12)) : getHorSpace(0),
              getCustomFont(text, fontsize, textColor, 1, textAlign: TextAlign.center, fontWeight: weight, fontFamily: fontFamily),
            ],
          ),
          Row(children: [(sufixIcon) ? getSvgImage(suffixImage!) : getHorSpace(0), (sufixIcon) ? getHorSpace(FetchPixels.getPixelWidth(18)) : getHorSpace(0)]),
        ],
      ),
    ),
  );
}

// Updated function with a new parameter: keyboardType.
// Widget getDefaultTextFiledWithLabel(
//   BuildContext context,
//   String s,
//   TextEditingController textEditingController,
//   Color fontColor, {
//   bool withprefix = false,
//   bool withSufix = false,
//   bool minLines = false,
//   EdgeInsetsGeometry margin = EdgeInsets.zero,
//   bool isPass = false,
//   bool isEnable = true,
//   double? height,
//   double? imageHeight,
//   double? imageWidth,
//   String? image,
//   String? suffiximage,
//   Function? imagefunction,
//   AlignmentGeometry alignmentGeometry = Alignment.centerLeft,
//   TextInputType? keyboardType, // New parameter for keyboard type.
//   List<TextInputFormatter>? inputFormatters, // ✅ NEW
//   int? maxLength, // ✅ NEW
//       TextInputAction? textInputAction,            // ✅ NEW
//       Function(String)? onSubmitted,               // ✅ NEW
//       FocusNode? focusNode,                        // ✅ NEW
// }) {
//   FocusNode myFocusNode = FocusNode();
//
//   return StatefulBuilder(
//     builder: (context, setState) {
//       final mqData = MediaQuery.of(context);
//       final mqDataNew =
//           mqData.copyWith(textScaleFactor: FetchPixels.getTextScale());
//
//       return AbsorbPointer(
//         // If isEnable is true, do NOT absorb pointers.
//         absorbing: !isEnable,
//         child: Container(
//           height: height,
//           margin: margin,
//           alignment: alignmentGeometry,
//           decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: const [
//                 BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0.0, 4.0)),
//               ],
//               borderRadius:
//                   BorderRadius.circular(FetchPixels.getPixelHeight(12))),
//           child: Focus(
//               onFocusChange: (hasFocus) {
//                 setState(() {
//                   myFocusNode.canRequestFocus = hasFocus;
//                 });
//               },
//               child: MediaQuery(
//                 data: mqDataNew,
//                 child: Row(
//                   children: [
//                     (!withprefix)
//                         ? SizedBox(width: FetchPixels.getPixelWidth(16))
//                         : Padding(
//                             padding: EdgeInsets.only(
//                                 right: FetchPixels.getPixelWidth(12),
//                                 left: FetchPixels.getPixelWidth(18)),
//                             child: getSvgImage(image!,
//                                 height: FetchPixels.getPixelHeight(24),
//                                 width: FetchPixels.getPixelHeight(24)),
//                           ),
//                     Expanded(
//                       child: TextField(
//                         keyboardType: keyboardType, // Pass the keyboard type.
//                         maxLines: (minLines) ? null : 1,
//                         maxLength: maxLength, // ✅ new
//                         inputFormatters: inputFormatters, // ✅ new
//
//                         controller: textEditingController,
//                         obscuringCharacter: "*",
//                         autofocus: false,
//                         focusNode: myFocusNode,
//                         obscureText: isPass,
//                         showCursor: true,
//                         onTap: () {
//                           // Optionally execute function
//                         },
//                         style: const TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.w400,
//                             fontSize: 16,
//                             fontFamily: Constant.fontsFamily),
//                         decoration: InputDecoration(
//                           contentPadding: EdgeInsets.zero,
//                           border: InputBorder.none,
//                           counterText: "", // ✅ hides character counter
//                           hintText: s,
//                           hintStyle: TextStyle(
//                               color: fontColor,
//                               fontWeight: FontWeight.w400,
//                               fontSize: 16,
//                               fontFamily: Constant.fontsFamily),
//                         ),
//                       ),
//                     ),
//                     (!withSufix)
//                         ? SizedBox(width: FetchPixels.getPixelWidth(16))
//                         : Padding(
//                             padding: EdgeInsets.only(
//                                 right: FetchPixels.getPixelWidth(18),
//                                 left: FetchPixels.getPixelWidth(12)),
//                             child: InkWell(
//                               onTap: () {
//                                 if (imagefunction != null) {
//                                   imagefunction();
//                                 }
//                               },
//                               child: getSvgImage(suffiximage!,
//                                   height: FetchPixels.getPixelHeight(24),
//                                   width: FetchPixels.getPixelHeight(24)),
//                             ),
//                           ),
//                   ],
//                 ),
//               )),
//         ),
//       );
//     },
//   );
// }

Widget getDefaultTextFiledWithLabel(
  BuildContext context,
  String s,
  TextEditingController textEditingController,
  Color fontColor, {
  bool withprefix = false,
  bool withSufix = false,
  bool minLines = false,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
  bool isPass = false,
  bool isEnable = true,
  double? height,
  double? imageHeight,
  double? imageWidth,
  String? image,
  String? suffiximage,
  Function? imagefunction,
  AlignmentGeometry alignmentGeometry = Alignment.centerLeft,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  int? maxLength,
  TextInputAction? textInputAction, // ✅ NEW
  Function(String)? onSubmitted, // ✅ NEW
  FocusNode? focusNode, // ✅ NEW
}) {
  final localFocusNode = focusNode ?? FocusNode();

  return StatefulBuilder(
    builder: (context, setState) {
      final mqData = MediaQuery.of(context);
      final mqDataNew = mqData.copyWith(textScaleFactor: FetchPixels.getTextScale());

      return AbsorbPointer(
        absorbing: !isEnable,
        child: Container(
          height: height,
          margin: margin,
          alignment: alignmentGeometry,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0))],
            borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
          ),
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                localFocusNode.canRequestFocus = hasFocus;
              });
            },
            child: MediaQuery(
              data: mqDataNew,
              child: Row(
                children: [
                  (!withprefix)
                      ? SizedBox(width: FetchPixels.getPixelWidth(16))
                      : Padding(
                        padding: EdgeInsets.only(right: FetchPixels.getPixelWidth(12), left: FetchPixels.getPixelWidth(18)),
                        child: getSvgImage(image!, height: FetchPixels.getPixelHeight(24), width: FetchPixels.getPixelHeight(24)),
                      ),
                  Expanded(
                    child: TextField(
                      keyboardType: keyboardType,
                      maxLines: minLines ? null : 1,
                      maxLength: maxLength,
                      inputFormatters: inputFormatters,
                      controller: textEditingController,
                      obscuringCharacter: "*",
                      autofocus: false,
                      focusNode: localFocusNode,
                      obscureText: isPass,
                      showCursor: true,
                      textInputAction: textInputAction,
                      // ✅
                      onSubmitted: onSubmitted,
                      // ✅
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16, fontFamily: Constant.fontsFamily),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        counterText: "",
                        hintText: s,
                        hintStyle: TextStyle(color: fontColor, fontWeight: FontWeight.w400, fontSize: 16, fontFamily: Constant.fontsFamily),
                      ),
                    ),
                  ),
                  (!withSufix)
                      ? SizedBox(width: FetchPixels.getPixelWidth(16))
                      : Padding(
                        padding: EdgeInsets.only(right: FetchPixels.getPixelWidth(18), left: FetchPixels.getPixelWidth(12)),
                        child: InkWell(
                          onTap: () {
                            if (imagefunction != null) {
                              imagefunction();
                            }
                          },
                          child: getSvgImage(suffiximage!, height: FetchPixels.getPixelHeight(24), width: FetchPixels.getPixelHeight(24)),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget getCardDateTextField(
  BuildContext context,
  String s,
  TextEditingController textEditingController,
  Color fontColor, {
  bool minLines = false,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
  bool isPass = false,
  bool isEnable = true,
  double? height,
  required Function function,
}) {
  FocusNode myFocusNode = FocusNode();
  return StatefulBuilder(
    builder: (context, setState) {
      final mqData = MediaQuery.of(context);
      final mqDataNew = mqData.copyWith(textScaleFactor: FetchPixels.getTextScale());

      return AbsorbPointer(
        absorbing: isEnable,
        child: Container(
          height: height,
          margin: margin,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(18)),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0))],
            borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
          ),
          child: Focus(
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  myFocusNode.canRequestFocus = true;
                });
              } else {
                setState(() {
                  myFocusNode.canRequestFocus = false;
                });
              }
            },
            child: MediaQuery(
              data: mqDataNew,
              child: TextField(
                maxLines: (minLines) ? null : 1,
                controller: textEditingController,
                obscuringCharacter: "*",
                autofocus: false,
                focusNode: myFocusNode,
                obscureText: isPass,
                showCursor: false,
                onTap: () {
                  function();
                },
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16, fontFamily: Constant.fontsFamily),
                // textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: s,
                  hintStyle: TextStyle(color: textColor, fontWeight: FontWeight.w400, fontSize: 16, fontFamily: Constant.fontsFamily),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var inputText = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var bufferString = StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      bufferString.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 4 == 0 && nonZeroIndexValue != inputText.length) {
        bufferString.write(' ');
      }
    }

    var string = bufferString.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

Widget getCardEditText(
  BuildContext context,
  String s,
  TextEditingController textEditingController,
  Color fontColor, {
  bool withprefix = false,
  bool withSufix = false,
  bool minLines = false,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
  bool isPass = false,
  bool isEnable = true,
  double? height,
  double? imageHeight,
  double? imageWidth,
  String? image,
  String? suffiximage,
  required Function function,
  Function? imagefunction,
}) {
  FocusNode myFocusNode = FocusNode();
  return StatefulBuilder(
    builder: (context, setState) {
      final mqData = MediaQuery.of(context);
      final mqDataNew = mqData.copyWith(textScaleFactor: FetchPixels.getTextScale());

      return AbsorbPointer(
        absorbing: isEnable,
        child: Container(
          height: height,
          margin: margin,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0))],
            borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
          ),
          child: Focus(
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  myFocusNode.canRequestFocus = true;
                });
              } else {
                setState(() {
                  myFocusNode.canRequestFocus = false;
                });
              }
            },
            child: MediaQuery(
              data: mqDataNew,
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardNumberFormatter()],
                maxLines: (minLines) ? null : 1,
                controller: textEditingController,
                maxLength: 19,
                obscuringCharacter: "*",
                autofocus: false,
                focusNode: myFocusNode,
                obscureText: isPass,
                showCursor: false,
                onTap: () {
                  function();
                },
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16, fontFamily: Constant.fontsFamily),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  counterText: "",
                  prefixIcon:
                      (withprefix)
                          ? Padding(
                            padding: EdgeInsets.only(right: FetchPixels.getPixelWidth(12), left: FetchPixels.getPixelWidth(18)),
                            child: getSvgImage(image!, height: FetchPixels.getPixelHeight(24), width: FetchPixels.getPixelHeight(24)),
                          )
                          : null,
                  suffixIcon:
                      (withSufix)
                          ? Padding(
                            padding: EdgeInsets.only(right: FetchPixels.getPixelWidth(18), left: FetchPixels.getPixelWidth(12)),
                            child: InkWell(
                              onTap: () {
                                imagefunction!();
                              },
                              child: getSvgImage(suffiximage!, height: FetchPixels.getPixelHeight(24), width: FetchPixels.getPixelHeight(24)),
                            ),
                          )
                          : null,
                  border: InputBorder.none,
                  hintText: s,
                  hintStyle: TextStyle(color: textColor, fontWeight: FontWeight.w400, fontSize: 16, fontFamily: Constant.fontsFamily),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget getCountryTextField(
  BuildContext context,
  String s,
  TextEditingController textEditingController,
  Color fontColor,
  String code, {
  bool withprefix = false,
  bool withSufix = false,
  bool minLines = false,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
  bool isPass = false,
  bool isEnable = true,
  double? height,
  String? image,
  required Function function,
  Function? imagefunction,
}) {
  FocusNode myFocusNode = FocusNode();
  return StatefulBuilder(
    builder: (context, setState) {
      final mqData = MediaQuery.of(context);
      final mqDataNew = mqData.copyWith(textScaleFactor: FetchPixels.getTextScale());

      return AbsorbPointer(
        absorbing: isEnable,
        child: Container(
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0))],
            borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              getHorSpace(FetchPixels.getPixelWidth(18)),
              getAssetImage(image!, FetchPixels.getPixelHeight(24), FetchPixels.getPixelHeight(24)),
              getHorSpace(FetchPixels.getPixelWidth(12)),
              getCustomFont(code, 16, Colors.black, 1, fontWeight: FontWeight.w400, fontFamily: Constant.fontsFamily),
              getSvgImage("down_arrow.svg"),
              getHorSpace(FetchPixels.getPixelWidth(20)),
              Expanded(
                child: MediaQuery(
                  data: mqDataNew,
                  child: TextField(
                    maxLines: (minLines) ? null : 1,
                    controller: textEditingController,
                    obscuringCharacter: "*",
                    autofocus: false,
                    focusNode: myFocusNode,
                    obscureText: isPass,
                    showCursor: false,
                    onTap: () {
                      function();
                    },
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16, fontFamily: Constant.fontsFamily),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: s,
                      hintStyle: TextStyle(color: textColor, fontWeight: FontWeight.w400, fontSize: 16, fontFamily: Constant.fontsFamily),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget getSearchWidget(
  BuildContext context,
  TextEditingController searchController,
  Function filterClick,
  ValueChanged<String> onChanged, {
  bool withPrefix = true,
  ValueChanged<String>? onSubmit,
}) {
  double height = FetchPixels.getPixelHeight(60);

  final mqData = MediaQuery.of(context);
  final mqDataNew = mqData.copyWith(textScaleFactor: FetchPixels.getTextScale());

  return Container(
    width: double.infinity,
    height: height,
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0.0, 4.0))],
      borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(right: FetchPixels.getPixelWidth(18), left: FetchPixels.getPixelWidth(19)),
          child: getSvgImage("search.svg", height: FetchPixels.getPixelHeight(24), width: FetchPixels.getPixelHeight(24)),
        ),
        Expanded(
          child: MediaQuery(
            data: mqDataNew,
            child: IntrinsicHeight(
              child: TextField(
                onTap: () {
                  filterClick();
                },
                onSubmitted: onSubmit,
                textInputAction: TextInputAction.search,
                controller: searchController,
                onChanged: onChanged,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "Search...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: textColor, fontWeight: FontWeight.w400, fontSize: 16, fontFamily: Constant.fontsFamily),
                ),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16, fontFamily: Constant.fontsFamily),
                textAlign: TextAlign.start,
                maxLines: 1,
              ),
            ),
          ),
          flex: 1,
        ),
        getHorSpace(FetchPixels.getPixelWidth(3)),
      ],
    ),
  );
}

Widget gettoolbarMenu(
  BuildContext context,
  String image,
  Function function, {
  bool istext = false,
  double? fontsize,
  String? title,
  Color? textColor,
  FontWeight? weight,
  String fontFamily = Constant.fontsFamily,
  bool isrightimage = false,
  String? rightimage,
  Function? rightFunction,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      InkWell(
        onTap: () {
          function();
        },
        child: getSvgImage(image, height: FetchPixels.getPixelHeight(24), width: FetchPixels.getPixelHeight(24)),
      ),
      Expanded(
        child: Container(alignment: Alignment.center, child: (istext) ? getCustomFont(title!, fontsize!, textColor!, 1, fontWeight: weight!, fontFamily: fontFamily) : null),
      ),
      (isrightimage)
          ? InkWell(
            onTap: () {
              rightFunction!();
            },
            child: getSvgImage(rightimage!, height: FetchPixels.getPixelHeight(24), width: FetchPixels.getPixelHeight(24)),
          )
          : Container(),
    ],
  );
}

Widget withoutleftIconToolbar(
  BuildContext context, {
  bool istext = false,
  double? fontsize,
  String? title,
  Color? textColor,
  FontWeight? weight,
  String fontFamily = Constant.fontsFamily,
  bool isrightimage = false,
  String? rightimage,
  Function? rightFunction,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Container(alignment: Alignment.center, child: (istext) ? getCustomFont(title!, fontsize!, textColor!, 1, fontWeight: weight!, fontFamily: fontFamily) : null),
      ),
      (isrightimage)
          ? InkWell(
            onTap: () {
              rightFunction!();
            },
            child: getSvgImage(rightimage!, height: FetchPixels.getPixelHeight(24), width: FetchPixels.getPixelHeight(24)),
          )
          : Container(),
    ],
  );
}

Widget getHorSpace(double verSpace) {
  return SizedBox(width: verSpace);
}

Widget getDivider(Color color, double height, double thickness) {
  return Divider(color: color, height: height, thickness: thickness);
}
