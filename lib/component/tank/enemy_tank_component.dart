import 'dart:async';
import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:tank90/component/base/direction.dart' show Direction;
import 'package:tank90/component/base/tank_type.dart' show TankType;
import 'package:tank90/component/tank/base_tank_component.dart'
    show BaseTankComponent;
import 'package:flame/components.dart'
    show HasGameReference, PositionComponent, TimerComponent, Vector2;
import 'package:tank90/data/map_constants.dart';
import 'package:tank90/scene/game_scene.dart';

/// 地方坦克组件
class EnemyTankComponent extends BaseTankComponent {
  /// 移动定时器
  TimerComponent? _moveTimer;

  TimerComponent? _fireTimer;

  final Random _random = Random();

  EnemyTankComponent._({
    super.speed,
    super.direction,
    super.position,
    super.type = TankType.enemy0,
  });

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    add(
      _moveTimer ??= TimerComponent(
        period: 2.0,
        repeat: true,
        onTick: () => setTankDirection(Direction.random()),
      ),
    );
    _randomFire(); //随机开火
  }

  // 随机开火
  void _randomFire() {
    add(
      _fireTimer ??= TimerComponent(
        onTick: () => fire(
          onFinished: () {
            _fireTimer = null;
            _randomFire();
          },
        ),
        removeOnFinish: true,
        period: _random.nextDouble() * 3 + 1,
      ),
    );
  }

  /// 创建敌方坦克实例
  static EnemyTankComponent create({
    TankType type = TankType.enemy0,
    Vector2? position,
  }) {
    return EnemyTankComponent._(
      position: position,
      type: type,
      speed: type.initialSpeed,
      direction: Direction.random(),
    );
  }

  /// 敌方坦克出生地址
  static final List<Vector2> bornPositions = [
    Vector2(16, 16),
    Vector2(MapConstants.mapSize.x / 2, 16),
    Vector2(MapConstants.mapSize.x - 16, 16),
  ];
}

/// 敌方坦克工厂组件
class EnemyTankFactory extends PositionComponent
    with HasGameReference<GameScene> {
  final List<TankType> tankTypes = [
    TankType.enemy0,
    TankType.enemy1,
    TankType.enemy2,
    TankType.enemy3,
    TankType.enemy4,
  ];

  final int maxTankCount;

  late Random _random;

  late TimerComponent _factoryTimer;

  EnemyTankFactory({this.maxTankCount = 5});

  @override
  FutureOr<void> onLoad() {
    _random = Random();
    _factoryTimer = TimerComponent(
      period: 2.0,
      repeat: true,
      onTick: _checkAndGenerateTanks,
    );
    add(_factoryTimer);
  }

  void _checkAndGenerateTanks() {
    var diffCount = maxTankCount - game.enemyTanks.length;
    if (diffCount <= 0) return;
    while (diffCount >= 0) {
      var tanks = game.mapComponent?.children
          .whereType<BaseTankComponent>()
          .toList();
      if (tanks?.isNotEmpty == true) {
        for (var i = 0; i < tanks!.length; i++) {
          var tankRect = tanks[i].toRect();
          for (var j = 0; j < EnemyTankComponent.bornPositions.length; j++) {
            var position = EnemyTankComponent.bornPositions[j];
            if (tankRect.containsPoint(position)) continue;
            game.addToWarMap(generate(position));
          }
        }
      }
    }
  }

  EnemyTankComponent generate(Vector2 targetPosition) {
    return EnemyTankComponent.create(
      position: targetPosition,
      type: tankTypes[_random.nextIntBetween(0, tankTypes.length)],
    );
  }
}
