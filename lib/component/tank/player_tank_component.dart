import 'package:tank90/component/base/direction.dart' show Direction;
import 'package:tank90/component/base/tank_type.dart' show TankType;
import 'package:tank90/data/map_constants.dart' show MapConstants;
import 'package:flame/components.dart'
    show KeyboardHandler, JoystickDirection, Vector2;
import 'package:flame/input.dart' show JoystickComponent;
import 'package:flutter/material.dart' show KeyEvent;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'base_tank_component.dart';

/// 玩家坦克组件
class PlayerTankComponent extends BaseTankComponent with KeyboardHandler {
  JoystickComponent? joystick;

  PlayerTankComponent({
    required this.joystick,
    super.speed,
    super.type = TankType.player,
  }) : super(position: defaultPosition);

  @override
  void update(double dt) {
    super.update(dt);
    _controlDirectionByJoystick(); //通过Joystick控制方向
  }

  /// 通过Joystick控制方向
  void _controlDirectionByJoystick() {
    if (joystick != null) {
      var dir = joystick!.direction;
      if (dir == JoystickDirection.up) {
        setTankDirection(Direction.up);
      } else if (dir == JoystickDirection.down) {
        setTankDirection(Direction.down);
      } else if (dir == JoystickDirection.left) {
        setTankDirection(Direction.left);
      } else if (dir == JoystickDirection.right) {
        setTankDirection(Direction.right);
      } else if (dir == JoystickDirection.idle) {
        direction = Vector2.zero();
      }
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (handleKeyEvent(event)) return true;
    return super.onKeyEvent(event, keysPressed);
  }

  /// 默认位置
  static Vector2 defaultPosition = Vector2(
    MapConstants.mapSize.x / 2 - MapConstants.mapCellSize.x * 4,
    MapConstants.mapSize.y - MapConstants.mapCellSize.x,
  );
}
