import 'dart:math';

import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'icon_card.dart';
import '../utils/sizes.dart';

class DeviceCard extends StatefulWidget {
  const DeviceCard({
    Key? key,
    required this.marginRight,
    required this.marginLeft,
    required this.icon,
    required this.deviceName,
    required this.switchValue,
    required this.switchChange,
    required this.controlsPage,
  }) : super(key: key);

  final double marginRight;
  final double marginLeft;
  final IconData icon;
  final String deviceName;
  final bool switchValue;
  final void Function(bool)? switchChange;
  final Widget controlsPage;

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return SizedBox(
      width: screen_.width / 2,
      height: screen_.height / 5.3,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(33),
        ),
        margin: EdgeInsets.only(
          right: widget.marginRight,
          left: widget.marginLeft,
        ),
        elevation: 0,
        color: widget.switchValue ? fg : secondaryBg,
        child: Column(
          children: [
            Row(
              children: [
                IconCard(
                  iconCardColour: widget.switchValue ? secondaryFg : bg,
                  child: IconButton(
                    splashRadius: sqrt(screen_.height + screen_.width) / 4.23,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return widget.controlsPage;
                          },
                        ),
                      );
                    },
                    icon: Icon(
                      widget.icon,
                      color: widget.switchValue ? fg : secondaryFg,
                      size: sqrt(screen_.height + screen_.width) / 1.23, // 28
                    ),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: screen_.height / 67.326)),
            Row(
              children: [
                Padding(padding: EdgeInsets.only(left: screen_.width / 23.1)),
                Text(widget.deviceName,
                    style: TextStyle(
                      color: secondaryFg,
                      fontWeight: FontWeight.bold,
                      fontSize: screen_.width / 23.8,
                      letterSpacing: 0.2,
                    ))
              ],
            ),
            Padding(padding: EdgeInsets.only(top: screen_.height / 180)),
            Row(
              children: [
                Padding(
                    padding: EdgeInsets.only(left: screen_.width / 21.8181)),
                Text(
                  widget.switchValue ? 'On' : 'Off',
                  style: const TextStyle(
                    color: secondaryFg,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: screen_.width / 6.24)),
                Transform.scale(
                  scale: sqrt(screen_.height + screen_.width) / 30.954,
                  child: Switch(
                    value: widget.switchValue,
                    onChanged: widget.switchChange,
                    inactiveTrackColor: inactiveTrack,
                    activeTrackColor: activeTrack,
                    thumbColor: MaterialStateProperty.all<Color>(secondaryFg),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
