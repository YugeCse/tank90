import 'package:tank90/data/statistics/score_statistics_info.dart';

/// 数据结算类
class ScoreStatistics {
  ScoreStatistics._();

  factory ScoreStatistics.create() => ScoreStatistics._();

  /// 结算数据集合
  final _data = <ScoreStatisticsInfo>[];

  /// 添加新结算数据
  void add(ScoreStatisticsInfo info) => _data.add(info);

  // void add(dynamic type, int score) =>
  //     _data.add(ScoreStatisticsInfo(type: type, score: score));

  /// 清空数据
  void clear() => _data.clear();

  /// 统计某种类型的数量
  /// + [type] - 类型数据
  int countByType(dynamic type) => _data.where((el) => el.type == type).length;

  /// 统计某个类型的总分数
  /// + [type] - 类型数据
  int totalScoreByType(dynamic type) => _data
      .where((el) => el.type == type)
      .fold(0, (sum, data) => sum + data.score);

  /// 所有统计总分和
  int get totalScore => _data.fold(0, (sum, data) => sum + data.score);
}
