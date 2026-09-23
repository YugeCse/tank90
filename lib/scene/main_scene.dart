import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Route, Image;
import 'package:tank90/app/app_router.dart';
import 'package:tank90/app/notifier/enemy_increment_notifier.dart';
import 'package:tank90/component/base/capability.dart';
import 'package:tank90/component/base/find_type.dart';
import 'package:tank90/component/base/tank_type.dart';
import 'package:tank90/component/joystick/joystic_fire_component.dart'
    show JoystickFireComponent;
import 'package:tank90/component/joystick/joystick_bg_component.dart';
import 'package:tank90/component/joystick/joystick_knob_component.dart';
import 'package:tank90/component/map/game_over_component.dart';
import 'package:tank90/component/map/war_map_component.dart'
    show WarMapComponent;
import 'package:tank90/component/tank/enemy_tank_component.dart';
import 'package:tank90/component/tank/player_tank_component.dart'
    show PlayerTankComponent;
import 'package:tank90/component/tank/prop_component.dart';
import 'package:tank90/component/view/info_sidebar_component.dart';
import 'package:tank90/data/game_constants.dart';
import 'package:tank90/data/game_properties.dart';
import 'package:tank90/app/provider/global_config.dart';
import 'package:tank90/data/map_stage_level.dart';
import 'package:tank90/app/notifier/boom_all_notifier.dart';
import 'package:tank90/app/notifier/boss_protected_notifier.dart';
import 'package:tank90/app/notifier/game_over_notifier.dart';
import 'package:tank90/app/notifier/prop_tank_attack_notifier.dart';
import 'package:tank90/app/notifier/tank_boom_notifier.dart'
    show TankBoomNotifier;
import 'package:tank90/app/provider/score_statistics.dart';
import 'package:tank90/data/score_statistics_info.dart';
import 'package:tank90/app/tank_war_game.dart';
import 'package:tank90/utils/audio_utils.dart';

