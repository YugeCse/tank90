import 'dart:async';

import 'package:tank90/component/base/direction.dart';
import 'package:tank90/component/base/hitbox_mixin.dart';
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
    with HasGameReference<GameScene>, CollisionCallbacks, HitboxMixin {
  /// 坦克类型
  TankType type;

  /// 移动速度
  double speed;

  /// 坦克的向量速度
  Vector2 velocity;

  /// 坦克有效的方向数据
  Vector2 facingDirection = Vector2.zero();

  /// 碰撞对象集合
  final Set<Component> _collisionObjects = {};

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
    position += velocity * speed * dt;
    _adjustLimitPosition(dt); //更新位置
  }

  /// 更新限制位置信息
  void _adjustLimitPosition(double dt) {
    _adjustCollisionPosition(); //调整碰撞位置信息
    position.clamp(Vector2.zero() + size / 2, MapConstants.mapSize - size / 2);
  }

  var _isCollisionHandled = false;

  /// 调整碰撞位置信息
  void _adjustCollisionPosition() {
    if (_isCollisionHandled) return;
    _isCollisionHandled = true;
    var collisionList = _collisionObjects.toList();
    for (var obj in collisionList) {
      if (obj is HitboxMixin) {
        _adjustPositionByHitbox(obj.hitbox);
      }
    }
    _isCollisionHandled = false;
  }

  /// 碰撞盒处理并修正位置
  void _adjustPositionByHitbox(RectangleHitbox otherHitbox) {
    const double epsilon = 0.5;
    var selfRect = toAbsoluteRect();
    var selfCenter = selfRect.center;
    var objRect = otherHitbox.toAbsoluteRect();
    var objCenter = objRect.center;
    var nCollisionDx = selfRect.size.width / 2 + objRect.size.width / 2;
    var nCollisionDy = selfRect.size.height / 2 + objRect.size.height / 2;
    var diffCenter = selfCenter - objCenter;
    final overlapX = nCollisionDx - diffCenter.dx.abs(); // 穿透深度
    final overlapY = nCollisionDy - diffCenter.dy.abs(); // 穿透深度
    if (overlapX > epsilon && overlapY > epsilon) {
      if (overlapX < overlapY) {
        position.x += (diffCenter.dx < 0 ? -overlapX : overlapX); // 向左/右推开
      } else {
        position.y += (diffCenter.dy < 0 ? -overlapY : overlapY); // 向左/右推开
      }
      velocity = Vector2.zero();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if ((other is MapCellComponent && other.type != MapCellType.grass) ||
        other is BaseTankComponent) {
      _collisionObjects.add(other);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if ((other is MapCellComponent && other.type != MapCellType.grass) ||
        other is BaseTankComponent) {
      _collisionObjects.add(other);
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if ((other is MapCellComponent && other.type != MapCellType.grass) ||
        other is BaseTankComponent) {
      _collisionObjects.remove(other);
    }
    super.onCollisionEnd(other);
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
