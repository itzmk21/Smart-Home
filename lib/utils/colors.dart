import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

const Color bg = Color(0xFF0A163B);
const Color secondaryBg = Color(0xFF111D42);
const Color secondaryFg = Color(0xFFFEFEFF);
const Color subtext = Color(0xFF9EA0A5);
const Color inactiveTrack = Color(0xFF2C3859);

Color fg = const Color(0xFF1BC6EF);
Color activeTrack = const Color(0xFF93E3F4);

Color randomColor = newRandom();

Color newRandom() {
  randomColor = [
    ...Colors.primaries,
    ...Colors.accents
  ][Random().nextInt(Colors.primaries.length)];

  if (randomColor.computeLuminance() > 0.5) {
    newRandom();
  }
  return randomColor;
}

customColors() {
  var theme = GetStorage().read("theme");

  switch (theme) {
    case 'default':
      fg = const Color(0xFF1BC6EF);
      activeTrack = const Color(0xFF93E3F4);
      break;

    case 'green':
      fg = const Color(0xFF55DD00);
      activeTrack = const Color(0xFFA2FF5D);
      break;

    case 'orange':
      fg = const Color(0xFFFFA500);
      activeTrack = const Color(0xFFFFDC4F);
      break;

    case 'random':
      newRandom();

      final hsl = HSLColor.fromColor(randomColor);

      fg = randomColor;
      activeTrack =
          hsl.withLightness((hsl.lightness + 0.1).clamp(0.0, 1.0)).toColor();

      break;

    default:
      fg = const Color(0xFF1BC6EF);
      activeTrack = const Color(0xFF93E3F4);
      break;
  }
}
