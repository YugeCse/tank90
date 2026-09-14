// ignore_for_file: constant_identifier_names

import 'package:tank90/data/game_level.dart';
import 'package:tank90/utils/score_statistics.dart';

/// 全局配置类
class GlobalConfig {
  GlobalConfig._();

  /// 敌人最大数量: 20
  static const ENEMEY_MAX_COUNT = 20;

  /// 每场战场同时出现的敌方坦克数量: 5
  static const ENEMY_PER_WAR_COUNT = 5;

  /// 敌方红坦克数量：3
  static const ENEMY_RED_FLICKER_COUNT = 3;

  /// 关卡
  static int stageLevel = 1;

  /// 玩家得分
  static int scoreCount = 0;

  /// 玩家生命数
  static int playerLifes = 3;

  /// 敌人数量
  static int enemyCounts = ENEMEY_MAX_COUNT;

  /// 游戏等级
  static GameLevel gameLevel = GameLevel.easy;

  /// 数据结算对象
  static ScoreStatistics dataStatistics = ScoreStatistics.create();
}
