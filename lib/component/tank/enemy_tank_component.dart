import 'dart:async';
import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tank90/component/base/bullet_type.dart';
import 'package:tank90/component/base/capability.dart';
import 'package:tank90/component/base/direction.dart' show Direction;
import 'package:tank90/component/base/tank_type.dart' show TankType;
import 'package:tank90/component/tank/base_tank_component.dart'
    show BaseTankComponent;
import 'package:flame/components.dart'
    show HasGameReference, PositionComponent, TimerComponent, Vector2;
import 'package:tank90/app/provider/global_config.dart';
import 'package:tank90/data/game_constants.dart';
import 'package:tank90/app/notifier/prop_tank_attack_notifier.dart';
import 'package:tank90/app/tank_war_game.dart';

/// 地方坦克组件
class EnemyTankComponent extends BaseTankComponent {
  /// 移动定时器
  TimerComponent? _moveTimer;

  /// 开火定时器
  TimerComponent? _fireTimer;

  /// 红色闪烁组件
  CombinedEffect? _redFlickerEffect;

  /// 随机数计算对象
  final Random _random = Random();

  /// 红坦克闪烁计次，能挨几次攻击
  int redFlickerCounter;

  /// 是否闪烁状态
  bool _isRedFlickerState = false;

  /// 构造函数
  EnemyTankComponent._({
    super.speed,
    super.facingDirection,
    super.position,
    super.type = TankType.enemy0,
    this.redFlickerCounter = 0,
  });

  @override
  void update(double dt) {
    super.update(dt);
    //如果不是出生状态才开启下面的逻辑
    if (!isBornState) {
      if (redFlickerCounter <= 0 && _isRedFlickerState) {
        _isRedFlickerState = false;
        _removeRedFlickerEffect(); //移除红色闪烁效果
      }
      if (capabilityController.hasSleepCapability) {
        _removeAutoMoveTimer();
        _removeRandomFireTime();
      } else {
        if (_moveTimer == null) _startAutoMoveTimer();
        if (_fireTimer == null) _startRandomFireTimer();
      }
    }
  }

  @override
  void onBornFinished() {
    if (redFlickerCounter > 0 && !_isRedFlickerState) {
      _isRedFlickerState = true;
      _showRedFlickerEffect(); //显示红坦克特效
    }
    _startAutoMoveTimer(); //启动自动移动的定时器
    _startRandomFireTimer(); //启动随机开火的定时器
  }

  @override
  void onAdjustPositionStartBeforeCollision() {
    _removeAutoMoveTimer();
    super.onAdjustPositionStartBeforeCollision();
  }

  @override
  void onAdjustPositionEndedAfterCollision() {
    _startAutoMoveTimer();
    super.onAdjustPositionEndedAfterCollision();
  }

  @override
  void attacked() {
    if (capabilityController.hasProtectedCapapbility) return;
    if (capabilityController.hasFerryCapability) {
      capabilityController.removeCapability(FerryCapability);
      return;
    }
    if (redFlickerCounter <= 0) {
      super.attacked();
    } else {
      redFlickerCounter--;
      findMainScene()?.onReceiveNotifier(PropTankAttackNotifier());
    }
  }

  @override
  void onAttackedButNotExplosion() {
    if (explosionProofCount == 1) {
      type = TankType.enemy3;
      updateSprite(type); //更换新的精灵图像
      setFacingDirection(facingDirection);
    } else if (explosionProofCount == 0) {
      type = TankType.enemy4;
      updateSprite(type); //更换新的精灵图像
      setFacingDirection(facingDirection);
    }
  }

  @override
  BulletType getAttackBulletType() {
    var strongFireLevel = capabilityController.powerFireLevel;
    if (strongFireLevel > 0) {
      if ([TankType.enemy2, TankType.enemy3, TankType.enemy4].contains(type) ||
          TankType.enemy0 == type ||
          (TankType.enemy1 == type && strongFireLevel >= 3)) {
        return BulletType.xstrong;
      } else if (strongFireLevel >= 1) {
        return BulletType.strong;
      }
    }
    return super.getAttackBulletType();
  }

  /// 启动自动移动的定时器
  void _startAutoMoveTimer() {
    add(
      _moveTimer ??= TimerComponent(
        period: 2.0,
        repeat: true,
        onTick: () => setFacingDirection(Direction.random()),
      ),
    );
  }

  /// 移除自动移动的定时器
  void _removeAutoMoveTimer() {
    if (_moveTimer != null) {
      _moveTimer?.removeFromParent();
      _moveTimer = null;
    }
  }

  /// 显示红坦克特效
  void _showRedFlickerEffect() {
    if (_redFlickerEffect != null) return;
    add(
      _redFlickerEffect ??= CombinedEffect(
        [
          ColorEffect(
            Colors.red,
            EffectController(duration: 1.0, alternate: true),
          ),
          OpacityEffect.fadeOut(
            EffectController(duration: 1.0, alternate: true),
          ),
        ],
        alternate: true,
        infinite: true,
      ),
    );
  }

