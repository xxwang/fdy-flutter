import 'dart:math';

import 'package:flutter/material.dart';

class ColorUtils {
  /// 生成ARGB随机颜色,Alpha固定255
  static Color get random {
    return Color.fromARGB(
      255,
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
    );
  }
}
