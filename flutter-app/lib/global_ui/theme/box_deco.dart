import 'package:flutter/material.dart';

import 'colors.dart';

class BoxDeco {
  static BoxDecoration boxDeco({BorderRadius? borderRadius}) => BoxDecoration(
      borderRadius: borderRadius,
      gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorTheme.buttonColorBlue,
            ColorTheme.buttonColorlightCyan,
          ]));
}
