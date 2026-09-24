import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart' hide OverlayRoute;
import 'package:tank90/app/provider/global_config.dart';
import 'package:tank90/app/tank_war_game.dart';
import 'package:tank90/component/view/game_level_radio_component.dart';
import 'package:tank90/data/game_constants.dart';
import 'package:tank90/data/game_properties.dart';
import 'package:tank90/utils/res_img_utils.dart';

/// 设置弹窗界面
class SettingsScene extends PositionComponent
    with RiverpodComponentMixin, HasGameReference<TankWarGame> {
  late final List<Sprite> _checkSprites;
  late final SpriteComponent? _musicStatusSprite;
  late final Map<GameLevel, GameLevelRadioComponent> _gameLevelComponents = {};

  /// 加载组件集合
  FutureOr<void> _loadComponents() async {
    _checkSprites = [
      Sprite(
        uiDesignImage,
        srcSize: Vector2.all(16),
        srcPosition: Vector2(96, 0),
      ),
      Sprite(
        uiDesignImage,
        srcSize: Vector2.all(16),
        srcPosition: Vector2(96, 16),
      ),
    ];
    var offsetX = (GameConstants.CANVAS_SIZE.x - 300.0) / 2.0;
    var offsetY = (GameConstants.CANVAS_SIZE.y - 200.0) / 2.0;
    var offsetMx = GameConstants.CANVAS_SIZE.x - offsetX;
    var offsetMy = GameConstants.CANVAS_SIZE.y - offsetY;
    add(
      // 游戏设置
      SpriteComponent(
        sprite: Sprite(
          uiDesignImage,
          srcSize: Vector2(56, 16),
          srcPosition: Vector2.zero(),
        ),
        position: Vector2(offsetX + 20, offsetY + 15),
      ),
    );
    add(
      // 声音设置
      SpriteComponent(
        sprite: Sprite(
          uiDesignImage,
          srcSize: Vector2(56, 16),
          srcPosition: Vector2(0, 16),
        ),
        position: Vector2(offsetX + 20, offsetY + 62),
      ),
    );
    add(
      // 音乐开关选项
      ButtonComponent(
        button: _musicStatusSprite = SpriteComponent(
          sprite: _checkSprites.first,
        ),
        onPressed: _toggleGameMusicStatus,
        position: Vector2(offsetMx - 36, offsetY + 62),
      ),
    );
    add(
      // 游戏难度
      SpriteComponent(
        sprite: Sprite(
          uiDesignImage,
          srcSize: Vector2(56, 16),
          srcPosition: Vector2(0, 32),
        ),
        position: Vector2(offsetX + 20, offsetY + 94),
      ),
    );
    _gameLevelComponents[.easy] = GameLevelRadioComponent(
      level: .easy,
      position: Vector2(offsetMx - 164, offsetY + 94),
      onCheckChanged: (value) {
        if (!value) return;
        _toggleGameLevel(.easy);
      },
    );
    add(_gameLevelComponents[GameLevel.easy]!);
    _gameLevelComponents[.normal] = GameLevelRadioComponent(
      level: .normal,
      position: Vector2(offsetMx - 116, offsetY + 94),
      onCheckChanged: (value) {
        if (!value) return;
        _toggleGameLevel(.normal);
      },
    );
    add(_gameLevelComponents[GameLevel.normal]!);
    _gameLevelComponents[.difficulty] = GameLevelRadioComponent(
      level: .difficulty,
      position: Vector2(offsetMx - 68, offsetY + 94),
      onCheckChanged: (value) {
        if (!value) return;
        _toggleGameLevel(.difficulty);
      },
    );
    add(_gameLevelComponents[GameLevel.difficulty]!);
    add(
      ButtonComponent(
        anchor: .center,
        onPressed: _closeDialog,
        button: SpriteComponent(
          sprite: Sprite(
            uiDesignImage,
            srcSize: Vector2(44, 23),
            srcPosition: Vector2(50, 64),
          ),
        ),
        position: Vector2(GameConstants.CANVAS_SIZE.x / 2.0, offsetMy - 32),
      ),
    );
  }

  @override
  void onMount() {
    _loadComponents(); //加载组件合集
    addToGameWidgetBuild(() {
      var globalConfig = ref.read(globalConfigProvider);
      _setGameLevelSprite(globalConfig.gameLevel);
      _setGameMusicStatusSprite(globalConfig.soundAvailable);
      ref.listen(globalConfigProvider, (_, next) {
        _setGameLevelSprite(next.gameLevel);
        _setGameMusicStatusSprite(next.soundAvailable);
      });
    });
    super.onMount();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawBackground();
    super.render(canvas);
  }

  /// 设置音乐开关的sprite
  void _setGameMusicStatusSprite(bool isAvailable) {
    _musicStatusSprite?.sprite = isAvailable
        ? _checkSprites.last
        : _checkSprites.first;
  }

  /// 切换游戏声音状态
  void _toggleGameMusicStatus() {
    var globalConfig = ref.read(globalConfigProvider);
    var targetValue = !globalConfig.soundAvailable;
    ref.read(globalConfigProvider.notifier).soundAvailable = targetValue;
  }

  /// 设置游戏等级的sprite
  void _setGameLevelSprite(GameLevel target) {
    for (var key in _gameLevelComponents.keys) {
      _gameLevelComponents[key]?.isChecked = key == target;
    }
  }

  /// 切换游戏等级设置
  void _toggleGameLevel(GameLevel target) {
    if (!isMounted) return;
    debugPrint('current target: $target');
    ref.read(globalConfigProvider.notifier).gameLevel = target;
  }

  /// 关闭当前页面
  void _closeDialog() => game.router.pop();
}

extension _CanvasDrawer on Canvas {
  /// 绘制背景
  void drawBackground() {
    clearScreen();
    var paint = Paint()
      ..isAntiAlias = true
      ..style = .fill
      ..color = const Color.fromARGB(255, 128, 128, 128).withValues(alpha: 0.8);
    drawRoundRectBackground(paint);
    paint
      ..style = .stroke
      ..color = Colors.grey
      ..strokeWidth = 3.0;
    drawRoundRectBackground(paint);
  }

  /// 清屏处理
  void clearScreen() {
    drawRect(
      GameConstants.CANVAS_RECT,
      Paint()
        ..isAntiAlias = true
        ..style = .fill
        ..color = const Color.fromARGB(189, 0, 0, 0),
    );
  }

  /// 绘制矩形背景
  void drawRoundRectBackground(Paint paint) {
    drawRRect(
      .fromRectAndRadius(
        .fromCenter(
          center: (GameConstants.CANVAS_SIZE / 2.0).toOffset(),
          width: 300,
          height: 200,
        ),
        .circular(12),
      ),
      paint,
    );
  }
}
