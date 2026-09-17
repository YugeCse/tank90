import 'dart:async';
import 'dart:math';

import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:tank90/component/base/boss_wall_state.dart';
import 'package:tank90/component/base/capability.dart';
import 'package:tank90/component/base/direction.dart';
import 'package:tank90/component/base/hitbox_mixin.dart';
import 'package:tank90/component/base/map_cell_type.dart';
import 'package:tank90/component/base/prop_type.dart';
import 'package:tank90/component/base/tank_type.dart';
import 'package:tank90/component/map/boss_component.dart';
import 'package:tank90/component/map/war_map_component.dart';
import 'package:tank90/component/tank/bullet_component.dart';
import 'package:tank90/component/map/map_cell_component.dart';
import 'package:tank90/component/tank/enemy_tank_component.dart';
import 'package:tank90/component/tank/player_tank_component.dart';
import 'package:tank90/component/tank/tank_born_component.dart';
import 'package:tank90/component/tank/tank_protect_component.dart';
import 'package:tank90/app/provider/global_config.dart';
import 'package:tank90/data/game_constants.dart';
import 'package:tank90/app/notifier/boom_all_notifier.dart';
import 'package:tank90/app/notifier/boss_protected_notifier.dart';
import 'package:tank90/app/notifier/tank_boom_notifier.dart'
    show TankBoomNotifier;
import 'package:tank90/scene/main_scene.dart';
import 'package:tank90/app/tank_war_game.dart' show TankWarGame;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:tank90/utils/audio_utils.dart';
import 'package:tank90/utils/res_img_utils.dart';

/// 坦克组件基类
abstract class BaseTankComponent extends SpriteComponent
    with
        CollisionCallbacks,
        HitboxMixin,
        RiverpodComponentMixin,
        MainSceneMixin,
        WarMapComponentMixin {
  /// 坦克类型
  TankType type;

  /// 坦克原始类型，不变化的
  final TankType _originType;

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

  /// 防爆次数
  int explosionProofCount;

  /// 拥有的能力对象集合
  final Map<Type, Capability> capabilities = {};

  /// 碰撞对象集合, 方便计算碰撞数据
  final Set<Component> _collisionObjects = {};

  /// 坦克保护组件，有时效性的
  TankProtectComponent? _tankProtectComponent;

  /// 是否是处理被保护状态
  bool get isProtectedState => _tankProtectComponent != null;

  /// 构造方法
  BaseTankComponent({
    required this.type,
    double? speed,
    Vector2? facingDirection,
    super.position,
    this.explosionProofCount = 0,
  }) : _originType = type,
       speed = type.initialSpeed,
       velocity = Vector2.zero(),
       facingDirection = facingDirection ?? Direction.up,
       super(size: type.srcSize, anchor: Anchor.center, priority: 600);

  /// 更新精灵图帧
  /// + [type] - 坦克类型
  void updateSprite(TankType type) {
    sprite = Sprite(
      assetImage,
      srcSize: type.srcSize,
      srcPosition: type.getSrcPosition(facingDirection),
    );
  }

  /// 出生完成事件
  void onBornFinished() {}

  @override
  FutureOr<void> onLoad() {
    explosionProofCount = type.explosionProofCount;
    updateSprite(type);
    facingDirection = velocity;
    velocity = Vector2.zero();
    add(hitbox = RectangleHitbox(size: size));
    opacity = 0; //默认设置透明度为0
    hitbox.collisionType = CollisionType.inactive;
  }

  @override
  void onMount() {
    super.onMount();
    findWarMapComponent()?.add(
      TankBornComponent(
        position: center,
        onAnimationFinished: _onBornAnimationFinished,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!capabilities.containsKey(SleepCapability)) {
      position += velocity * speed * dt;
    } else {
      var capability = capabilities[SleepCapability] as SleepCapability;
      capability.sleepTimeSec -= dt;
      if (capability.sleepTimeSec <= 0.0) {
        capabilities.remove(SleepCapability); //移除这个能力
      }
    }
    _adjustLimitPosition(dt); //更新位置
  }

  /// 更新限制位置信息
  void _adjustLimitPosition(double dt) {
    _adjustCollisionPosition(); //调整碰撞位置信息
    position.clamp(
      Vector2.zero() + size / 2,
      GameConstants.MAP_SIZE - size / 2,
    );
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
        other is BaseTankComponent ||
        other is BossComponent) {
      _collisionObjects.add(other);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if ((other is MapCellComponent && other.type != MapCellType.grass) ||
        other is BaseTankComponent ||
        other is BossComponent) {
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

  /// 出生动画完成事件
  void _onBornAnimationFinished() {
    opacity = 1.0;
    isBornState = false;
    hitbox.collisionType = CollisionType.active;
    onBornFinished(); //出生完成
  }

  /// 改变坦克方向并更新精灵
  void setFacingDirection(Vector2 facingDirection) {
    if (facingDirection != Vector2.zero()) {
      if (velocity != facingDirection) {
        sprite = Sprite(
          assetImage,
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
    } else {
      AudioUtils().playGetProp();
    }
    if (type is TankPropType) {
      if (this.type == TankType.player) {
        globalConfig.playerLifes += 1;
      } else {
        if (globalConfigInfo.enemyCounts >= 20) {
          //敌人最多能拥有 20 个
          return;
        }
        globalConfig.enemyCounts += 1;
      }
    } else if (type is TimerPropType) {
      var mainScene = findMainScene();
      if (this is EnemyTankComponent) {
        mainScene?.freezePlayerTank();
      } else {
        mainScene?.freezeEnemyTanks();
      }
    } else if (type is BossProtectPropType) {
      findMainScene()?.onReceiveNotifier(
        BossProtectedNotifier(
          state: this is PlayerTankComponent
              ? SteelBossWallState()
              : NoneBossWallState(),
        ),
      );
    } else if (type is BoomPropType) {
      findMainScene()?.onReceiveNotifier(
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

  /// 开炮/攻击
  /// + [onFinished] - 开火完成的事件
  void attack({void Function()? onFinished}) {
    if (facingDirection != Vector2.zero()) {
      if (this is PlayerTankComponent) {
        AudioUtils().playAttack(); //播放玩家射击的声音
      }
      findWarMapComponent()?.add(
        BulletComponent.create(
          ownerType: type,
          velocity: facingDirection,
          position: position + facingDirection * size.x / 2,
        ),
      );
      if (onFinished != null) onFinished();
    }
  }

  /// 被攻击
  void attacked() {
    if (explosionProofCount > 0) {
      explosionProofCount--;
      onAttackedButNotExplosion();
      return; //因为扛住了打击，所以不会执行下面的逻辑
    }
    boomAndDestroy(); //爆炸并损坏
  }

  /// 被攻击了，但是没有爆炸
  void onAttackedButNotExplosion() {}

  /// 爆炸并消灭
  void boomAndDestroy() {
    var mainScene = findMainScene();
    var warMapComponent = findWarMapComponent();
    removeFromParent(); //从父节点移除
    hitbox.collisionType = CollisionType.inactive;
    _originType == TankType.player
        ? AudioUtils().playPlayerCrack()
        : AudioUtils().playTankCrack();
    warMapComponent?.add(
      _TankBoomEffectComponent(
        position: position,
        onFinished: () =>
            mainScene?.onReceiveNotifier(TankBoomNotifier(type: _originType)),
      ),
    );
  }
}

/// 坦克爆炸的效果组件
class _TankBoomEffectComponent extends SpriteAnimationComponent
    with HasGameReference<TankWarGame> {
  final void Function() onFinished;

  _TankBoomEffectComponent({super.position, required this.onFinished})
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