/// 主场景
class MainScene extends Component
    with HasGameReference<TankWarGame>, RiverpodComponentMixin {
  /// 游戏地图对象
  WarMapComponent? mapComponent;

  /// 侧边信息栏
  InfoSidebarComponent? _infoSidebarComponent;

  /// 道具工厂对象
  PropFactoryComponent? _propFactoryComponent;

  /// 玩家坦克对象
  PlayerTankComponent? playerTank;

  /// 游戏结束的事件
  GameOverComponent? _gameOverComponent;

  /// 虚拟方向操作组件
  JoystickComponent? joystick;

  /// 虚拟开火组件
  JoystickFireComponent? joystickFire;

  @override
  FutureOr<void> onLoad() async {
    if (!kIsWeb &&
        ([
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform))) {
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
              onFireTap: () => playerTank?.attack(),
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
    AudioUtils().playStart(); //播放开始的声音
  }

  @override
  void onMount() {
    addToGameWidgetBuild(() {
      Future.microtask(() {
        ref.read(globalConfigProvider.notifier).gameState = GameState.playing;
      });
    });
    super.onMount();
    var curStage = (globalConfigInfo.stageLevel - 1).clamp(
      0,
      MapStageLevel.maps.length - 1,
    );
    add(
      mapComponent ??= WarMapComponent(
        stage: curStage,
        position: Vector2.zero(),
      ),
    );
    mapComponent?.add(
      _propFactoryComponent = PropFactoryComponent(),
    ); //添加装备道具工厂组件
    mapComponent?.add(EnemyTankFactory()); //添加敌方坦克工厂组件
    add(
      _infoSidebarComponent = InfoSidebarComponent()
        ..position = Vector2(GameConstants.MAP_SIZE.x, 0),
    );
  }

  /// 接受消息事件
  void onReceiveNotifier(dynamic event) async {
    debugPrint('onReceiveNotifier 接收到事件：$event');
    if (event is GameOverNotifier) {
      showGameOver(); //显示游戏结束的界面
    } else if (event is TankBoomNotifier) {
      if (event.type == TankType.player) {
        if (--globalConfig.playerLifes > 0) {
          _addPlayerTank(); //添加玩家坦克
        } else {
          globalConfig.playerLifes = 0;
          showGameOver(); //显示游戏结束的界面
        }
      } else {
        _infoSidebarComponent?.removeOneEnemySprite();
        var statisticsInfo = ScoreStatisticsInfo(
          type: event.type,
          score: event.type.score,
          additionalScore: event.additionalScore,
        );
        ref.read(scoreStatisticsProvider.notifier).add(statisticsInfo);
        var isGameWin =
            globalConfigInfo.enemyCounts <= 0 &&
            (game.enemyTanks?.isEmpty ?? true);
        if (isGameWin) {
          //保存上一个关卡的坦克获得的能力
          if (playerTank != null) {
            globalConfig.cacheCapabilities = playerTank?.capabilities ?? {};
          }
          add(
            TimerComponent(
              period: 6,
              removeOnFinish: true,
              onTick: () =>
                  game.router.pushReplacementNamed(AppRouter.ROUTE_STATISTICS),
            ),
          ); //跳转新的关卡界面
        }
      }
    } else if (event is BoomAllNotifier) {
      _boomAllTanks(event); //炸死所有坦克的通知
    } else if (event is PropTankAttackNotifier) {
      _propFactoryComponent?.generateProp(); //生成道具组件
    } else if (event is BossProtectedNotifier) {
      mapComponent?.changeBossWallState(event.state);
    } else if (event is EnemyIncrementNotifier) {
      _infoSidebarComponent?.addEnemySprite();
    }
  }

  /// 炸死所有坦克的通知
  void _boomAllTanks(BoomAllNotifier event) {
    if (event.ownerType != TankType.player) {
      var allPlayers = mapComponent
          ?.descendants()
          .whereType<PlayerTankComponent>();
      if (allPlayers == null) return;
      for (var player in allPlayers) {
        player.boomAndDestroy(); //调用爆炸的方法
      }
    } else {
      var allEnemies = mapComponent
          ?.descendants()
          .whereType<EnemyTankComponent>();
      if (allEnemies == null) return;
      for (var enemy in allEnemies) {
        enemy.boomAndDestroy(); //调用爆炸的方法
        _infoSidebarComponent?.removeOneEnemySprite(); //爆炸一个，删除一个记录
      }
    }
  }

  /// 添加玩家坦克
  void _addPlayerTank() {
    if (playerTank != null) {
      playerTank?.removeFromParent();
      playerTank = null;
    }
    var capabilities = ref.read(globalConfigProvider).cacheCapabilities;
    mapComponent?.add(
      playerTank ??= PlayerTankComponent(
        joystick: joystick,
        facingDirection: Vector2(0.0, -1.0),
        capabilities: Map.from(capabilities ?? {}),
      ),
    );
  }

  /// 冻结敌方坦克
  void freezeEnemyTanks() {
    game.enemyTanks?.forEach(
      (el) => el.capabilityController.putCapability(SleepCapability()),
    );
  }

  /// 冻结玩家坦克
  void freezePlayerTank() =>
      playerTank?.capabilityController.putCapability(SleepCapability());

  /// 显示游戏失效的界面
  void showGameOver() {
    if (_gameOverComponent != null) return;
    ref.read(globalConfigProvider.notifier).gameState = GameState.gameOver;
    add(
      TimerComponent(
        period: 10,
        removeOnFinish: true,
        onTick: () =>
            game.router.pushReplacementNamed(AppRouter.ROUTE_STATISTICS),
      ),
    );
    add(_gameOverComponent ??= GameOverComponent()); //显示游戏结束的界面
  }
}

/// 主场景混淆类
mixin MainSceneMixin on Component {
  /// 查找主场景对象
  /// + [type] - 查找方式，默认：向上查找
  MainScene? findMainScene({FindType type = FindType.ancestors}) {
    return (type == FindType.ancestors ? ancestors() : descendants())
            .whereType<MainScene>()
            .firstOrNull ??
        findGame()?.descendants().whereType<MainScene>().firstOrNull;
  }
}
