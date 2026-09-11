import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tank90/scene/tank_war_game.dart';

/// 还原场景
class WelcomeScene extends Component with HasGameReference<TankWarGame> {
  late final SpriteComponent _welcomeComponent;
  OpacityEffect? _opacityEffect;
  @override
  FutureOr<void> onLoad() async {
    add(
      _welcomeComponent = SpriteComponent(
        sprite: Sprite(await game.images.load('test.jpeg')),
      ),
    );
    add(
      ButtonComponent(
        button: TextComponent(
          text: 'Settings',
          textRenderer: TextPaint(
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        onPressed: () {
          _removeOpacityEffect();
          game.router.pushNamed('Settings');
        },
      ),
    );
    _addOpacityEffect(); //默认添加透明特效
  }

  /// 添加透明过渡特效
  void _addOpacityEffect() {
    _welcomeComponent.add(
      _opacityEffect = OpacityEffect.fadeOut(
        EffectController(duration: 5),
        onComplete: () => _changeToStageScene(),
      ),
    );
  }

  /// 删除透明过渡特效
  void _removeOpacityEffect() {
    if (_opacityEffect == null) {
      return;
    }
    _opacityEffect?.removeFromParent();
    _opacityEffect = null;
  }

  /// 切换到关卡场景
  void _changeToStageScene() {
    game.router.pushReplacementNamed('Stage');
  }
}
