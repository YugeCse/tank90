import 'dart:async';

import 'package:tank90/component/base/direction.dart';
import 'package:tank90/component/base/map_cell_type.dart';
import 'package:tank90/component/base/tank_type.dart';
import 'package:tank90/component/bullet/bullet_component.dart';
import 'package:tank90/component/map/map_cell_component.dart';
import 'package:tank90/component/tank/player_tank_component.dart';
import 'package:tank90/component/tank/tank_born_component.dart';
import 'package:tank90/data/map_constants.dart';
import 'package:tank90/data/notifier/tank_bom_notifier.dart'
    show TankBomNotifier;
import 'package:tank90/scene/game_scene.dart' show GameScene;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:tank90/utils/audio_utils.dart';

/// 坦克组件基类
abstract class BaseTankComponent extends SpriteComponent
    with HasGameReference<GameScene>, CollisionCallbacks {
  late RectangleHitbox hitbox;

  /// 坦克类型
  TankType type;

  /// 移动速度
  double speed;

  /// 坦克的向量速度
  Vector2 velocity;

  /// 坦克有效的方向数据
  Vector2 facingDirection = Vector2.zero();

  BaseTankComponent({
    required this.type,
    double? speed,
    Vector2? facingDirection,
    super.position,
  }) : speed = type.initialSpeed,
       velocity = facingDirection ?? Direction.up,
       super(size: type.srcSize, anchor: Anchor.center, priority: 600);

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(
      game.assetImage,
      srcSize: type.srcSize,
      srcPosition: type.getSrcPosition(velocity),
    );
    facingDirection = velocity;
    velocity = Vector2.zero();
    add(hitbox = RectangleHitbox(size: size - Vector2.all(1.0)));
    opacity = 0; //默认设置透明度为0
    hitbox.collisionType = CollisionType.inactive;
    game.addToWarMap(
      TankBornComponent(
        position: position,
        onAnimationFinished: () {
          opacity = 1.0;
          hitbox.collisionType = CollisionType.active;
        },
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updatePosition(dt); //更新位置
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (intersectionPoints.isEmpty) return;
    if ((other is MapCellComponent && other.type != MapCellType.grass) ||
        other is BaseTankComponent) {
      hitbox.collisionType = CollisionType.inactive;
      if (other is BaseTankComponent) {
        other.hitbox.collisionType = CollisionType.inactive;
      }
      // 使用轴向最小分离（MTV）来解决穿透：仅沿穿透最小的轴推开
      var iRect = toRect().intersect(other.toRect());
      if (iRect.width > 0 && iRect.height > 0) {
        // 决定沿哪一轴分离（选择穿透深度更小的轴）
        if (iRect.width <= iRect.height) {
          // 沿 X 轴分离
          // 根据两个中心点的相对位置确定推开方向
          final sign = (position.x - other.position.x) >= 0 ? 1.0 : -1.0;
          // 如果碰到另一个坦克，双方各退一半；若是墙体，则只退自己全部距离
          final move = iRect.width;
          if (other is BaseTankComponent) {
            position.x += sign * (move / 2);
            other.position.x -= sign * (move / 2);
            other.velocity = Vector2.zero();
          } else {
            position.x += sign * move;
          }
        } else {
          // 沿 Y 轴分离
          final sign = (position.y - other.position.y) >= 0 ? 1.0 : -1.0;
          final move = iRect.height;
          if (other is BaseTankComponent) {
            position.y += sign * (move / 2);
            other.position.y -= sign * (move / 2);
            other.velocity = Vector2.zero();
          } else {
            position.y += sign * move;
          }
        }
      }
      // 停止当前运动方向（发生碰撞时暂时停止移动）
      velocity = Vector2.zero();
      if (other is BaseTankComponent) {
        other.velocity = Vector2.zero();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    hitbox.collisionType = CollisionType.active;
    if (other is BaseTankComponent) {
      other.hitbox.collisionType = CollisionType.active;
    }
    super.onCollisionEnd(other);
  }

  /// 更新位置
  void _updatePosition(double dt) {
    // 记录最近有效移动方向已移除（不再基于历史方向回退）
    // 计算每帧位移向量，按轴分离移动并做最小分离修正
    position += velocity * speed * dt;
    position.clamp(Vector2.zero() + size / 2, MapConstants.mapSize - size / 2);
  }

  /// 改变坦克方向并更新精灵
  void setFacingDirection(Vector2 facingDirection) {
    if (facingDirection != Vector2.zero()) {
      if (velocity != facingDirection) {
        sprite = Sprite(
          game.assetImage,
          srcSize: type.srcSize,
          srcPosition: type.getSrcPosition(facingDirection),
        );
      }
      this.facingDirection = facingDirection;
      velocity = facingDirection; //更新速度向量数据
    }
  }

  /// 开火
  void fire({void Function()? onFinished}) {
    if (facingDirection != Vector2.zero()) {
      game.addToWarMap(
        BulletComponent.create(
          ownerType: runtimeType,
          direction: facingDirection,
          position: position + facingDirection * size.x / 2,
        ),
      );
      if (onFinished != null) onFinished();
    }
  }

  /// 被攻击
  void hit() {}

  /// 爆炸并消灭
  void bomAndDestroy() {
    removeFromParent();
    hitbox.collisionType = CollisionType.inactive;
    if (runtimeType is PlayerTankComponent) {
      AudioUtils().playPlayerCrack();
    } else {
      AudioUtils().playTankCrack();
    }
    game.addToWarMap(
      _TankBomEffectComponent(
        position: position,
        onFinished: () {
          game.onReceiveNotifier(TankBomNotifier(type: type));
        },
      ),
    );
  }
}

/// 坦克爆炸的效果组件
class _TankBomEffectComponent extends SpriteAnimationComponent
    with HasGameReference<GameScene> {
  final void Function() onFinished;

  _TankBomEffectComponent({super.position, required this.onFinished})
    : super(anchor: Anchor.center, removeOnFinish: true);

  @override
  FutureOr<void> onLoad() {
    var assetImage = game.assetImage;
    animation = SpriteAnimation.spriteList(
      [
        Sprite(
          assetImage,
          srcPosition: Vector2(0, 160),
          srcSize: Vector2.all(64),
        ),
        Sprite(
          assetImage,
          srcPosition: Vector2(65, 160),
          srcSize: Vector2.all(64),
        ),
        Sprite(
          assetImage,
          srcPosition: Vector2(135, 160),
          srcSize: Vector2(65, 64),
        ),
        Sprite(
          assetImage,
          srcPosition: Vector2(205, 160),
          srcSize: Vector2(60, 64),
        ),
      ],
      loop: false,
      stepTime: 0.12,
    );
    animationTicker?.onComplete = onFinished;
    return super.onLoad();
  }
}
