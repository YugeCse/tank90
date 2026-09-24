import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/input.dart';
import 'package:flame/layout.dart';
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
        DragCallbacks,
        RiverpodComponentMixin {
  /// 总的移动y轴距离
  double _totalDeltaY = 0;

  /// 总的移动x轴距离
  double _totalDeltaX = 0;

  /// 关卡数字显示组件
  NumberSpriteComponent? _numberSpriteComponent;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    add(
      PositionComponent(
        size: GameConstants.CANVAS_SIZE,
        children: [
          AlignComponent(
            alignment: .center,
            child: ButtonComponent(
              button: RowComponent(
                children: [
                  SpriteComponent(
                    sprite: Sprite(
                      assetImage,
                      srcSize: Vector2(78, 13),
                      srcPosition: Vector2(396, 96),
                    ),
                    size: Vector2(78.0, 13),
                  ),
                  PositionComponent(size: Vector2(5.0, 2.0)),
                  _numberSpriteComponent = NumberSpriteComponent(number: 0),
                ],
              ),
              onPressed: () => _goToMainGameScene(),
            ),
          ),
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
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _totalDeltaY = 0;
    _totalDeltaX = 0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _totalDeltaY += event.localDelta.y;
    _totalDeltaX += event.localDelta.x;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    const threshold = 50.0; // 滑动阈值，按需调整
    // 判断是否是上下滑动：垂直位移大于阈值，且大于水平位移
    if (_totalDeltaY.abs() > threshold &&
        _totalDeltaY.abs() > _totalDeltaX.abs()) {
      if (_totalDeltaY < 0) {
        debugPrint('向上滑动'); // 处理向上滑动
        _decrementStageLevel();
      } else {
        debugPrint('向下滑动'); // 处理向下滑动
        _incrementStageLevel();
      }
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _totalDeltaX = 0.0;
    _totalDeltaY = 0.0;
    super.onDragCancel(event);
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
        _incrementStageLevel();
      } else if ({
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.keyK,
      }.contains(key)) {
        _decrementStageLevel();
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  /// 减少关卡数设置
  void _decrementStageLevel() {
    var stageLevel = globalConfigInfo.stageLevel - 1;
    globalConfig.stageLevel = stageLevel >= 1
        ? stageLevel
        : MapStageLevel().stageCount;
  }

  /// 增加关卡数设置
  void _incrementStageLevel() {
    var stageLevel = globalConfigInfo.stageLevel + 1;
    globalConfig.stageLevel = stageLevel > MapStageLevel().stageCount
        ? 1
        : stageLevel;
  }

  /// 设置关卡数
  void _setStageLevel(int level) {
    _numberSpriteComponent?.number = level;
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
