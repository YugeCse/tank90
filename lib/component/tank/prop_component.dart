import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:tank90/component/base/prop_type.dart';
import 'package:tank90/component/tank/enemy_tank_component.dart';
import 'package:tank90/component/tank/player_tank_component.dart';
import 'package:tank90/data/game_level.dart';
import 'package:tank90/data/global_config.dart';
import 'package:tank90/scene/tank_war_game.dart';

/// 装备组件类
class PropComponent extends SpriteComponent
    with HasGameReference<TankWarGame>, CollisionCallbacks {
  /// 装备类型
  PropType propType;

  /// 停留有效时间
  double stayTimeSec;

  /// 时间计数
  double _timeSecCounter = 0;

  /// 是否是闪烁状态
  bool _isFlickerState = false;

  /// 撞击盒对象
  late RectangleHitbox _hitbox;

  /// 构造函数
  PropComponent({
    required this.propType,
    super.position,
    this.stayTimeSec = 30.0,
  });

  @override
  FutureOr<void> onLoad() async {
    scale = Vector2.all(1.1);
    changePropType(propType);
    add(_hitbox = RectangleHitbox(size: size, isSolid: true));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timeSecCounter += dt;
    if (_timeSecCounter > stayTimeSec && !_isFlickerState) {
      _isFlickerState = true;
      _showFlickerEffect(); //显示闪烁效果
    }
  }

  /// 修改装备类型
  void changePropType(PropType type) {
    propType = type;
    sprite = Sprite(
      game.assetImage,
      srcSize: propType.srcSize,
      srcPosition: propType.srcPosition,
    );
  }

  /// 显示闪烁效果
  void _showFlickerEffect() {
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 1.0, repeatCount: 6),
        onComplete: () => removeFromParent(),
      ),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is PlayerTankComponent) {
      _hitbox.collisionType = CollisionType.inactive;
      removeFromParent();
      other.fetchProp(propType);
    } else if (other is EnemyTankComponent) {
      // 只有困难等级才能让敌人获得装备
      if (GlobalConfig.gameLevel == GameLevel.difficulty) {
        _hitbox.collisionType = CollisionType.inactive;
        removeFromParent();
        other.fetchProp(propType);
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}

/// 装备道具工厂组件
class PropFactoryComponent extends Component
    with HasGameReference<TankWarGame> {
  final Random _rand = Random();

  /// 道具组件
  PropComponent? _propComponent;

  /// 生成道具
  void generateProp() {
    removeProps();
    var gameWarMapSize = game.warMapComponent?.size;
    if (gameWarMapSize == null) return;
    add(_propComponent = PropComponent(propType: HatProtectPropType()));
    var propSize = _propComponent!.size;
    var randX = _rand
        .nextIntBetween(0, (gameWarMapSize.x - propSize.x).toInt())
        .toDouble();
    var randY = _rand
        .nextIntBetween(0, (gameWarMapSize.y - propSize.y).toInt())
        .toDouble();
    var randPosition = Vector2(randX, randY);
    randPosition.clamp(Vector2.zero(), gameWarMapSize - propSize);
    _propComponent?.position = randPosition;
  }

  /// 删除道具
  void removeProps() {
    if (_propComponent != null) {
      _propComponent?.removeFromParent();
      _propComponent = null;
    }
  }
}
