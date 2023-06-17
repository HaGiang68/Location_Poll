import 'package:flutter/material.dart';

class InputFieldDecorations {
  static InputDecoration defaultDecoration({
    required BuildContext context,
    String? labelText,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) =>
      InputDecoration(
        labelText: labelText,
        fillColor: Theme.of(context).colorScheme.surface,
        filled: true,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surface, width: 14.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surface, width: 14.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
      );
}
