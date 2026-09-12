import 'dart:async';
import 'package:tank90/component/base/direction.dart';
import 'package:tank90/component/base/map_cell_type.dart';
import 'package:tank90/component/map/map_cell_component.dart';
import 'package:tank90/component/tank/base_tank_component.dart';
import 'package:tank90/data/map_constants.dart';
import 'package:tank90/scene/tank_war_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:tank90/utils/audio_utils.dart' show AudioUtils;

/// 子弹组件
class BulletComponent extends SpriteComponent
    with HasGameReference<TankWarGame>, CollisionCallbacks {
  static final Vector2 _upOffset = Vector2(80, 96);
  static final Vector2 _downOffset = Vector2(86, 96);
  static final Vector2 _leftOffset = Vector2(92, 96);
  static final Vector2 _rightOffset = Vector2(98, 96);

  static Vector2 _getSrcOffset(Vector2 direction) {
    if (direction == Direction.up) {
      return _upOffset;
    } else if (direction == Direction.down) {
      return _downOffset;
    } else if (direction == Direction.left) {
      return _leftOffset;
    }
    return _rightOffset;
  }

  /// 单位速度向量
  Vector2 velocity;

  /// 运行速度
  final double speed;

  /// 拥有者类型
  final Type ownerType;

  /// 碰撞盒
  late RectangleHitbox hitbox;

  /// 构造函数
  BulletComponent({
    required this.ownerType,
    this.speed = 150.0,
    required this.velocity,
  }) : super(size: Vector2.all(6.0), priority: 700) {
    add(hitbox = RectangleHitbox(size: Vector2.all(5.0)));
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    anchor = Anchor.center;
    sprite = Sprite(
      game.assetImage,
      srcSize: Vector2.all(6.0),
      srcPosition: _getSrcOffset(velocity),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!Rect.fromLTWH(
      0,
      0,
      MapConstants.mapSize.x,
      MapConstants.mapSize.y,
    ).overlaps(toRect())) {
      bomAndDestroy(); //从父节点中删除
    }
    position += velocity * speed * dt;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is MapCellComponent &&
        other.type != MapCellType.grass &&
        other.type != MapCellType.rive) {
      if (other.type == MapCellType.mudWall) {
        other.setRemoveFromParent();
      }
      bomAndDestroy(); //爆炸并消失
    } else if (other is BaseTankComponent && other.runtimeType != ownerType) {
      bomAndDestroy(); //爆炸并消失
      // removeFromParent();
      other.bomAndDestroy(); //爆炸并损坏
    }
    AudioUtils().playBulletCrack();
    super.onCollisionStart(intersectionPoints, other);
  }

  /// 爆炸并消失
  void bomAndDestroy() {
    velocity = Vector2.zero();
    removeFromParent(); //下一帧从父节点删除
    hitbox.collisionType = CollisionType.inactive;
    game.warMapComponent?.add(
      _BulletBomEffectComponent(position: position.clone()),
    );
  }

  /// 创建子弹组件
  static BulletComponent create({
    required Type ownerType,
    double speed = 150.0,
    required Vector2 velocity,
    Vector2? position,
  }) {
    return BulletComponent(
      ownerType: ownerType,
      velocity: velocity,
      speed: speed,
    )..position = position ?? Vector2.zero();
  }
}

/// 子弹爆炸效果的组件
class _BulletBomEffectComponent extends SpriteAnimationComponent
    with HasGameReference<TankWarGame> {
  _BulletBomEffectComponent({required super.position})
    : super(anchor: Anchor.center, removeOnFinish: true);

  @override
  FutureOr<void> onLoad() {
    animation = SpriteAnimation.spriteList(
      [
        Sprite(
          game.assetImage,
          srcPosition: Vector2(320, 0),
          srcSize: Vector2.all(32.0),
        ),
        Sprite(
          game.assetImage,
          srcPosition: Vector2(352, 0),
          srcSize: Vector2.all(32.0),
        ),
        Sprite(
          game.assetImage,
          srcPosition: Vector2(384, 0),
          srcSize: Vector2.all(32.0),
        ),
      ],
      loop: false,
      stepTime: 0.06,
    );
  }
}
