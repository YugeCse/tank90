import 'dart:async';
import 'dart:io';
import 'dart:ui' show Image;

import 'package:tank90/component/base/tank_type.dart' show TankType;
import 'package:tank90/component/joystick/joystic_fire_component.dart'
    show JoystickFireComponent;
import 'package:tank90/component/joystick/joystick_bg_component.dart'
    show JoystickBgComponent;
import 'package:tank90/component/joystick/joystick_knob_component.dart'
    show JoystickKnobComponent;
import 'package:tank90/component/map/war_map_component.dart';
import 'package:tank90/component/tank/enemy_tank_component.dart';
import 'package:tank90/component/tank/player_tank_component.dart'
    show PlayerTankComponent;
import 'package:tank90/data/notifier/tank_bom_notifier.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show EdgeInsets;
import 'package:tank90/scene/main_scene.dart';
import 'package:tank90/scene/settings_scene.dart';
import 'package:tank90/scene/stage_screen.dart';
import 'package:tank90/scene/welcome_scene.dart';
import 'package:tank90/utils/audio_utils.dart';

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
