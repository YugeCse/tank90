import 'dart:async';
import 'dart:math' hide Rectangle;

import 'package:flame/camera.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart' hide Route, OverlayRoute;
import 'package:tank90/component/map/war_map_component.dart';
import 'package:tank90/component/tank/base_tank_component.dart';
import 'package:tank90/component/tank/enemy_tank_component.dart';
import 'package:tank90/scene/main_scene.dart';
import 'package:tank90/scene/settings_scene.dart';
import 'package:tank90/scene/stage_screen.dart';
import 'package:tank90/scene/statistics_scene.dart';
import 'package:tank90/scene/welcome_scene.dart';

/// 游戏主场景
class TankWarGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        HasCollisionDetection,
        RiverpodGameMixin {
  /// 页面路由对象，跳转到支持的场景
  late final RouterComponent router;

  @override
  FutureOr<void> load() async {
    await images.load('tankAll.png');
    camera.viewport = FixedAspectRatioViewport(aspectRatio: 1.0);
    camera.viewfinder.anchor = .topLeft;
    world.add(
      router = RouterComponent(
        initialRoute: 'Welcome',
        routes: {
          'Main': Route(MainScene.new),
          'Stage': Route(StageScreen.new),
          'Welcome': Route(WelcomeScene.new),
          'Settings': OverlayRoute(
            (_, game) => SettingsScene(
              onRequestSceneClose: router.pop,
              rootContainerSize: Size(game.size.x, game.size.y),
            ),
          ),
          'Statistics': Route(StatisticsScene.new),
        },
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    var m = min(size.x, size.y);
    camera.setBounds(Rectangle.fromLTWH(0, 0, m, m));
  }

  /// 获取游戏战场地图组件
  WarMapComponent? get warMapComponent =>
      descendants().whereType<WarMapComponent>().firstOrNull;

  /// 获取游戏战场中所有的坦克集合
  Set<BaseTankComponent>? get allTanks =>
      descendants().whereType<BaseTankComponent>().toSet();

  /// 获取游戏战场中所有的敌方坦克集合
  Set<EnemyTankComponent>? get enemyTanks =>
      descendants().whereType<EnemyTankComponent>().toSet();

  /// 游戏主场景
  MainScene? get mainScene => descendants().whereType<MainScene>().firstOrNull;
}
