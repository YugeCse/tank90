import 'dart:async';
import 'dart:ui' show Image;

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:tank90/component/map/war_map_component.dart';
import 'package:tank90/component/tank/enemy_tank_component.dart';
import 'package:tank90/scene/main_scene.dart';
import 'package:tank90/scene/settings_scene.dart';
import 'package:tank90/scene/stage_screen.dart';
import 'package:tank90/scene/welcome_scene.dart';

/// 游戏主场景
class TankWarGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Image assetImage;

  late final RouterComponent router;

  @override
  FutureOr<void> load() async {
    assetImage = await images.load('tankAll.png');
    add(
      router = RouterComponent(
        initialRoute: 'Welcome',
        routes: {
          'Main': Route(MainScene.new),
          'Stage': Route(StageScreen.new),
          'Welcome': Route(WelcomeScene.new),
          'Settings': OverlayRoute(
            (context, game) => SettingsScene(game: game as TankWarGame),
          ),
        },
      ),
    );
  }

  /// 获取游戏战场地图组件
  WarMapComponent? get warMapComponent =>
      descendants().whereType<WarMapComponent>().firstOrNull;

  /// 获取游戏战场中所有的敌方坦克
  Set<EnemyTankComponent>? get enemyTanks =>
      descendants().whereType<EnemyTankComponent>().toSet();

  /// 游戏主场景
  MainScene? get mainScene => descendants().whereType<MainScene>().firstOrNull;
}
