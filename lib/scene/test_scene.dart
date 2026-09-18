import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tank90/component/view/number_sprite_component.dart';
import 'package:tank90/data/game_constants.dart';

/// 测试页面
class TestScene extends PositionComponent with RiverpodComponentMixin {
  final Random _random = Random();

  late final NumberSpriteComponent _numberSpriteComponent;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    add(
      _numberSpriteComponent = NumberSpriteComponent(number: 1234567890)
        ..position = Vector2(200, 100),
    );
    add(
      ButtonComponent(
        button: TextComponent(text: '修改数字'),
        onPressed: () => _numberSpriteComponent.number = _random.nextIntBetween(
          0,
          999999999,
        ),
      ),
    );
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
