import 'dart:async';
import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tank90/component/base/direction.dart' show Direction;
import 'package:tank90/component/base/tank_type.dart' show TankType;
import 'package:tank90/component/tank/base_tank_component.dart'
    show BaseTankComponent;
import 'package:flame/components.dart'
    show HasGameReference, PositionComponent, TimerComponent, Vector2;
import 'package:tank90/data/map_constants.dart';
import 'package:tank90/data/notifier/prop_tank_attack_notifier.dart';
import 'package:tank90/scene/tank_war_game.dart';

/// 地方坦克组件
class EnemyTankComponent extends BaseTankComponent {
  /// 移动定时器
  TimerComponent? _moveTimer;

  /// 开火定时器
  TimerComponent? _fireTimer;

  /// 随机数计算对象
  final Random _random = Random();

  /// 红坦克闪烁计次，能挨几次攻击
  int redFlickerCounter;

  /// 是否闪烁状态
  bool _isRedFlickerState = false;

  EnemyTankComponent._({
    super.speed,
    super.facingDirection,
    super.position,
    super.type = TankType.enemy0,
    this.redFlickerCounter = 0,
  });

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    add(
      _moveTimer ??= TimerComponent(
        period: 2.0,
        repeat: true,
        onTick: () => setFacingDirection(Direction.random()),
      ),
    );
    _randomFire(); //随机开火
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (redFlickerCounter > 0 && !_isRedFlickerState) {
      _isRedFlickerState = true;
      _showRedFlickerEffect(); //显示红坦克特效
    }
  }

  @override
  void hit() {
    if (redFlickerCounter <= 0) {
      super.hit();
    } else {
      redFlickerCounter--;
      game.mainScene?.onReceiveNotifier(PropTankAttackNotifier());
    }
  }

  /// 显示红坦克特效
  void _showRedFlickerEffect() {
    add(
      CombinedEffect(
        [
          ColorEffect(
            Colors.red,
            EffectController(duration: 1.0, infinite: true),
          ),
          OpacityEffect.fadeOut(
            EffectController(duration: 1.0, infinite: true),
          ),
        ],
        infinite: true,
        alternate: true,
      ),
    );
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
    int redFlickerCounter = 1,
  }) {
    return EnemyTankComponent._(
      position: position,
      type: type,
      speed: type.initialSpeed,
      facingDirection: Direction.random(),
      redFlickerCounter: redFlickerCounter,
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
    with HasGameReference<TankWarGame> {
  final List<TankType> tankTypes = [
    TankType.enemy0,
    TankType.enemy1,
    TankType.enemy2,
    TankType.enemy3,
    TankType.enemy4,
  ];

  /// 每批次允许的数量
  final int maxPerTankCount;

  /// 最大生产数量
  final int maxTotalTankCount;

  /// 统计生产了的数量
  int _produceTankCount = 0;

  /// 随机对象
  late Random _random;

  /// 是否正在生产坦克
  bool _isGeneratingTank = false;

  /// 生产坦克的定时器
  late TimerComponent _factoryTimer;

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

  /// 检查并生成坦克
  void _checkAndGenerateTanks() async {
    if (_produceTankCount >= maxTotalTankCount) {
      _factoryTimer.timer.stop();
      _factoryTimer.removeFromParent();
      debugPrint('所有坦克达到生产总数目：$maxTotalTankCount');
      return;
    }
    if (_isGeneratingTank) return;
    _isGeneratingTank = true;
    var diffCount = maxPerTankCount - (game.enemyTanks?.length ?? 0);
    if (diffCount <= 0) {
      _isGeneratingTank = false;
      return;
    }
    debugPrint('将要要生产的坦克数目：$diffCount');
    while (diffCount > 0) {
      var tanks =
          game.warMapComponent?.children
              .whereType<BaseTankComponent>()
              .toList() ??
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
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }
        var newTank = generate(position);
        game.warMapComponent?.add(newTank);
        if (--diffCount <= 0) {
          debugPrint('本批次所有坦克已经生产完成');
          break; //所有坦克已经生产完成，需要跳出循环
        }
        await Future.delayed(const Duration(milliseconds: 120));
        addedTanks.add(newTank); //记录这个新增的坦克
        _produceTankCount++; //已经生成的坦克数量++
      }
    }
    _isGeneratingTank = false; //标记上一次任务完成
  }

  EnemyTankComponent generate(Vector2 targetPosition) {
    return EnemyTankComponent.create(
      position: targetPosition,
      type: tankTypes[_random.nextIntBetween(0, tankTypes.length)],
    );
  }
}
