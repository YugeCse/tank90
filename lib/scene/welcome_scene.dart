import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:tank90/scene/tank_war_game.dart';

/// 还原场景
class WelcomeScene extends Component with HasGameReference<TankWarGame> {
  /// 透明特效对象
  OpacityEffect? _opacityEffect;

  /// 欢迎dlogo组件
  SpriteComponent? _welcomeComponent;

  /// 设置按钮组件
  ButtonComponent? _settingsButtonComponent;

  /// 开始按钮组件
  ButtonComponent? _startButtonComponent;

  @override
  FutureOr<void> onLoad() async {
    add(
      _welcomeComponent = SpriteComponent(
        sprite: Sprite(await game.images.load('menu.gif')),
      ),
    );
    add(
      _settingsButtonComponent = ButtonComponent(
        anchor: Anchor.topRight,
        button: TextComponent(
          text: 'Settings',
          textRenderer: TextPaint(
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        onPressed: _showSettingsScene,
      ),
    );
    add(
      _startButtonComponent = ButtonComponent(
        button: TextComponent(
          text: 'START GAME',
          textRenderer: TextPaint(
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
        ),
        onPressed: _changeToStageScene,
      ),
    );
    _addOpacityEffect(); //默认添加透明特效
    _adjustComponentPositions(); //调整welcome图标的位置
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _adjustComponentPositions(); //调整welcome图标的位置
  }

  /// 调整welcome图标的位置
  void _adjustComponentPositions() {
    if (_welcomeComponent != null) {
      _welcomeComponent?.position = (game.size - _welcomeComponent!.size) / 2.0;
      if (_startButtonComponent != null) {
        _startButtonComponent?.position = Vector2(
          (game.size.x - _startButtonComponent!.x) / 2.0,
          _welcomeComponent!.y + _welcomeComponent!.size.y + 30.0,
        );
      }
    }
    if (_settingsButtonComponent != null) {
      _settingsButtonComponent?.position = Vector2(game.size.x - 20.0, 30.0);
    }
  }

  /// 添加透明过渡特效
  void _addOpacityEffect() {
    _welcomeComponent?.add(
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

  /// 显示设置场景
  void _showSettingsScene() async {
    _removeOpacityEffect();
    game.router.pushOverlay('Settings');
  }

  /// 切换到关卡场景
  void _changeToStageScene() {
    game.router.pushReplacementNamed('Stage');
  }
}
