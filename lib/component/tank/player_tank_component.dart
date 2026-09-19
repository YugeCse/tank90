import 'package:flutter/material.dart';
import 'package:tank90/component/base/bullet_type.dart';
import 'package:tank90/component/base/capability.dart';
import 'package:tank90/component/base/direction.dart' show Direction;
import 'package:tank90/component/base/prop_type.dart';
import 'package:tank90/component/base/tank_cannon_type.dart';
import 'package:tank90/component/base/tank_type.dart' show TankType;
import 'package:tank90/data/game_constants.dart' show GameConstants;
import 'package:flame/components.dart'
    show KeyboardHandler, JoystickDirection, Vector2;
import 'package:flame/input.dart' show JoystickComponent;
import 'package:flutter/services.dart'
    show LogicalKeyboardKey, KeyDownEvent, KeyUpEvent;
import 'package:tank90/data/game_properties.dart';
import 'package:tank90/app/provider/global_config.dart';
import 'base_tank_component.dart';

/// 玩家坦克组件
class PlayerTankComponent extends BaseTankComponent with KeyboardHandler {
  /// 开火间隔时间
  double _fireSpanTime = 0.5;

  /// 记录上一次的开火时间
  double _lastFireTime = 0;

  /// 虚拟控制器
  JoystickComponent? joystick;

  /// 记录被按下的按键
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  /// 构造函数
  PlayerTankComponent({
    this.joystick,
    Vector2? position,
    super.speed,
    super.type = TankType.player,
    super.facingDirection,
    super.capabilities,
  }) : super(position: position ?? defaultPosition);

  @override
  void update(double dt) {
    super.update(dt);
    if (!isBornState) {
      _updateTankAction(); //处理Tank行为
      _controlDirectionByJoystick(); //通过Joystick控制方向
    }
  }

  /// 根据当前火力等级获取炮嘴类型。
  TankCannonType get cannonType {
    final capability = capabilities[StrongFireCapability];
    if (capability is! StrongFireCapability) {
      return TankCannonType.normal;
    }
    switch (capability.fireLevel) {
      case 1:
        return TankCannonType.longer;
      case 2:
        return TankCannonType.thicker;
      default:
        return capability.fireLevel >= 3
            ? TankCannonType.larger
            : TankCannonType.normal;
    }
  }

  @override
  Vector2 getSrcPosition(Vector2 facingDir) {
    if (cannonType != TankCannonType.normal) {
      debugPrint('-----> facingDir $facingDir');
      return type.getSrcPositionByCannonType(
        type: cannonType,
        facingDirection: facingDir,
      );
    }
    return super.getSrcPosition(facingDir);
  }

  @override
  void attacked() {
    // 没有被保护能力且是最大火力炮嘴类型时，能承受1次攻击
    if (capabilities[ProtectedCapability] == null &&
        cannonType == TankCannonType.larger) {
      var capability = capabilities[StrongFireCapability];
      if (capability != null) {
        capability = (capability as StrongFireCapability);
        capability.fireLevel = 2;
        capabilities[StrongFireCapability] = capability;
        return;
      }
    }
    super.attacked();
  }

  @override
  BulletType getAttackBulletType() {
    switch (cannonType) {
      case TankCannonType.thicker:
        return BulletType.strong;
      case TankCannonType.larger:
        return BulletType.xstrong;
      default:
        return super.getAttackBulletType();
    }
  }

  @override
  void fetchProp(PropType type) {
    super.fetchProp(type);
    if (_fireSpanTime > 0.3 &&
        ((capabilities[StrongFireCapability] as StrongFireCapability?)
                    ?.fireLevel ??
                0) >=
            1) {
      _fireSpanTime = 0.3; //如果已经获得了火力加持，直接减少发射炮弹的间隔时间
    }
  }

  /// 通过Joystick控制方向
  void _controlDirectionByJoystick() {
    if (joystick != null) {
      var dir = joystick!.direction;
      if (dir == JoystickDirection.up) {
        setFacingDirection(Direction.up);
      } else if (dir == JoystickDirection.down) {
        setFacingDirection(Direction.down);
      } else if (dir == JoystickDirection.left) {
        setFacingDirection(Direction.left);
      } else if (dir == JoystickDirection.right) {
        setFacingDirection(Direction.right);
      } else if (dir == JoystickDirection.idle) {
        velocity = Vector2.zero();
      }
    }
  }

  /// 处理Tank行为
  void _updateTankAction() {
    if (_pressedKeys.contains(LogicalKeyboardKey.keyJ)) {
      var curTimeSec = DateTime.now().millisecondsSinceEpoch / 1000;
      var diffTimeSec = curTimeSec - _lastFireTime;
      if (diffTimeSec > _fireSpanTime) {
        _lastFireTime = curTimeSec;
        attack(); //执行开火
      }
    }
    if (capabilities.containsKey(SleepCapability)) return;
    // 处理方向 - 使用标志位
    bool hasDirection = false;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW)) {
      hasDirection = true;
      setFacingDirection(Direction.up);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.keyS)) {
      hasDirection = true;
      setFacingDirection(Direction.down);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.keyA)) {
      hasDirection = true;
      setFacingDirection(Direction.left);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.keyD)) {
      hasDirection = true;
      setFacingDirection(Direction.right);
    }
    if (!hasDirection) velocity = Vector2.zero(); //方向速度归零
  }

  /// 处理键盘事件，返回是否处理该事件
  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (globalConfigInfo.state == GameState.playing && !isBornState) {
      handleKeyEvent(event);
    }
    return super.onKeyEvent(event, keysPressed);
  }

  /// 默认位置
  static Vector2 defaultPosition = Vector2(
    GameConstants.MAP_SIZE.x / 2 - GameConstants.MAP_CELL_SIZE.x * 4,
    GameConstants.MAP_SIZE.y - GameConstants.MAP_CELL_SIZE.x,
  );
}
