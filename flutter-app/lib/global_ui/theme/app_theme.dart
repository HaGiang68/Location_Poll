import 'package:flutter/material.dart';

import 'colors.dart';

class AppTheme {
  get darkTheme => ThemeData(
        scaffoldBackgroundColor: ColorTheme.backgroundColor,
        unselectedWidgetColor: ColorTheme.colorWhite,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(),
        colorScheme: ColorScheme.dark(
          background: ColorTheme.backgroundColor,
          onBackground: ColorTheme.colorWhite,
          surface: ColorTheme.buttonColorGrey,
          onSurface: ColorTheme.colorWhite,
          primary: ColorTheme.barColorBlue,
          onPrimary: ColorTheme.colorWhite,
          secondary: ColorTheme.buttonColorlightCyan,
          onSecondary: ColorTheme.backgroundColor,
          error: ColorTheme.buttonColorRed,
        ),
      );

  get lightTheme => ThemeData(
        scaffoldBackgroundColor: ColorTheme.backgroundColorLight,
        unselectedWidgetColor: ColorTheme.colorBlack,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(),
    colorScheme: ColorScheme.light(
      background: ColorTheme.backgroundColorLight,
      onBackground: ColorTheme.colorBlack,
      surface: ColorTheme.colorWhite,
      onSurface: ColorTheme.colorBlack,
      primary: ColorTheme.barColorBlue,
      onPrimary: ColorTheme.colorWhite,
      secondary: ColorTheme.buttonColorlightCyan,
      onSecondary: ColorTheme.backgroundColor,
      error: ColorTheme.buttonColorRed,
    ),
      );
}
