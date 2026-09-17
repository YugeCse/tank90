import 'package:tank90/data/score_statistics_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'score_statistics.g.dart';

/// 数据结算类
@Riverpod(keepAlive: true)
class ScoreStatistics extends _$ScoreStatistics {
  @override
  List<ScoreStatisticsInfo> build() => [
    // ...TankType.enemyTankTypes.map(
    //   (type) => ScoreStatisticsInfo(
    //     type: type,
    //     score: Random().nextIntBetween(100, 1000),
    //   ),
    // ),
  ];

  /// 添加新结算数据
  void add(ScoreStatisticsInfo info) => state = [...state, info];

  /// 清空数据
  void clear() => state = [];

  /// 统计某种类型的数量
  /// + [type] - 类型数据
  int countByType(dynamic type) => state.where((el) => el.type == type).length;

  /// 统计某个类型的总分数
  /// + [type] - 类型数据
  int totalScoreByType(dynamic type) => state
      .where((el) => el.type == type)
      .fold(0, (sum, data) => sum + data.score);

  /// 所有统计总分和
  int get totalScore => state.fold(0, (sum, data) => sum + data.score);
}
