import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tank90/component/view/info_sidebar_component.dart';
import 'package:tank90/data/game_constants.dart';

/// 测试页面
class TestScene extends PositionComponent with RiverpodComponentMixin {
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    add(InfoSidebarComponent());
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 480, 416),
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..color = GameConstants.CANVAS_BG_COLOR,
    );
    super.render(canvas);
  }
}
