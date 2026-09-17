import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:tank90/app/app_router.dart';
import 'package:tank90/component/map/war_map_component.dart';
import 'package:tank90/component/tank/base_tank_component.dart';
import 'package:tank90/component/tank/enemy_tank_component.dart';
import 'package:tank90/scene/main_scene.dart';

/// 游戏主场景
class TankWarGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        HasCollisionDetection,
        RiverpodGameMixin {
  TankWarGame()
    : super(
        camera: CameraComponent.withFixedResolution(width: 416.0, height: 416.0)
          ..viewfinder.anchor = .topLeft,
      );

  /// 页面路由对象，跳转到支持的场景
  late final RouterComponent router;

  @override
  FutureOr<void> load() async {
    await images.load('tankAll.png');
    world.add(
      router = RouterComponent(
        initialRoute: AppRouter.INIT_ROUTE,
        routes: AppRouter.buildRouteConfigs(
          requestRouterPop: () => router.pop(),
        ),
      ),
    );
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
