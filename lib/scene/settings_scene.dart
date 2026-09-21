import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart' hide OverlayRoute;
import 'package:tank90/data/game_constants.dart';

class SettingsScene extends PositionComponent with RiverpodComponentMixin {
  // late final SpriteComponent? _soundAvailableSprite;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    // add(_soundAvailableSprite = SpriteComponent(sprite: Sprite(image)));
  }

  @override
  void onMount() {
    addToGameWidgetBuild(() {});
    super.onMount();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawBackground();
    super.render(canvas);
  }

  /// 布局界面视图
  void _layoutSettingsView() {}
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
          height: 300,
        ),
        .circular(12),
      ),
      paint,
    );
  }
}
