import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_home/utils/colors.dart';

import '../utils/sizes.dart';
import 'app_card.dart';

class ThemeCard extends StatefulWidget {
  const ThemeCard({
    Key? key,
    required this.name,
    required this.accent,
  }) : super(key: key);

  final String name;
  final Color accent;

  @override
  State<ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<ThemeCard> {
  @override
  Widget build(BuildContext context) {
    Size screen_ = screen(context);

    return Padding(
      padding: EdgeInsets.only(top: screen_.height / 26.76),
      child: AppCard(
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(screen_.width / 13.851),
                child: Text(
                  widget.name,
                  style: TextStyle(
                    color: widget.accent,
                    fontSize: screen_.width / 17.851,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screen_.width / 25.851),
                child: ElevatedButton.icon(
                  onPressed: () {
                    GetStorage().write("theme", widget.name.toLowerCase());

                    if (widget.name == 'Random') newRandom();

                    customColors();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Switched to the ${widget.name} theme',
                          style: const TextStyle(color: secondaryFg),
                        ),
                        dismissDirection: DismissDirection.horizontal,
                        backgroundColor: secondaryBg,
                        duration: const Duration(milliseconds: 1500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(widget.accent),
                  ),
                  label: const Text('Switch',
                      style: TextStyle(
                          color: secondaryFg, fontWeight: FontWeight.bold)),
                  icon: const Icon(
                    Icons.change_circle_outlined,
                    color: secondaryFg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
