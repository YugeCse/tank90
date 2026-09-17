import 'dart:async';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:tank90/component/base/direction.dart';
import 'package:tank90/component/base/map_cell_type.dart';
import 'package:tank90/component/base/tank_type.dart';
import 'package:tank90/component/map/boss_component.dart';
import 'package:tank90/component/map/map_cell_component.dart';
import 'package:tank90/component/tank/base_tank_component.dart';
import 'package:tank90/data/game_constants.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:tank90/utils/audio_utils.dart' show AudioUtils;
import 'package:tank90/utils/res_img_utils.dart';

/// 子弹组件
class BulletComponent extends SpriteComponent
    with CollisionCallbacks, RiverpodComponentMixin {
  /// 单位速度向量
  Vector2 velocity;

  /// 运行速度
  final double speed;

  /// 拥有者类型
  final TankType type;

  /// 碰撞盒
  late RectangleHitbox hitbox;

  /// 是否出墙了，默认：false
  bool _isShotOutWall = false;

  /// 构造函数
  BulletComponent({
    required this.type,
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
      assetImage,
      srcSize: Vector2.all(6.0),
      srcPosition: _getSrcOffset(velocity),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_isShotOutWall &&
        !Rect.fromLTWH(
          0,
          0,
          GameConstants.MAP_SIZE.x,
          GameConstants.MAP_SIZE.y,
        ).overlaps(toRect())) {
      _isShotOutWall = true;
      boomAndDestroy(); //从父节点中删除
      AudioUtils().playBulletCrack(); //子弹射击到边界
    }
    position += velocity * speed * dt;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is MapCellComponent &&
        ![MapCellType.grass, MapCellType.rive].contains(other.type)) {
      velocity = Vector2.zero();
      AudioUtils().playBulletCrack();
      if (other.type == MapCellType.mudWall) {
        //如果是泥墙，直接移除
        other.setWillRemoveFromParent();
      }
      boomAndDestroy(); //爆炸并消失
    } else if (other is BaseTankComponent) {
      if (!other.type.isSameKind(type)) {
        velocity = Vector2.zero();
        AudioUtils().playBulletCrack();
        if (!other.isProtectedState) {
          other.attacked(); //被攻击
        }
        boomAndDestroy(); //爆炸并消失
      }
    } else if (other is BossComponent) {
      velocity = Vector2.zero();
      boomAndDestroy();
      other.setDeathState(); //boss 爆炸死亡
    } else if (other is BulletComponent && !other.type.isSameKind(type)) {
      velocity = Vector2.zero();
      AudioUtils().playBulletCrack();
      boomAndDestroy();
      other.boomAndDestroy();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  /// 获取资源所在的坐标信息
  Vector2 _getSrcOffset(Vector2 direction) {
    if (direction == Direction.up) {
      return Vector2(80.0, 96.0);
    } else if (direction == Direction.down) {
      return Vector2(86.0, 96.0);
    } else if (direction == Direction.left) {
      return Vector2(92.0, 96.0);
    }
    return Vector2(98.0, 96.0);
  }

  /// 爆炸并消失
  void boomAndDestroy() {
    velocity = Vector2.zero();
    removeFromParent(); //下一帧从父节点删除
    hitbox.collisionType = CollisionType.inactive;
    parent?.add(_BulletBoomEffectComponent(position: position.clone()));
  }

  /// 创建子弹组件
  static BulletComponent create({
    Vector2? position,
    double speed = 150.0,
    required Vector2 velocity,
    required TankType ownerType,
  }) {
    return BulletComponent(type: ownerType, velocity: velocity, speed: speed)
      ..position = position ?? Vector2.zero();
  }
}

/// 子弹爆炸效果的组件
class _BulletBoomEffectComponent extends SpriteAnimationComponent {
  _BulletBoomEffectComponent({required super.position})
    : super(anchor: Anchor.center, removeOnFinish: true);

  @override
  FutureOr<void> onLoad() {
    animation = SpriteAnimation.spriteList(
      [
        Sprite(
          assetImage,
          srcPosition: Vector2(320, 0),
          srcSize: Vector2.all(32.0),
        ),
        Sprite(
          assetImage,
          srcPosition: Vector2(352, 0),
          srcSize: Vector2.all(32.0),
        ),
        Sprite(
          assetImage,
          srcPosition: Vector2(384, 0),
          srcSize: Vector2.all(32.0),
        ),
      ],
      loop: false,
      stepTime: 0.06,
    );
  }
}
