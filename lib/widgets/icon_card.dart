import 'package:flutter/material.dart';
import '../utils/sizes.dart';

class IconCard extends StatelessWidget {
  const IconCard({
    Key? key,
    required this.child,
    required this.iconCardColour,
  }) : super(key: key);

  final Widget child;
  final Color iconCardColour;

  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return SizedBox(
      width: screen_.width / 5, //76
      height: screen_.height / 12.95,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.only(
          right: screen_.width / 28.05,
          left: screen_.width / 28.05,
          top: screen_.height / 53.527,
        ),
        elevation: 0,
        color: iconCardColour,
        child: child,
      ),
    );
  }
}
