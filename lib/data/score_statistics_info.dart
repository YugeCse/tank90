/// 数据结算实体类
class ScoreStatisticsInfo {
  /// 构造函数
  ScoreStatisticsInfo({
    required this.type,
    this.score = 0,
    this.additionalScore = 0,
  });

  /// 类型
  final dynamic type;

  /// 得分
  final int score;

  /// 额外加分项
  final int additionalScore;

  /// 获取总分数
  int get totalScore => score + additionalScore;
}
