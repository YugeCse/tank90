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

/// 游戏主场景
class GameScene extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  GameScene();

  late Image assetImage;
  JoystickComponent? joystick;
  JoystickFireComponent? joystickFire;
  WarMapComponent? mapComponent;
  PlayerTankComponent? playerTank;

  @override
  FutureOr<void> load() async {
    assetImage = await images.load('tankAll.png');
    add(mapComponent ??= WarMapComponent(stage: 1));
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      add(
        joystick = JoystickComponent(
          priority: 1000,
          knob: JoystickKnobComponent(),
          background: JoystickBgComponent(),
          margin: const EdgeInsets.only(left: 40, bottom: 40),
        ),
      );
      add(
        HudMarginComponent(
          priority: 1000,
          margin: EdgeInsets.only(bottom: 120, right: 120),
          children: [
            joystickFire = JoystickFireComponent(
              onFireTap: () => playerTank?.fire(),
            ),
          ],
        ),
      );
    }
    add(EnemyTankFactory()); //添加敌方坦克工厂组件
    addToWarMap(playerTank ??= PlayerTankComponent(joystick: joystick));
  }

  /// 接受消息事件
  void onReceiveNotifier(dynamic event) {
    if (event is TankBomNotifier) {
      if (event.type == TankType.player) {
        playerTank = null;
        addToWarMap(playerTank ??= PlayerTankComponent(joystick: joystick));
      }
    }
  }

  /// 获取地图上还有的敌方坦克信息
  Iterable<EnemyTankComponent> get enemyTanks =>
      mapComponent?.children.whereType<EnemyTankComponent>() ?? [];

  /// 添加到战场地图
  void addToWarMap(PositionComponent comp) => mapComponent?.add(comp);
}
