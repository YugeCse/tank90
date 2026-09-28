import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tank90/app/app_router.dart';
import 'package:tank90/app/tank_war_game.dart';
import 'package:tank90/data/game_constants.dart';
import 'package:tank90/utils/res_img_utils.dart';

/// 还原场景
class WelcomeScene extends Component
    with HasGameReference<TankWarGame>, RiverpodComponentMixin {
  /// 透明特效对象
  OpacityEffect? _opacityEffect;

  /// 欢迎dlogo组件
  SpriteComponent? _welcomeComponent;

  /// 设置按钮组件
  ButtonComponent? _settingsButtonComponent;

  @override
  FutureOr<void> onLoad() async {
    add(
      _welcomeComponent = SpriteComponent(
        sprite: Sprite(await game.images.load('menu.png')),
      ),
    );
    add(
      _settingsButtonComponent = ButtonComponent(
        anchor: Anchor.topRight,
        button: SpriteComponent(
          sprite: Sprite(
            uiDesignImage,
            srcSize: Vector2(48, 16),
            srcPosition: Vector2(64, 48),
          ),
        )..tint(Colors.white),
        onPressed: _showSettingsScene,
      ),
    );
    add(
      ButtonComponent(
        anchor: .center,
        button: SpriteComponent(
          sprite: Sprite(
            uiDesignImage,
            srcSize: Vector2(64, 16),
            srcPosition: Vector2(0, 96),
          ),
        ),
        onPressed: _changeToStageScene,
        position: Vector2(
          GameConstants.CANVAS_SIZE.x / 2.0,
          GameConstants.CANVAS_SIZE.y - 64.0,
        ),
      ),
    );
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
    }
    if (_settingsButtonComponent != null) {
      _settingsButtonComponent?.position = Vector2(game.size.x - 40.0, 13.0);
    }
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
    game.router.pushNamed(AppRouter.ROUTE_SETTINGS);
  }

  /// 切换到关卡场景
  void _changeToStageScene() =>
      game.router.pushReplacementNamed(AppRouter.ROUTE_STAGE);
}
