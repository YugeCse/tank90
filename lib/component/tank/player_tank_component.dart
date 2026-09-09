import 'package:tank90/component/base/direction.dart' show Direction;
import 'package:tank90/component/base/tank_type.dart' show TankType;
import 'package:tank90/data/map_constants.dart' show MapConstants;
import 'package:flame/components.dart'
    show KeyboardHandler, JoystickDirection, Vector2;
import 'package:flame/input.dart' show JoystickComponent;
import 'package:flutter/material.dart' show KeyEvent;
import 'package:flutter/services.dart'
    show LogicalKeyboardKey, KeyDownEvent, KeyUpEvent;
import 'base_tank_component.dart';

/// 玩家坦克组件
class PlayerTankComponent extends BaseTankComponent with KeyboardHandler {
  double fireSpanTime = 0.5;

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
  void update(double dt) {
    super.update(dt);
    _updateTankAction(); //处理Tank行为
    _controlDirectionByJoystick(); //通过Joystick控制方向
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
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW)) {
      setFacingDirection(Direction.up);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.keyS)) {
      setFacingDirection(Direction.down);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.keyA)) {
      setFacingDirection(Direction.left);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.keyD)) {
      setFacingDirection(Direction.right);
    } else {
      velocity = Vector2.zero(); //方向速度归零
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyJ)) {
      var curTimeSec = DateTime.now().millisecondsSinceEpoch / 1000;
      var diffTimeSec = curTimeSec - _lastFireTime;
      if (diffTimeSec > fireSpanTime) {
        _lastFireTime = curTimeSec;
        fire(); //执行开火
      }
    }
  }

  /// 处理键盘事件，返回是否处理该事件
  void handleKeyEvent(KeyEvent event) {
    switch (event) {
      case KeyDownEvent():
        _pressedKeys.add(event.logicalKey);
      case KeyUpEvent():
        _pressedKeys.remove(event.logicalKey);
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    handleKeyEvent(event);
    return super.onKeyEvent(event, keysPressed);
  }

  /// 默认位置
  static Vector2 defaultPosition = Vector2(
    MapConstants.mapSize.x / 2 - MapConstants.mapCellSize.x * 4,
    MapConstants.mapSize.y - MapConstants.mapCellSize.x,
  );
}
