import 'package:flutter/material.dart';

const Color blue = Color(0xFF0077E4);
const Color lightBlue = Color(0xFF80bbf2);
const Color blue3 = Color(0xFFE6F4FF);
const Color green = Color(0xFF4CC473);
const Color green2 = Color(0xFF8DD196);
const Color green3 = Color(0xFFC1ECC8);
const Color green4 = Color(0xFFECF9E9);
const Color darkBlue = Color(0xFF2D77C1);
const Color darkGreen = Color(0xFF2BB559);
const Color deepGreen = Color(0xFF1A9342);
const Color backGround = Color(0xFF2B2B2B);
const Color backGroundLight = Color(0xFF444444);
const Color backGroundDark = Color(0xFF1B1B1B);
const Color gray = Color(0xFFA1A1A1);
const Color gray2 = Color(0xFFDBDADC);
const Color gray3 = Color(0xFF9B9A9C);
const Color gray4 = Color(0xFF8A888A);
const Color gray5 = Color(0xFF575558);
const Color org = Color(0xFFFFBD56);
const Color org2 = Color(0xFFFFE8C0);
const Color yellow = Color(0xFFFFE56F);
const Color yellow2 = Color(0xFFFEFAE2);
const Color pink = Color(0xFFFE9BA7);
const Color Gf = Color(0xFFFA846C);
const Color darkGf = Color(0xFFEB583B);
const Color purple = Color(0xFFA929F3);
const List<Color> activityColors = [
  Color(0xFF4CC473), // green
  Color(0xFF75A9ED), // blue
  Color(0xFFA929F3), // purple
  Color(0xFFFFBD56), // org
  Color(0xFFD3D3D3), // gray
];
class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      fontFamily: "Pretendard",
      colorSchemeSeed: Colors.white,
      canvasColor: Colors.white,
      dividerColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      //unselectedWidgetColor: Colors.white,
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        contentTextStyle: TextStyle(fontSize: 16, color: Colors.black87),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(Colors.white),
        checkColor: WidgetStateProperty.all(Colors.blue),
        overlayColor: WidgetStateProperty.all(gray),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true),
        trackVisibility: WidgetStateProperty.all(true),
        thickness: WidgetStateProperty.all(10),
        radius: const Radius.circular(4),

        // ✔ 밝은 색상 설정
        thumbColor: WidgetStateProperty.all(Colors.white30),
        trackColor: WidgetStateProperty.all(Colors.white12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: gray),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gray2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkGf),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkGf),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: blue, width: 2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.all(gray2),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: blue,
        linearTrackColor: blue3,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: gray2, width: 1),
        ),
      ),
    );
  }
}

final ButtonStyle mainBlueElevatedButton = mainColoredElevatedButton(
    blue,
    lightBlue
);
final ButtonStyle mainRoundBlueElevatedButton = mainColoredElevatedButton(
    blue,
    lightBlue,
    radius: 999
);
final ButtonStyle mainGrayElevatedButton = mainColoredElevatedButton(
    backGroundLight,
    gray
);
final ButtonStyle mainRoundGrayElevatedButton = mainColoredElevatedButton(
    backGroundLight,
    gray,
    radius: 999
);

ButtonStyle mainColoredElevatedButton(
    Color backgroundColor,
    Color borderColor,
    {double radius = 12}
    ) {
  return ButtonStyle(
    backgroundColor: WidgetStateProperty.all(backgroundColor),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor, width: 2),
      ),
    ),
  );
}

final ButtonStyle disabledElevatedButton = ButtonStyle(
  backgroundColor: WidgetStateProperty.all(gray2),
  foregroundColor: WidgetStateProperty.all(Colors.white),
  surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
  shape: WidgetStateProperty.all(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
      side: BorderSide(color: gray3, width: 4),
    ),
  ),
);

Widget borderedText({
  required String text,
  double size = 16,
  FontWeight weight = FontWeight.normal,
  Color fillColor = Colors.white,
  Color borderColor = Colors.black,
  double strokeWidth = 3,
}) {
  return Stack(
    children: [
      // 외곽선 텍스트
      Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: weight,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = borderColor,
        ),
      ),
      // 안쪽 채워진 텍스트
      Text(
        text,
        style: TextStyle(fontSize: size, fontWeight: weight, color: fillColor),
      ),
    ],
  );
}


SizedBox defaultBackground(BuildContext context) {
  return SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(decoration: BoxDecoration(
                color: backGroundDark
            )),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/images/grid.png', // 원하는 배경 이미지
              fit: BoxFit.cover,
            ),
          ),
        ],
      )
  );
}
