// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:flame/game.dart';

/// 常量
class GameConstants {
  GameConstants._();

  /// 敌人最大数量: 20
  static const ENEMEY_MAX_COUNT = 20;

  /// 每场战场同时出现的敌方坦克数量: 5
  static const ENEMY_PER_WAR_COUNT = 5;

  /// 敌方红坦克数量：3
  static const ENEMY_RED_FLICKER_COUNT = 3;

  /// 地图像素尺寸
  static final Vector2 MAP_SIZE = Vector2(416, 416);

  /// 地图表格数据：WxH
  static final Vector2 MAP_GRID_SIZE = Vector2(26, 26);

  /// 地图单个元尺寸：WxH
  static final Vector2 MAP_CELL_SIZE = Vector2.all(16.0);
}
