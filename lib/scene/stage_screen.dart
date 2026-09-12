import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;
import 'package:tank90/data/global_config.dart';
import 'package:tank90/data/map_stage_level.dart';
import 'package:tank90/scene/tank_war_game.dart';

/// 关卡场景
class StageScreen extends Component
    with HasGameReference<TankWarGame>, KeyboardHandler {
  int _stageLevel = 1;

  late TextComponent _stageComponent;

  @override
  FutureOr<void> onLoad() async {
    _stageLevel = GlobalConfig.stageLevel;
    add(
      _stageComponent = TextComponent(
        text: 'STAGE $_stageLevel',
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 56,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
        position: game.size / 2,
      ),
    );
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      var key = event.logicalKey;
      if ({LogicalKeyboardKey.enter, LogicalKeyboardKey.space}.contains(key)) {
        _changeToMainGameScene();
        debugPrint('点击了Enter键');
      } else if ({
        LogicalKeyboardKey.arrowUp,
        LogicalKeyboardKey.keyJ,
      }.contains(key)) {
        _stageLevel--;
        if (_stageLevel <= 1) {
          _stageLevel = MapStageLevel.maps.length;
        }
        GlobalConfig.stageLevel = _stageLevel;
        _stageComponent.text = "STAGE $_stageLevel";
      } else if ({
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.keyK,
      }.contains(key)) {
        _stageLevel++;
        if (_stageLevel > MapStageLevel.maps.length) {
          _stageLevel = 1;
        }
        GlobalConfig.stageLevel = _stageLevel;
        _stageComponent.text = "STAGE $_stageLevel";
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void _changeToMainGameScene() {
    game.router.pushReplacementNamed('Main');
  }
}
