import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart' hide OverlayRoute;
import 'package:tank90/app/provider/global_config.dart';
import 'package:tank90/app/tank_war_game.dart';
import 'package:tank90/data/game_constants.dart';

/// 设置弹窗界面
class SettingsScene extends PositionComponent
    with RiverpodComponentMixin, HasGameReference<TankWarGame> {
  late final Sprite _musicOpenSprite;
  late final Sprite _musicCloseSprite;
  late final SpriteComponent? _musicStatusSprite;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    _musicCloseSprite = await Sprite.load('music_close.png');
    _musicOpenSprite = await Sprite.load('music_open.png');
    var offsetX = (GameConstants.CANVAS_SIZE.x - 300.0) / 2.0;
    var offsetY = (GameConstants.CANVAS_SIZE.y - 200.0) / 2.0;
    var offsetMx = GameConstants.CANVAS_SIZE.x - offsetX;
    var offsetMy = GameConstants.CANVAS_SIZE.y - offsetY;
    add(
      SpriteComponent(
        sprite: await Sprite.load('game_settings.png'),
        position: Vector2(offsetX + 20, offsetY + 15),
      ),
    );
    add(
      SpriteComponent(
        sprite: await Sprite.load('game_music.png'),
        position: Vector2(offsetX + 20, offsetY + 62),
      ),
    );
    add(
      ButtonComponent(
        onPressed: _toggleGameMusicStatus,
        position: Vector2(offsetMx - 48, offsetY + 62),
        button: _musicStatusSprite = SpriteComponent(sprite: _musicCloseSprite),
      ),
    );
    add(
      ButtonComponent(
        anchor: .center,
        onPressed: _closeDialog,
        button: SpriteComponent(
          sprite: await Sprite.load('game_settings_close.png'),
        ),
        position: Vector2(GameConstants.CANVAS_SIZE.x / 2.0, offsetMy - 32),
      ),
    );
  }

  @override
  void onMount() {
    addToGameWidgetBuild(() {
      var globalConfig = ref.read(globalConfigProvider);
      _musicStatusSprite?.sprite = globalConfig.soundAvailable
          ? _musicCloseSprite
          : _musicOpenSprite;
      ref.listen(globalConfigProvider, (_, next) {
        _musicStatusSprite?.sprite = next.soundAvailable
            ? _musicCloseSprite
            : _musicOpenSprite;
      });
    });
    super.onMount();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawBackground();
    super.render(canvas);
  }

  /// 切换游戏声音状态
  void _toggleGameMusicStatus() {
    var globalConfig = ref.read(globalConfigProvider);
    var targetValue = !globalConfig.soundAvailable;
    _musicStatusSprite?.sprite = targetValue
        ? _musicCloseSprite
        : _musicOpenSprite;
    ref.read(globalConfigProvider.notifier).soundAvailable = targetValue;
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
      ..color = Colors.white.withValues(alpha: 0.8);
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
