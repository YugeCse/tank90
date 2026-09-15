// ignore_for_file: constant_identifier_names

import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tank90/app/provider/shared_preferences.dart';
import 'package:tank90/data/game_properties.dart';
import 'package:tank90/data/global_config_info.dart';
import 'package:tank90/utils/audio_utils.dart';
import 'package:tank90/utils/num_utils.dart';

part 'global_config.g.dart';

/// 全局配置类
@Riverpod(keepAlive: true)
class GlobalConfig extends _$GlobalConfig {
  @override
  GlobalConfigInfo build() => GlobalConfigInfo();

  GameState get gameState => state.state;

  set gameState(GameState state) {
    this.state = this.state.copyWith(state: state);
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
}

extension GlobalConfigProviderExtension on RiverpodComponentMixin {
  /// 获取全局的GlobalConfig对象
  GlobalConfig get globalConfig => ref.read(globalConfigProvider.notifier);
}
