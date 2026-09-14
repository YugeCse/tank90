import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:tank90/scene/tank_war_game.dart';
import 'package:tank90/utils/res_img_utils.dart';

/// 游戏结束的组件
class GameOverComponent extends SpriteComponent
    with HasGameReference<TankWarGame> {
  @override
  FutureOr<void> onLoad() async {
    priority = 9999;
    scale = Vector2.all(3.0);
    anchor = Anchor.center;
    sprite = Sprite(
      assetImage,
      srcSize: Vector2(64, 34),
      srcPosition: Vector2(382, 62),
    );
    position = Vector2(game.size.x / 2.0, game.size.y + 34.0 / 2.0);
    _showGameOverEffect(); //显示游戏结束的特效
  }

  // @override
  // void onGameResize(Vector2 size) {
  //   super.onGameResize(size);
  //   position = Vector2(game.size.x / 2.0, game.size.y + 34.0 / 2.0);
  // }

  /// 显示游戏结束的特效
  void _showGameOverEffect() {
    add(MoveEffect.to(game.size / 2.0, EffectController(duration: 5.0)));
    var cEffect = ColorEffect(Colors.white, EffectController(duration: 1.0));
    var oEffect = OpacityEffect.fadeOut(EffectController(duration: 1.0));
    add(CombinedEffect([cEffect, oEffect], infinite: true, alternate: true));
  }
}