  /// 移除红色闪烁特效
  void _removeRedFlickerEffect() {
    if (_redFlickerEffect != null) {
      _redFlickerEffect?.removeFromParent();
      _redFlickerEffect = null;
    }
    // 手动恢复初始状态
    paint.color = Colors.white;
    sprite?.paint.color = Colors.white;
  }

  /// 启动随机开火的定时器
  void _startRandomFireTimer() {
    add(
      _fireTimer ??= TimerComponent(
        onTick: () => fire(
          onFireFinished: () {
            _fireTimer = null;
            _startRandomFireTimer();
          },
        ),
        removeOnFinish: true,
        period: _random.nextDouble() * 3 + 1,
      ),
    );
  }

  /// 移除随机开火的定时器
  void _removeRandomFireTime() {
    if (_fireTimer != null) {
      _fireTimer?.removeFromParent();
      _fireTimer = null;
    }
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
    Vector2(GameConstants.MAP_SIZE.x / 2, 16),
    Vector2(GameConstants.MAP_SIZE.x - 16, 16),
  ];
}

/// 敌方坦克工厂组件
class EnemyTankFactory extends PositionComponent
    with HasGameReference<TankWarGame>, RiverpodComponentMixin {
  /// 每批次允许的数量
  final int maxPerTankCount;

  /// 最大生产数量
  final int maxTotalTankCount;

  /// 红色闪烁的坦克数量
  int redFlickerTankCount = 0;

  /// 随机对象
  final Random _random = Random();

  /// 是否正在生产坦克
  bool _isGeneratingTank = false;

  /// 生成坦克的数量
  int _generateTankCount = 0;

  /// 生产坦克的定时器
  late TimerComponent _factoryTimer;

  EnemyTankFactory({
    this.maxPerTankCount = GameConstants.ENEMY_PER_WAR_COUNT,
    this.maxTotalTankCount = GameConstants.ENEMEY_MAX_COUNT,
    this.redFlickerTankCount = GameConstants.ENEMY_RED_FLICKER_COUNT,
  });

  @override
  void onMount() {
    super.onMount();
    _factoryTimer = TimerComponent(
      period: 2.0,
      repeat: true,
      onTick: _checkAndGenerateTanks,
    );
    add(_factoryTimer); //添加生成定时器
  }

  /// 检查并生成坦克
  void _checkAndGenerateTanks() async {
    if (globalConfigInfo.enemyCounts <= 0) {
      _factoryTimer.timer.stop();
      _factoryTimer.removeFromParent();
      debugPrint('所有坦克达到生产总数目：$maxTotalTankCount');
      return;
    }
    if (_isGeneratingTank) return;
    _isGeneratingTank = true;
    var diffCount = maxPerTankCount - (game.enemyTanks?.length ?? 0);
    if (diffCount <= 0 || globalConfigInfo.enemyCounts <= 0) {
      _isGeneratingTank = false;
      return;
    }
    debugPrint('将要要生产的坦克数目：$diffCount');
    while (diffCount > 0) {
      var allTanks = game.allTanks ?? {};
      var addedTanks = <BaseTankComponent>{};
      for (var j = 0; j < EnemyTankComponent.bornPositions.length; j++) {
        var position = EnemyTankComponent.bornPositions[j];
        var targetRect = Rect.fromCenter(
          width: 32,
          height: 32,
          center: position.toOffset(),
        );
        if (allTanks.any((e) => e.toRect().overlaps(targetRect)) ||
            addedTanks.any((e) => e.toRect().overlaps(targetRect))) {
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }
        var redFlickerCount = [5, 11, 16, 20].contains(_generateTankCount)
            ? _random.nextIntBetween(1, 3)
            : 0;
        var newTank = generate(position, redFlickerCount: redFlickerCount);
        game.warMapComponent?.add(newTank);
        addedTanks.add(newTank); //记录这个新增的坦克
        _generateTankCount++; //生成的坦克数量增加 1 次
        if (globalConfigInfo.enemyCounts > 0) {
          globalConfig.enemyCounts--; //已经生成的坦克数量，总数量减少
        }
        if (--diffCount <= 0) {
          debugPrint('本批次所有坦克已经生产完成');
          break; //所有坦克已经生产完成，需要跳出循环
        }
        await Future.delayed(
          Duration(
            milliseconds: _generateTankCount < 5
                ? 200
                : _random.nextIntBetween(500, 3000),
          ),
        );
      }
    }
    _isGeneratingTank = false; //标记上一次任务完成
  }

  /// 生成敌方坦克
  EnemyTankComponent generate(
    Vector2 targetPosition, {
    int redFlickerCount = 0,
  }) {
    var tankTypes = TankType.enemyTankTypes;
    return EnemyTankComponent.create(
      position: targetPosition,
      redFlickerCounter: redFlickerCount,
      type: tankTypes[_random.nextIntBetween(0, tankTypes.length)],
    );
  }
}
