// ignore_for_file: constant_identifier_names

import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tank90/app/provider/score_statistics.dart';
import 'package:tank90/app/provider/shared_preferences.dart';
import 'package:tank90/component/base/capability.dart';
import 'package:tank90/data/game_constants.dart';
import 'package:tank90/data/game_properties.dart';
import 'package:tank90/data/global_config_info.dart';
import 'package:tank90/data/map_stage_level.dart';
import 'package:tank90/utils/audio_utils.dart';
import 'package:tank90/utils/num_utils.dart';

part 'global_config.g.dart';

/// 全局配置类
@Riverpod(keepAlive: true)
class GlobalConfig extends _$GlobalConfig {
  @override
  GlobalConfigInfo build() => GlobalConfigInfo();

  GameState get gameState => state.state;

  set gameState(GameState gameState) {
    state = state.copyWith(state: gameState);
  }

  GameLevel get gameLevel => state.gameLevel;

  set gameLevel(GameLevel leve) {
    state = state.copyWith(gameLevel: leve);
    ref.read(sharedPreferencesHandlerProvider).gameLevel = leve;
  }

  bool get soundAvailable => state.soundAvailable;

  set soundAvailable(bool value) {
    AudioUtils().setAllowPlay(value);
    state = state.copyWith(soundAvailable: value);
    ref.read(sharedPreferencesHandlerProvider).isSoundAvailable = value;
  }

  int get stageLevel => state.stageLevel;

  set stageLevel(int level) => state = state.copyWith(stageLevel: level);

  int get scoreCount => state.scoreCount;

  set scoreCount(int score) => state = state.copyWith(scoreCount: score);

  int get playerLifes => state.playerLifes;

  set playerLifes(int count) => state = state.copyWith(playerLifes: count);

  int get enemyCounts => state.enemyCounts;

  set enemyCounts(int count) => state = state.copyWith(enemyCounts: count);

  void incrementScore(int score) =>
      state = state.copyWith(scoreCount: state.scoreCount + score);

  void incrementOneForEnemy() =>
      state = state.copyWith(enemyCounts: state.enemyCounts + 1);

  void decrementOneForEnemy() =>
      state = state.copyWith(enemyCounts: (state.enemyCounts - 1).clamp(0, 20));

  void incrementOneLifeForPlayer() =>
      state = state.copyWith(playerLifes: state.playerLifes + 1);

  void decrementOneLifeForPlayer() =>
      state = state.copyWith(playerLifes: (state.playerLifes - 1).atLeast(0));

  /// 切换到下一关卡
  bool switchToNextStageLevel() {
    var level = stageLevel;
    if (level >= MapStageLevel.maps.length) {
      return false;
    }
    stageLevel = level + 1;
    enemyCounts = GameConstants.ENEMEY_MAX_COUNT;
    ref.read(scoreStatisticsProvider.notifier).clear();
    return true;
  }

  /// 设置缓存的能力集合
  set cacheCapabilities(Map<Type, Capability> value) {
    state = state.copyWith(cacheCapabilities: value);
  }

  /// 获取缓存的能力集合
  Map<Type, Capability> get cacheCapabilities => state.cacheCapabilities ?? {};

  /// 状态重置
  void resetState() {
    stageLevel = 1;
    cacheCapabilities = {}; //清空能力数据
    enemyCounts = GameConstants.ENEMEY_MAX_COUNT;
    playerLifes = GameConstants.DEAULT_PLAYER_LIFES;
    ref.read(scoreStatisticsProvider.notifier).clear();
  }
}

extension GlobalConfigProviderExtension on RiverpodComponentMixin {
  /// 获取全局的GlobalConfig对象
  GlobalConfigInfo get globalConfigInfo => ref.read(globalConfigProvider);

  /// 获取全局的GlobalConfig对象
  GlobalConfig get globalConfig => ref.read(globalConfigProvider.notifier);
}
