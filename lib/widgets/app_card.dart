import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/sizes.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      margin: EdgeInsets.only(
        right: screen_.width / 19.6,
        left: screen_.width / 19.6,
      ),
      elevation: 0,
      color: secondaryBg,
      child: child,
    );
  }
}
