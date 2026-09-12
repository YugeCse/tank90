import 'package:flame/image_composition.dart' show Vector2;

/// 地图地形类型
enum MapCellType {
  /// 草场
  grass(3, 32, 96.0),

  /// 河流
  rive(4, 48, 96.0),

  /// 冰地
  ice(5, 64, 96.0),

  /// 水泥墙
  mudWall(1, 0, 96.0),

  /// 钢铁墙
  steelWall(2, 16, 96.0);

  final int value;

  final double assetOffsetX;

  final double assetOffsetY;

  const MapCellType(this.value, this.assetOffsetX, this.assetOffsetY);

  Vector2 get srcPosition => Vector2(assetOffsetX, assetOffsetY);

  static MapCellType? fromValue(int value) {
    try {
      return MapCellType.values.firstWhere((type) => type.value == value);
    } catch (e) {
      return null;
    }
  }

  static Vector2 get size => Vector2.all(16.0);
}
