import 'package:tank90/component/base/direction.dart' show Direction;
import 'package:flame/image_composition.dart';

/// 坦克类型枚举
enum TankType {
  player(0, 0, 100.0),
  enemy0(0, 32, 80.0),
  enemy1(128, 32, 150.0),
  enemy2(0, 64, 90.0),
  enemy3(128, 64, 95.0),
  enemy4(256, 64, 98.0);

  final double assetPositionX;

  final double assetPositionY;

  final double initialSpeed;

  const TankType(this.assetPositionX, this.assetPositionY, this.initialSpeed);

  Vector2 get srcSize => Vector2.all(32.0);

  Vector2 get srcPosition => Vector2(assetPositionX, assetPositionY);

  Vector2 get _upOffsetDelta => Vector2(0, 0);

  Vector2 get _downOffsetDelta => Vector2(32, 0);

  Vector2 get _leftOffsetDelta => Vector2(64, 0);

  Vector2 get _rightOffsetDelta => Vector2(96, 0);

  Vector2 getSrcPosition(Vector2 direction) {
    if (direction == Direction.up) {
      return _upOffsetDelta + srcPosition;
    } else if (direction == Direction.down) {
      return _downOffsetDelta + srcPosition;
    } else if (direction == Direction.left) {
      return _leftOffsetDelta + srcPosition;
    } else if (direction == Direction.right) {
      return _rightOffsetDelta + srcPosition;
    }
    throw Exception("Unknown Direction, must be up、down、left、right");
  }

  /// 敌人坦克类型
  static final enemyTankTypes = <TankType>[
    TankType.enemy0,
    TankType.enemy1,
    TankType.enemy2,
    TankType.enemy3,
    TankType.enemy4,
  ];

  /// 是否同一类型
  bool isSameKind(TankType other) {
    return ((other == TankType.player && this == TankType.player) ||
        TankType.enemyTankTypes.contains(other) &&
            TankType.enemyTankTypes.contains(this));
  }
}
