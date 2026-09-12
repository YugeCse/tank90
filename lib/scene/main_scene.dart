import 'dart:async';
import 'dart:io';
import 'dart:math' show max;

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
import 'package:tank90/component/tank/prop_component.dart';
import 'package:tank90/data/global_config.dart';
import 'package:tank90/data/notifier/boom_all_notifier.dart';
import 'package:tank90/data/notifier/boss_protected_notifier.dart';
import 'package:tank90/data/notifier/prop_tank_attack_notifier.dart';
import 'package:tank90/data/notifier/tank_bom_notifier.dart'
    show TankBomNotifier;
import 'package:tank90/scene/tank_war_game.dart';
import 'package:tank90/utils/audio_utils.dart';

/// 主场景
class MainScene extends Component with HasGameReference<TankWarGame> {
  /// 游戏地图对象
  WarMapComponent? mapComponent;

  /// 道具工厂对象
  PropFactoryComponent? _propFactoryComponent;

  /// 玩家坦克对象
  PlayerTankComponent? playerTank;

  /// 虚拟方向操作组件
  JoystickComponent? joystick;

  /// 虚拟开火组件
  JoystickFireComponent? joystickFire;

  @override
  FutureOr<void> onLoad() async {
    AudioUtils().playStart(); //播放开始的声音
    add(
      mapComponent ??= WarMapComponent(
        stage: max(GlobalConfig.stageLevel - 1, 0),
      ),
    );
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
    add(
      TimerComponent(
        period: 1.0,
        repeat: false,
        removeOnFinish: true,
        onTick: _addPlayerTank,
      ),
    );
    mapComponent?.add(
      _propFactoryComponent = PropFactoryComponent(),
    ); //添加装备道具工厂组件
    mapComponent?.add(EnemyTankFactory()); //添加敌方坦克工厂组件
  }

  /// 接受消息事件
  void onReceiveNotifier(dynamic event) {
    if (event is TankBomNotifier) {
      if (event.type == TankType.player) {
        if (--GlobalConfig.playerLifes > 0) {
          _addPlayerTank(); //添加玩家坦克
        } else {
          ///TODO Game Over !
        }
      } else {
        if (GlobalConfig.enemyCounts == 0 &&
            (game.enemyTanks?.isEmpty ?? true)) {
          ///TODO Jump To Next Stage Level
        }
      }
    } else if (event is BoomAllNotifier) {
      _boomAllTanks(event); //炸死所有坦克的通知
    } else if (event is PropTankAttackNotifier) {
      _propFactoryComponent?.generateProp(); //生成道具组件
    } else if (event is BossProtectedNotifier) {
      mapComponent?.changeBossWallState(event.state);
    }
  }

  /// 炸死所有坦克的通知
  void _boomAllTanks(BoomAllNotifier event) {
    if (event.ownerType == TankType.player) {
      var allEnemies = mapComponent
          ?.descendants()
          .whereType<EnemyTankComponent>();
      if (allEnemies == null) return;
      for (var enemy in allEnemies) {
        enemy.bomAndDestroy(); //调用爆炸的方法
      }
    } else {
      var allPlayers = mapComponent
          ?.descendants()
          .whereType<PlayerTankComponent>();
      if (allPlayers == null) return;
      for (var player in allPlayers) {
        player.bomAndDestroy(); //调用爆炸的方法
      }
    }
  }

  /// 添加玩家坦克
  void _addPlayerTank() {
    if (playerTank != null) {
      playerTank?.removeFromParent();
    }
    playerTank = null;
    mapComponent?.add(playerTank ??= PlayerTankComponent(joystick: joystick));
  }
}
