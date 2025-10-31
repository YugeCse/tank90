import 'dart:math' show Random;

import 'package:flame/extensions.dart';

/// 方向声明
class Direction {
  Direction._();

  /// 方向-上
  static final Vector2 up = Vector2(0, -1);

  /// 方向-下
  static final Vector2 down = Vector2(0, 1);

  /// 方向-左
  static final Vector2 left = Vector2(-1, 0);

  /// 方向-右
  static final Vector2 right = Vector2(1, 0);

  /// 任意一个方向
  static Vector2 random() =>
      [up, down, left, right][Random().nextIntBetween(0, 4)];
}
