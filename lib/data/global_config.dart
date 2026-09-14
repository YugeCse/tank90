// ignore_for_file: constant_identifier_names

import 'package:tank90/data/game_constants.dart';
import 'package:tank90/data/game_level.dart';
import 'package:tank90/data/provider/score_statistics.dart';

/// 全局配置类
class GlobalConfig {
  GlobalConfig._();

  /// 游戏等级
  static GameLevel gameLevel = GameLevel.easy;

  /// 关卡
  static int stageLevel = 1;

  /// 玩家得分
  static int scoreCount = 0;

  /// 玩家生命数
  static int playerLifes = 3;

  /// 敌人数量
  static int enemyCounts = GameConstants.ENEMEY_MAX_COUNT;

  /// 数据结算对象
  static ScoreStatistics dataStatistics = ScoreStatistics();
}
