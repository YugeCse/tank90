import 'dart:async';
import 'dart:math';

import 'package:tank90/component/base/capability.dart';
import 'package:tank90/component/base/direction.dart';
import 'package:tank90/component/base/hitbox_mixin.dart';
import 'package:tank90/component/base/map_cell_type.dart';
import 'package:tank90/component/base/prop_type.dart';
import 'package:tank90/component/base/tank_type.dart';
import 'package:tank90/component/tank/bullet_component.dart';
import 'package:tank90/component/map/map_cell_component.dart';
import 'package:tank90/component/tank/player_tank_component.dart';
import 'package:tank90/component/tank/tank_born_component.dart';
import 'package:tank90/component/tank/tank_protect_component.dart';
import 'package:tank90/data/global_config.dart';
import 'package:tank90/data/map_constants.dart';
import 'package:tank90/data/notifier/boom_all_notifier.dart';
import 'package:tank90/data/notifier/tank_bom_notifier.dart'
    show TankBomNotifier;
import 'package:tank90/scene/tank_war_game.dart' show TankWarGame;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:tank90/utils/audio_utils.dart';

/// 坦克组件基类
abstract class BaseTankComponent extends SpriteComponent
    with HasGameReference<TankWarGame>, CollisionCallbacks, HitboxMixin {
  /// 坦克类型
  TankType type;

  /// 移动速度
  double speed;

  /// 坦克的单位速度向量
  Vector2 velocity;

  /// 坦克有效的方向数据
  Vector2 facingDirection = Vector2.zero();

  /// 是否是出生状态
  bool isBornState = true;

  /// 是否处理了碰撞逻辑
  bool _isCollisionHandled = false;

  /// 拥有的能力对象集合
  final Map<Type, Capability> capabilities = {};

  /// 碰撞对象集合, 方便计算碰撞数据
  final Set<Component> _collisionObjects = {};

  /// 坦克保护组件，有时效性的
  TankProtectComponent? _tankProtectComponent;

  /// 是否是处理被保护状态
  bool get isProtectedState => _tankProtectComponent != null;

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
    add(hitbox = RectangleHitbox(size: size));
    opacity = 0; //默认设置透明度为0
    hitbox.collisionType = CollisionType.inactive;
    game.warMapComponent?.add(
      TankBornComponent(
        position: position,
        onAnimationFinished: () {
          opacity = 1.0;
          isBornState = false;
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
    // This value is measured in absolute pixels. Keep it very small: a large
    // epsilon allows the tank to penetrate the obstacle before being corrected.
    const double epsilon = 0.01;
    // Collision rectangles are in absolute (screen) coordinates, while
    // `position` is relative to the scaled WarMapComponent.  Use the actual
    // hitbox for both sides, then convert the correction back to local units
    // before changing position.  Applying an absolute correction directly to
    // position makes the tank overshoot the wall whenever the map is scaled.
    var selfRect = hitbox.toAbsoluteRect();
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
        final correction = diffCenter.dx < 0 ? -overlapX : overlapX;
        position.x += correction / absoluteScale.x; // 绝对位移转局部位移
      } else {
        final correction = diffCenter.dy < 0 ? -overlapY : overlapY;
        position.y += correction / absoluteScale.y; // 绝对位移转局部位移
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

  /// 添加保护效果
  void showProtectEffect() {
    if (_tankProtectComponent != null) {
      _tankProtectComponent?.removeFromParent();
      _tankProtectComponent = null;
    }
    add(
      _tankProtectComponent = TankProtectComponent(
        onDestroy: () => _tankProtectComponent = null,
      ),
    );
  }

  /// 获得装备
  void fetchProp(PropType type) {
    if (type is TankPropType) {
      AudioUtils().playProp();
      if (this.type == TankType.player) {
        GlobalConfig.playerLifes += 1;
      } else {
        if (GlobalConfig.enemyCounts >= 20) {
          //敌人最多能拥有 20 个
          return;
        }
        GlobalConfig.enemyCounts += 1;
      }
    } else if (type is TimerPropType) {
      if (this is PlayerTankComponent) {
      } else {}

      /// TODO 暂停玩家或敌人的行为能力
    } else if (type is BossProtectPropType) {
      if (this is PlayerTankComponent) {
      } else {}

      ///TODO 在地图上对 BOSS 区域进行装饰
    } else if (type is BoomPropType) {
      game.mainScene?.onReceiveNotifier(
        BoomAllNotifier(type: type, ownerType: this.type),
      );
    } else if (type is StarPropType) {
      if (capabilities.containsKey(StrongFireCapability)) {
        var capability =
            capabilities[StrongFireCapability] as StrongFireCapability;
        var level = max(capability.fireLevel + 1, 3);
        capability.fireLevel = level;
        capabilities[StrongFireCapability] = capability;
      } else {
        capabilities[StrongFireCapability] = StrongFireCapability(fireLevel: 2);
      }
    } else if (type is HatProtectPropType) {
      showProtectEffect(); //如果没有保护效果的，则添加保护效果
    }
  }

  /// 开火
  /// + [onFinished] - 开火完成的事件
  void fire({void Function()? onFinished}) {
    if (facingDirection != Vector2.zero()) {
      if (this is PlayerTankComponent) {
        AudioUtils().playAttack(); //播放玩家射击的声音
      }
      game.warMapComponent?.add(
        BulletComponent.create(
          ownerType: runtimeType,
          velocity: facingDirection,
          position: position + facingDirection * size.x / 2,
        ),
      );
      if (onFinished != null) onFinished();
    }
  }

  /// 被攻击
  void hit() {
    bomAndDestroy(); //爆炸并损坏
  }

  /// 爆炸并消灭
  void bomAndDestroy() {
    removeFromParent();
    hitbox.collisionType = CollisionType.inactive;
    if (runtimeType is PlayerTankComponent) {
      AudioUtils().playPlayerCrack();
    } else {
      AudioUtils().playTankCrack();
    }
    game.warMapComponent?.add(
      _TankBomEffectComponent(
        position: position,
        onFinished: () {
          game.mainScene?.onReceiveNotifier(TankBomNotifier(type: type));
        },
      ),
    );
  }
}

/// 坦克爆炸的效果组件
class _TankBomEffectComponent extends SpriteAnimationComponent
    with HasGameReference<TankWarGame> {
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
