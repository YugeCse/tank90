import 'dart:async';
import 'dart:io';
import 'dart:ui' show Image;

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Route, Image;
import 'package:tank90/component/base/tank_type.dart';
import 'package:tank90/component/joystick/joystic_fire_component.dart'
    show JoystickFireComponent;
import 'package:tank90/component/joystick/joystick_bg_component.dart';
import 'package:tank90/component/joystick/joystick_knob_component.dart';
import 'package:tank90/component/map/war_map_component.dart'
    show WarMapComponent;
import 'package:tank90/component/tank/enemy_tank_component.dart';
import 'package:tank90/component/tank/player_tank_component.dart'
    show PlayerTankComponent;
import 'package:tank90/data/notifier/tank_bom_notifier.dart'
    show TankBomNotifier;
import 'package:tank90/scene/tank_war_game.dart';
import 'package:tank90/utils/audio_utils.dart';

class MainScene extends Component with HasGameReference<TankWarGame> {
  WarMapComponent? mapComponent;
  PlayerTankComponent? playerTank;

  JoystickComponent? joystick;
  JoystickFireComponent? joystickFire;

  @override
  FutureOr<void> onLoad() async {
    AudioUtils().playStart(); //播放开始的声音
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

  /// 添加到战场地图
  void addToWarMap(PositionComponent comp) => mapComponent?.add(comp);
}
