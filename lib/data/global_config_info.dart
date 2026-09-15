import 'package:tank90/data/game_constants.dart';
import 'package:tank90/data/game_properties.dart';

/// 全局配置实体类
class GlobalConfigInfo {
  GlobalConfigInfo({
    this.state = GameState.playing,
    this.gameLevel = GameLevel.easy,
    this.soundAvailable = false,
    this.stageLevel = 1,
    this.scoreCount = 0,
    this.playerLifes = 3,
    this.enemyCounts = GameConstants.ENEMEY_MAX_COUNT,
  });

  /// 游戏状态
  GameState state = GameState.playing;

  /// 游戏等级
  GameLevel gameLevel = GameLevel.easy;

  /// 声音是否打开
  bool soundAvailable = false;

  /// 关卡
  int stageLevel = 1;

  /// 玩家得分
  int scoreCount = 0;

  /// 玩家生命数
  int playerLifes = 3;

  /// 敌人数量
  int enemyCounts = GameConstants.ENEMEY_MAX_COUNT;

  /// 复制一个对象
  GlobalConfigInfo copyWith({
    GameState? state,
    GameLevel? gameLevel,
    bool? soundAvailable,
    int? stageLevel,
    int? scoreCount,
    int? playerLifes,
    int? enemyCounts,
  }) => GlobalConfigInfo(
    state: state ?? this.state,
    gameLevel: gameLevel ?? this.gameLevel,
    stageLevel: stageLevel ?? this.stageLevel,
    scoreCount: scoreCount ?? this.scoreCount,
    playerLifes: playerLifes ?? this.playerLifes,
    enemyCounts: enemyCounts ?? this.enemyCounts,
    soundAvailable: soundAvailable ?? this.soundAvailable,
  );
}
