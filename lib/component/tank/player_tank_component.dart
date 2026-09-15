import 'package:flutter/widgets.dart';
import 'package:tank90/component/base/capability.dart';
import 'package:tank90/component/base/direction.dart' show Direction;
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
