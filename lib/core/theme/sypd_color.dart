import 'dart:ui';

// const Color primaryColor = Color(0xFF0F3D4A); // Dark Teal
const Color accentColor = Color(0xFF065971); // Aqua Blue
Color backGroundColor = "#FFFFFF".toColor();
// Color primaryColor = "#23408F".toColor();
// Color primaryColor = "00424f".toColor();
Color primaryColor = Color.fromRGBO(0, 58, 69, 1);
// Color primaryColor = Color(0xFF077975);
// Color primaryColor = Color(0xFF23408f);
Color intro1Color = "#FFC8CF".toColor();
Color intro2Color = "#E5ECFF".toColor();
Color intro3Color = "#F7FBCD".toColor();
Color dividerColor = "#E5E8F1".toColor();
Color textColor = "#7F889E".toColor();
// Color textColor = "#7F889E".toColor();
Color deatilColor = "#D3DFFF".toColor();
Color listColor = "#EEF1F9".toColor();
Color procced = "#E2EAFF".toColor();
Color success = "#04B155".toColor();
Color completed = "#0085FF".toColor();
Color error = "#FF2323".toColor();

extension ColorExtension on String {
  toColor() {
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}
