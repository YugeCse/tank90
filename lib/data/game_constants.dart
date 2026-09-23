// ignore_for_file: non_constant_identifier_names, constant_identifier_names
import 'package:flame/extensions.dart';

/// 常量
class GameConstants {
  GameConstants._();

  /// 资源图片名称
  static const RES_IMG_NAME = 'tankAll.png';

  static const DEAULT_PLAYER_LIFES = 3;

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

  /// 画布的默认背景色
  static const Color CANVAS_BG_COLOR = .fromARGB(255, 127, 127, 127);

  /// 画布大小
  static final Vector2 CANVAS_SIZE = Vector2(480, 416);

  /// 画布矩形
  static final Rect CANVAS_RECT = .fromLTWH(0, 0, CANVAS_SIZE.x, CANVAS_SIZE.y);
}
