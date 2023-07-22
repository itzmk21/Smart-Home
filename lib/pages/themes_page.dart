import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smart_home/widgets/theme_card.dart';

class ThemesPage extends StatefulWidget {
  const ThemesPage({Key? key}) : super(key: key);

  @override
  State<ThemesPage> createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ThemeCard(
          name: 'Default',
          accent: Color(0xFF1BC6EF),
        ),
        const ThemeCard(
          name: 'Green',
          accent: Color(0XFF64DD17),
        ),
        const ThemeCard(
          name: 'Orange',
          accent: Color(0xFFFFA500),
        ),
        ThemeCard(
          name: 'Random',
          accent: [
            ...Colors.primaries,
            ...Colors.accents
          ][Random().nextInt(Colors.primaries.length)],
        ),
      ],
    );
  }
}
