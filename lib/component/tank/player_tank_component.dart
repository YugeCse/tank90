import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tank90/component/base/capability.dart';
import 'package:tank90/component/base/direction.dart' show Direction;
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
  double fireSpanTime = 0.5;

  /// 记录上一次的开火时间
  double _lastFireTime = 0;

  /// 虚拟控制器
  JoystickComponent? joystick;

  /// 记录被按下的按键
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  PlayerTankComponent({
    required this.joystick,
    super.speed,
    super.type = TankType.player,
  }) : super(position: defaultPosition);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..isAntiAlias = true
      ..color = Colors.red;
    final (width, length) = switch (cannonType) {
      TankCannonType.normal => (4.0, 10.0),
      TankCannonType.longer => (4.0, 14.0),
      TankCannonType.thicker => (7.0, 10.0),
      TankCannonType.larger => (8.0, 16.0),
    };
    canvas.save();
    // 本地坐标中炮嘴默认朝上，根据坦克朝向旋转炮嘴。
    final angle = atan2(facingDirection.y, facingDirection.x) + pi / 2;
    canvas.rotate(angle);
    final rect = Rect.fromLTWH(-width / 2, -length, width, length);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
      paint,
    );
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateTankAction(); //处理Tank行为
    _controlDirectionByJoystick(); //通过Joystick控制方向
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
  void attacked() {
    // 没有被保护能力且是最大火力炮嘴类型时，能承受1次攻击
    if (capabilities[ProtectedCapability] == null &&
        cannonType == TankCannonType.larger) {
      var capability = capabilities[StrongFireCapability];
      if (capability != null) {
        canFireGrass = false; //不能烧掉草场
        capability = (capability as StrongFireCapability);
        capability.fireLevel = 2;
        capabilities[StrongFireCapability] = capability;
        return;
      }
    }
    super.attacked();
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
      if (diffTimeSec > fireSpanTime) {
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
