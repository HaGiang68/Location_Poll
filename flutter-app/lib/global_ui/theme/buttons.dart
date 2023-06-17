import 'package:flutter/material.dart';

class ButtonStyles {
  static ButtonStyle fullSizeButton(
          {MaterialStateProperty<Color>? backgroundColor}) =>
      ButtonStyle(
        backgroundColor: backgroundColor,
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
}
