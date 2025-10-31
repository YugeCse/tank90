import 'dart:async';
import 'dart:math';

import 'package:tank90/component/base/direction.dart' show Direction;
import 'package:tank90/component/base/tank_type.dart' show TankType;
import 'package:tank90/component/tank/base_tank_component.dart'
    show BaseTankComponent;
import 'package:flame/components.dart' show TimerComponent;

/// 地方坦克组件
class EnemyTankComponent extends BaseTankComponent {
  /// 创建敌方坦克实例
  static EnemyTankComponent create({TankType type = TankType.enemy0}) {
    return EnemyTankComponent._(
      type: type,
      speed: type.initialSpeed,
      direction: Direction.random(),
    );
  }

  /// 移动定时器
  TimerComponent? _moveTimer;

  TimerComponent? _fireTimer;

  final Random _random = Random();

  EnemyTankComponent._({
    super.speed,
    super.direction,
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
}
