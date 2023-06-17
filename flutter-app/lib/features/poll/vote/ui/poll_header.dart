import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/home/home_module.dart';
import 'package:location_poll/global_ui/theme/box_deco.dart';
import 'package:location_poll/global_ui/theme/text_styles.dart';

class PollHeader extends StatelessWidget {
  const PollHeader({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: BoxDeco.boxDeco(),
        padding:
            const EdgeInsets.only(left: 48, right: 48, bottom: 48, top: 75),
        child: Center(
          child: Text(
            text,
            style: OwnTextStylesBlackBold.ownTextStyle(),
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.only(left: 0, top: 30),
        child: SafeArea(
          child: IconButton(
            onPressed: () {
              Modular.to.navigate(HomeModule.routeName);
            },
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
        ),
      ),
    ]);
  }
}
