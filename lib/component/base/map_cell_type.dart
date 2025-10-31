import 'package:flame/image_composition.dart' show Vector2;

enum MapCellType {
  grass(3, 32, 96.0),
  rive(4, 48, 96.0),
  ice(5, 64, 96.0),
  mudWall(1, 0, 96.0),
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
