import 'package:flutter/material.dart';

import 'colors.dart';

class OwnTextStylesDarkM {
  static TextStyle ownTextStyle() => TextStyle(
        fontSize: 34,
        color: ColorTheme.colorWhite,
      );
}

class OwnTextStylesLightM {
  static TextStyle ownTextStyle() => TextStyle(
        fontSize: 34,
        color: ColorTheme.colorBlack,
      );
}

class OwnTextStylesBlackBold {
  static TextStyle ownTextStyle() => TextStyle(
        fontSize: 34,
        color: ColorTheme.colorBlack,
        fontWeight: FontWeight.bold,
      );
}

class ListTileStyles {
  static TextStyle ownTextStyle(BuildContext context) => TextStyle(
        fontSize: 20,
        color: Theme.of(context).colorScheme.onBackground,
      );
}

class StatsStyles {
  static TextStyle ownTextStyle() => TextStyle(
        fontSize: 18,
        color: ColorTheme.colorWhite,
      );
}

class StatsStylesLightM {
  static TextStyle ownTextStyle() => TextStyle(
        fontSize: 18,
        color: ColorTheme.colorBlack,
      );
}

class ButtonTextStylesBlack {
  static TextStyle buttonTextStyle() => TextStyle(
        fontSize: 25,
        color: ColorTheme.colorBlack,
        fontWeight: FontWeight.bold,
      );
}

class ButtonTextStylesWhite {
  static TextStyle buttonTextStyle() => TextStyle(
        fontSize: 25,
        color: ColorTheme.colorWhite,
        fontWeight: FontWeight.bold,
      );
}
