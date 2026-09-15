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
  final GameState state;

  /// 游戏等级
  final GameLevel gameLevel;

  /// 声音是否打开
  final bool soundAvailable;

  /// 关卡
  final int stageLevel;

  /// 玩家得分
  final int scoreCount;

  /// 玩家生命数
  final int playerLifes;

  /// 敌人数量
  final int enemyCounts;

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
