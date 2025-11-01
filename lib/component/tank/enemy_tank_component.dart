import 'dart:async';
import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flutter/rendering.dart';
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

  final int maxPerTankCount;

  final int maxTotalTankCount;

  int _produceTankCount = 0;

  late Random _random;

  late TimerComponent _factoryTimer;

  bool _isLastTaskComplete = true;

  EnemyTankFactory({this.maxPerTankCount = 5, this.maxTotalTankCount = 20});

  @override
  FutureOr<void> onLoad() {
    _random = Random();
    _factoryTimer = TimerComponent(
      period: 2.0,
      repeat: true,
      onTick: _checkAndGenerateTanks,
    );
    add(_factoryTimer); //添加生成定时器
  }

  void _checkAndGenerateTanks() async {
    if (_produceTankCount >= maxTotalTankCount) {
      _factoryTimer.timer.stop();
      _factoryTimer.removeFromParent();
      debugPrint('达到生成总数目！');
      return;
    }
    if (!_isLastTaskComplete) return;
    _isLastTaskComplete = false;
    var diffCount = maxPerTankCount - game.enemyTanks.length;
    if (diffCount <= 0) return;
    debugPrint('要生成数目：$diffCount');
    while (diffCount > 0) {
      var tanks =
          game.mapComponent?.children.whereType<BaseTankComponent>().toList() ??
          [];
      var addedTanks = <BaseTankComponent>[];
      for (var j = 0; j < EnemyTankComponent.bornPositions.length; j++) {
        var position = EnemyTankComponent.bornPositions[j];
        var targetRect = Rect.fromCenter(
          width: 32,
          height: 32,
          center: position.toOffset(),
        );
        if (tanks.any((e) => e.toRect().overlaps(targetRect)) ||
            addedTanks.any((e) => e.toRect().overlaps(targetRect))) {
          debugPrint('有其他坦克，无法在该位置生成');
          await Future.delayed(const Duration(milliseconds: 200));
          continue;
        }
        var newTank = generate(position);
        game.addToWarMap(newTank);
        await Future.delayed(const Duration(milliseconds: 120));
        addedTanks.add(newTank); //记录这个新增的坦克
        _produceTankCount++; //已经生成的坦克数量++
      }
      diffCount = maxPerTankCount - game.enemyTanks.length;
    }
    _isLastTaskComplete = true; //标记上一次任务完成
  }

  EnemyTankComponent generate(Vector2 targetPosition) {
    return EnemyTankComponent.create(
      position: targetPosition,
      type: tankTypes[_random.nextIntBetween(0, tankTypes.length)],
    );
  }
}
