import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;
import 'package:tank90/app/app_router.dart';
import 'package:tank90/app/provider/global_config.dart';
import 'package:tank90/data/map_stage_level.dart';
import 'package:tank90/app/tank_war_game.dart';

/// 关卡场景
class StageScreen extends Component
    with
        HasGameReference<TankWarGame>,
        KeyboardHandler,
        RiverpodComponentMixin {
  /// 关卡文本组件
  TextComponent? _stageComponent;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    add(
      _stageComponent = TextComponent(
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 56,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        text: 'STAGE --',
        anchor: Anchor.center,
        position: game.size / 2,
      ),
    );
  }

  /// 监听数据变化
  void listenDataChanged() {
    var stageLevel = globalConfigInfo.stageLevel;
    _stageComponent?.text = 'STAGE $stageLevel';
    ref.listen(globalConfigProvider, (pre, next) {
      _stageComponent?.text = 'STAGE ${next.stageLevel}';
    });
  }

  @override
  void onMount() {
    addToGameWidgetBuild(listenDataChanged);
    super.onMount();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      var key = event.logicalKey;
      if ({LogicalKeyboardKey.enter, LogicalKeyboardKey.space}.contains(key)) {
        _goToMainGameScene();
      } else if ({
        LogicalKeyboardKey.arrowUp,
        LogicalKeyboardKey.keyJ,
      }.contains(key)) {
        var stageLevel = globalConfigInfo.stageLevel - 1;
        globalConfig.stageLevel = stageLevel >= 1
            ? stageLevel
            : MapStageLevel.maps.length;
      } else if ({
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.keyK,
      }.contains(key)) {
        var stageLevel = globalConfigInfo.stageLevel + 1;
        globalConfig.stageLevel = stageLevel > MapStageLevel.maps.length
            ? 1
            : stageLevel;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  /// 跳转到主界面
  void _goToMainGameScene() =>
      game.router.pushReplacementNamed(AppRouter.ROUTE_MAIN);
}
