import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;
import 'package:tank90/app/provider/global_config.dart';
import 'package:tank90/data/map_stage_level.dart';
import 'package:tank90/scene/tank_war_game.dart';

/// 关卡场景
class StageScreen extends Component
    with
        HasGameReference<TankWarGame>,
        KeyboardHandler,
        RiverpodComponentMixin {
  /// 关卡文本组件
  late TextComponent _stageComponent;

  @override
  FutureOr<void> onLoad() async {
    var stageLevel = globalConfig.stageLevel;
    add(
      _stageComponent = TextComponent(
        text: 'STAGE $stageLevel',
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
  void onMount() {
    addToGameWidgetBuild(
      () => ref.listen(globalConfigProvider, (pre, next) {
        _stageComponent.text = 'STAGE ${next.stageLevel}';
      }),
    );
    super.onMount();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      var key = event.logicalKey;
      if ({LogicalKeyboardKey.enter, LogicalKeyboardKey.space}.contains(key)) {
        _goToMainGameScene();
        debugPrint('点击了Enter键');
      } else if ({
        LogicalKeyboardKey.arrowUp,
        LogicalKeyboardKey.keyJ,
      }.contains(key)) {
        var stageLevel = globalConfig.stageLevel - 1;
        globalConfig.stageLevel = stageLevel >= 1
            ? stageLevel
            : MapStageLevel.maps.length;
      } else if ({
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.keyK,
      }.contains(key)) {
        var stageLevel = globalConfig.stageLevel + 1;
        globalConfig.stageLevel = stageLevel > MapStageLevel.maps.length
            ? 1
            : stageLevel;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  /// 跳转到主界面
  void _goToMainGameScene() {
    game.router.pushReplacementNamed('Main');
  }
}
