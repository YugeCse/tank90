import 'dart:async';
import 'dart:ui' show Image;

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:tank90/scene/main_scene.dart';
import 'package:tank90/scene/settings_scene.dart';
import 'package:tank90/scene/stage_screen.dart';
import 'package:tank90/scene/welcome_scene.dart';

/// 游戏主场景
class TankWarGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  TankWarGame();
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
}
