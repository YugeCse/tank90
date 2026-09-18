import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;
import 'package:tank90/app/app_router.dart';
import 'package:tank90/app/provider/global_config.dart';
import 'package:tank90/component/view/number_sprite_component.dart';
import 'package:tank90/data/game_constants.dart';
import 'package:tank90/data/map_stage_level.dart';
import 'package:tank90/app/tank_war_game.dart';
import 'package:tank90/utils/res_img_utils.dart';

/// 关卡场景
class StageScreen extends Component
    with
        HasGameReference<TankWarGame>,
        KeyboardHandler,
        DoubleTapCallbacks,
        RiverpodComponentMixin {
  /// 间隔值
  final double _spacer = 2.0;

  /// StageLevel整个组件
  PositionComponent? _stageLevelComponent;

  /// Stage图标组件
  SpriteComponent? _stageSpriteComponent;

  /// 关卡数字显示组件
  NumberSpriteComponent? _numberSpriteComponent;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    add(
      _stageLevelComponent = PositionComponent(
        position: game.size / 2,
        children: [
          _stageSpriteComponent = SpriteComponent(
            sprite: Sprite(
              assetImage,
              srcSize: Vector2(78, 13),
              srcPosition: Vector2(396, 96),
            ),
            size: Vector2(78.0, 13),
          )..position = Vector2(0, 0),
          _numberSpriteComponent = NumberSpriteComponent(number: 0)
            ..position = Vector2(78.0 + _spacer, 0),
        ],
      ),
    );
  }

  /// 监听数据变化
  void listenDataChanged() {
    _setStageLevel(globalConfigInfo.stageLevel);
    ref.listen(
      globalConfigProvider,
      (_, next) => _setStageLevel(next.stageLevel),
    );
  }

  @override
  void onMount() {
    addToGameWidgetBuild(listenDataChanged);
    super.onMount();
  }

  @override
  void render(Canvas canvas) {
    // var paint = Paint()
    //   ..isAntiAlias = true
    //   ..style = PaintingStyle.fill
    //   ..color = GameConstants.CANVAS_BG_COLOR;
    // canvas.drawRect(GameConstants.CANVAS_RECT, paint);
    // paint.color = Colors.amber;
    // canvas.drawLine(
    //   Offset(0, GameConstants.CANVAS_SIZE.y / 2),
    //   Offset(GameConstants.CANVAS_SIZE.x, GameConstants.CANVAS_SIZE.y / 2),
    //   paint,
    // );
    // canvas.drawLine(
    //   Offset(GameConstants.CANVAS_SIZE.x / 2, 0),
    //   Offset(GameConstants.CANVAS_SIZE.x / 2, GameConstants.CANVAS_SIZE.y),
    //   paint,
    // );
    super.render(canvas);
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

  /// 设置关卡数
  void _setStageLevel(int level) {
    _numberSpriteComponent?.number = level;
    var stageSpriteSize = Vector2(
      (_stageSpriteComponent?.size.x ?? 0) +
          _spacer +
          (_numberSpriteComponent?.size.x ?? 0),
      (_stageSpriteComponent?.size.y ?? 0),
    );
    _stageLevelComponent?.size = stageSpriteSize;
    _stageLevelComponent?.position = Vector2(
      (GameConstants.CANVAS_SIZE.x - stageSpriteSize.x - _spacer) / 2.0,
      (GameConstants.CANVAS_SIZE.y - stageSpriteSize.y - _spacer) / 2.0,
    );
  }

  @override
  void onDoubleTapUp(DoubleTapEvent event) {
    super.onDoubleTapUp(event);
    game.router.pushReplacementNamed(AppRouter.ROUTE_MAIN);
  }

  /// 跳转到主界面
  void _goToMainGameScene() =>
      game.router.pushReplacementNamed(AppRouter.ROUTE_MAIN);
}
