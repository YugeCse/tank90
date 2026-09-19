import 'dart:async';

import 'package:flame/components.dart';
import 'package:tank90/component/tank/player_tank_component.dart';
import 'package:tank90/data/game_constants.dart';

/// 测试页面
class TestScene extends PositionComponent {
  @override
  FutureOr<void> onLoad() async {
    size = GameConstants.CANVAS_SIZE;
    add(PlayerTankComponent(position: Vector2.all(100.0))..debugMode = true);
  }
}
