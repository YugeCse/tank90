import 'dart:async';

import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tank90/app/notifier/enemy_increment_notifier.dart';
import 'package:tank90/component/base/boss_wall_state.dart';
import 'package:tank90/component/base/bullet_type.dart';
import 'package:tank90/component/base/capability.dart';
import 'package:tank90/component/base/capability_controller.dart';
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

  /// 拥有的能力控制器
  CapabilityController capabilityController;

  /// 碰撞对象集合, 方便计算碰撞数据
  final Set<Component> _collisionObjects = <Component>{};

  /// 坦克保护组件，有时效性的
  TankProtectComponent? _tankProtectComponent;

  /// 是否是处理被保护状态
  bool get isProtectedState => _tankProtectComponent != null;

  /// 获取所有能力集合
  Map<Type, Capability> get capabilities =>
      capabilityController.allCapabilities;

  /// 构造方法
  BaseTankComponent({
    required this.type,
    double? speed,
    Vector2? velocity,
    Vector2? facingDirection,
    super.position,
    Map<Type, Capability>? capabilities,
  }) : _originType = type,
       speed = type.initialSpeed,
       velocity = velocity ?? Vector2.zero(),
       facingDirection =
           facingDirection ??
           (type == TankType.player ? Direction.up : Direction.random()),
       explosionProofCount = type.explosionProofCount,
       capabilityController = CapabilityController(
         capabilities: Map.from(capabilities ?? {}),
       ),
       super(size: type.srcSize, anchor: Anchor.center, priority: 600) {
    updateSprite(type); //更新当前显示的精灵图片
    setFacingDirection(this.facingDirection); //设置当前的朝向数据
  }

  @override
  FutureOr<void> onLoad() {
    opacity = 0; //默认设置透明度为0
    add(
      hitbox = RectangleHitbox(
        size: size,
        collisionType: CollisionType.inactive,
      ),
    );
    if (capabilityController.hasProtectedCapapbility) {
      showProtectEffect(); //显示保护状态
    }
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
  void render(Canvas canvas) {
    if (capabilityController.hasFerryCapability) {
      var paint = Paint()
        ..isAntiAlias = true
        ..style = .stroke
        ..strokeWidth = 2.0
        ..color = Colors.white70;
      var rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        .circular(3),
      );
      canvas.drawRRect(rrect, paint);
    }
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // 非正在出生的状态，才能执行下面的逻辑
    if (!isBornState) {
      if (!capabilityController.hasSleepCapability) {
        position += velocity * speed * dt;
      } else {
        var capability =
            capabilityController.getCapability(SleepCapability)
                as SleepCapability;
        capability.sleepTimeSec -= dt;
        if (capability.sleepTimeSec <= 0.0) {
          capabilityController.removeCapability(SleepCapability); //移除这个能力
        }
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
      velocity = Vector2.zero(); //防止额外移动，所以先禁止它继续移动
      onAdjustPositionEndedAfterCollision();
      if (overlapX < overlapY) {
        final correction = diffCenter.dx < 0 ? -overlapX : overlapX;
        position.x += correction / absoluteScale.x; // 绝对位移转局部位移
      } else {
        final correction = diffCenter.dy < 0 ? -overlapY : overlapY;
        position.y += correction / absoluteScale.y; // 绝对位移转局部位移
      }
      onAdjustPositionEndedAfterCollision();
    }
  }

  /// 在碰撞发生前调整坐标数据
  void onAdjustPositionStartBeforeCollision() {}

  /// 在碰撞发生后调整坐标数据
  void onAdjustPositionEndedAfterCollision() {}

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is BaseTankComponent ||
        other is BossComponent ||
        (other is MapCellComponent &&
            ((![
                  MapCellType.grass,
                  MapCellType.ice,
                  MapCellType.rive,
                ].contains(other.type)) ||
                (!capabilityController.hasFerryCapability &&
                    other.type == MapCellType.rive)))) {
      _collisionObjects.add(other);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (_collisionObjects.contains(other)) {
      _collisionObjects.remove(other);
    }
    super.onCollisionEnd(other);
  }

  /// 获得资源的原始起始坐标
  Vector2 getSrcPosition(Vector2 facingDir) {
    return type.getSrcPosition(facingDir);
  }

  /// 更新精灵图帧
  /// + [type] - 坦克类型
  void updateSprite(TankType type, {Vector2? facingDirection}) {
    sprite = Sprite(
      assetImage,
      srcSize: type.srcSize,
      srcPosition: getSrcPosition(facingDirection ?? this.facingDirection),
    );
  }

  /// 出生完成事件
  void onBornFinished() {}

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
      if (this.facingDirection != facingDirection) {
        this.facingDirection = facingDirection;
        updateSprite(type, facingDirection: facingDirection); //设置精灵图像
      }
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
    var isTankPropType = false;
    if (type is TankPropType) {
      isTankPropType = true;
      AudioUtils().playProp();
      if (this.type == TankType.player) {
        globalConfig.playerLifes += 1;
      } else {
        if (globalConfigInfo.enemyCounts >= 20) {
          //敌人最多能拥有 20 个
          return;
        }
        globalConfig.enemyCounts += 1;
        var mainScene = findMainScene();
        mainScene?.onReceiveNotifier(EnemyIncrementNotifier());
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
      // 火力等级最多按 4 颗星处理，3 颗及以上都显示 large 炮嘴；4颗星能够烧毁草场地块
      capabilityController.putCapability(StrongFireCapability());
    } else if (type is HatProtectPropType) {
      showProtectEffect(); //如果没有保护效果的，则添加保护效果
      capabilityController.putCapability(ProtectedCapability());
    } else if (type is GunPropType) {
      capabilityController.putCapability(StrongFireCapability(fireLevel: 3));
    } else if (type is ShipPropType) {
      capabilityController.putCapability(FerryCapability()); //设置获取轮渡能力
    }
    if (!isTankPropType) AudioUtils().playGetProp();
  }

  /// 获取攻击使用的子弹类型
  BulletType getAttackBulletType() => BulletType.normal;

  /// 开炮/攻击
  /// + [onFireFinished] - 开火完成的事件
  /// + [doubleFireAvailable] - 双倍火力是否可用，如果开启且本身支持才行
  void fire({
    bool doubleFireAvailable = false,
    void Function()? onFireFinished,
  }) {
    /// 开火，添加子弹精灵
    void openFire({bool isSecond = false}) {
      if (this is PlayerTankComponent) {
        AudioUtils().playAttack(); //播放玩家射击的声音
      }
      findWarMapComponent()?.add(
        BulletComponent.create(
          ownerType: type,
          type: getAttackBulletType(),
          velocity: facingDirection,
          position: position + facingDirection * size.x / 3,
          fireGrass: capabilityController.powerFireLevel >= 4,
        ),
      );
    }

    if (facingDirection != Vector2.zero()) {
      openFire(isSecond: false);
      if (doubleFireAvailable) {
        add(
          TimerComponent(
            period: 0.2, //第二个延迟0.2s
            removeOnFinish: true,
            onTick: () => openFire(isSecond: true),
          ),
        );
      }
      if (onFireFinished != null) onFireFinished();
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
