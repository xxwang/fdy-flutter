import 'dart:math';

import 'package:flutter/material.dart';

/// 颜色扩展
extension ColorExt on Color {
  /// 生成ARGB随机颜色,Alpha固定255
  static Color get random {
    return Color.fromARGB(
      255,
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
    );
  }

  /// 使用十六进制颜色字符串创建Color
  static Color fromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}
