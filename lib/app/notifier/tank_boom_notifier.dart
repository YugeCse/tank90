import 'package:tank90/component/base/tank_type.dart';

/// 坦克爆炸通知
class TankBoomNotifier {
  /// 爆炸坦克类型
  final TankType type;

  /// 额外分数
  final int additionalScore;

  /// 构造方法
  TankBoomNotifier({required this.type, this.additionalScore = 0});
}
