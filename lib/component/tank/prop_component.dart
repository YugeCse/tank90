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
import 'package:tank90/data/map_constants.dart';
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
  /// 道具组件
  PropComponent? _propComponent;

  /// 生成随机坐标的随机对象
  final Random _positionRandom = Random();

  /// 道具权重数据表，合计为：100
  static final Map<PropType, int> weightMap = {
    TankPropType(): 5,
    TimerPropType(): 10,
    BossProtectPropType(): 30,
    BoomPropType(): 8,
    StarPropType(): 10,
    HatProtectPropType(): 37,
  };

  /// 道具生成的随机对象
  final _propGenerateRandom = _PropGenerateRandom(weightMap);

  /// 生成道具
  void generateProp() {
    var targetPropType = _propGenerateRandom.pick();
    if (targetPropType == null) return;
    removeProps();
    var gameWarMapSize = MapConstants.mapSize;
    game.warMapComponent?.add(
      _propComponent = PropComponent(propType: targetPropType),
    );
    var propSize = _propComponent!.size;
    var randX = _positionRandom
        .nextIntBetween(0, (gameWarMapSize.x - propSize.x).toInt())
        .toDouble();
    var randY = _positionRandom
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

/// 道具生成随机方法
class _PropGenerateRandom {
  final List<PropType> items;
  final List<int> weights;
  final Random _random;
  final int _total;
  _PropGenerateRandom(Map<PropType, int> weightMap, {Random? random})
    : items = weightMap.keys.toList(),
      weights = weightMap.values.toList(),
      _random = random ?? Random(),
      _total = weightMap.values.fold(0, (sum, w) => sum + w);

  PropType? pick() {
    if (items.isEmpty || _total <= 0) return null;
    var r = _random.nextInt(_total);
    for (var i = 0; i < items.length; i++) {
      if (r < weights[i]) return items[i];
      r -= weights[i];
    }
    return items.last;
  }
}
