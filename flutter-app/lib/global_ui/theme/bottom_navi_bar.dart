import 'package:flutter/material.dart';

import 'colors.dart';

enum SelectedButton {
  polls,
  ownPolls,
  pollsMap,
  settings,
  createPoll,
}

/// Custom Bottom Navigation Bar
class BottomNaviBar extends StatelessWidget {
  const BottomNaviBar({
    Key? key,
    required this.onButtonPressed,
  }) : super(key: key);

  final Function(SelectedButton selectedButton) onButtonPressed;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size(size.width, 80),
            painter: BNBCustomPainter(),
          ),
          Center(
            heightFactor: 0.6,
            child: FloatingActionButton(
              //backgroundColor: ColorTheme.buttonColorlightCyan,
              child: const Icon(Icons.add),
              elevation: 0.1,
              onPressed: () => onButtonPressed(SelectedButton.createPoll),
            ),
          ),
          SizedBox(
            width: size.width,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () => onButtonPressed(SelectedButton.polls),
                    icon: Icon(
                      Icons.list,
                      color: ColorTheme.colorWhite,
                    )),
                IconButton(
                    onPressed: () => onButtonPressed(SelectedButton.ownPolls),
                    icon: Icon(
                      Icons.note_alt_outlined,
                      color: ColorTheme.colorWhite,
                    )),
                Container(
                  width: size.width * 0.20,
                ),
                IconButton(
                    onPressed: () => onButtonPressed(SelectedButton.pollsMap),
                    icon: Icon(
                      Icons.location_on_outlined,
                      color: ColorTheme.colorWhite,
                    )),
                IconButton(
                    onPressed: () => onButtonPressed(SelectedButton.settings),
                    icon: Icon(
                      Icons.settings,
                      color: ColorTheme.colorWhite,
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = ColorTheme.navigationBarColorBlue
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.quadraticBezierTo(size.width * 0.2, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.4, 0, size.width * 0.4, 20);
    path.arcToPoint(Offset(size.width * 0.6, 20),
        radius: const Radius.circular(20.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.6, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.8, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, ColorTheme.backgroundColor, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
