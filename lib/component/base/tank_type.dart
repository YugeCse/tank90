import 'package:tank90/component/base/direction.dart' show Direction;
import 'package:flame/image_composition.dart';
import 'package:tank90/component/base/tank_cannon_type.dart';

/// 坦克类型枚举
enum TankType {
  player(0, 0, 0, 100.0, 0),
  enemy0(100, 0, 32, 80.0, 0),
  enemy1(300, 128, 32, 160.0, 0),
  enemy2(300, 0, 64, 120.0, 2),
  enemy3(200, 128, 64, 100.0, 1),
  enemy4(120, 256, 64, 90.0, 0);

  /// 记分
  final int score;

  /// 资源坐标x
  final double assetPositionX;

  /// 资源坐标y
  final double assetPositionY;

  /// 初始化时的速度
  final double initialSpeed;

  /// 坦克的防爆次数
  final int explosionProofCount;

  /// 构造方法
  const TankType(
    this.score,
    this.assetPositionX,
    this.assetPositionY,
    this.initialSpeed,
    this.explosionProofCount,
  );

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

  /// 获取资源图片大小
  Vector2 get srcSize => Vector2.all(32.0);

  /// 获取资源图片的起始坐标
  Vector2 get srcPosition => Vector2(assetPositionX, assetPositionY);

  /// 根据朝向获取资源的位置
  /// + [facingDirection] - 朝向
  Vector2 getSrcPosition(Vector2 facingDirection, {Vector2? srcPosition}) {
    if (facingDirection == Direction.up) {
      return Vector2(0, 0) + (srcPosition ?? this.srcPosition);
    } else if (facingDirection == Direction.down) {
      return Vector2(32, 0) + (srcPosition ?? this.srcPosition);
    } else if (facingDirection == Direction.left) {
      return Vector2(64, 0) + (srcPosition ?? this.srcPosition);
    } else if (facingDirection == Direction.right) {
      return Vector2(96, 0) + (srcPosition ?? this.srcPosition);
    }
    return (this == TankType.player ? Vector2(0, 0) : Vector2(32, 0)) +
        (srcPosition ?? this.srcPosition);
  }

  /// 获取玩家资源坐标信息
  /// + [type] - 炮筒类型
  /// + [facingDirection] - 面朝方向
  Vector2 getSrcPositionByCannonType({
    required TankCannonType type,
    required Vector2 facingDirection,
  }) {
    switch (type) {
      case TankCannonType.longer:
        return getSrcPosition(
          facingDirection,
          srcPosition: Vector2(288.0, 160),
        );
      case TankCannonType.thicker:
        return getSrcPosition(
          facingDirection,
          srcPosition: Vector2(288.0, 192),
        );
      case TankCannonType.larger:
        return getSrcPosition(
          facingDirection,
          srcPosition: Vector2(288.0, 224),
        );
      default:
        return getSrcPosition(facingDirection);
    }
  }
}
