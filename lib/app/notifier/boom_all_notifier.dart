import 'package:tank90/component/base/prop_type.dart';
import 'package:tank90/component/base/tank_type.dart';

/// 炸死所有的通知
class BoomAllNotifier {
  /// 装备类型
  PropType type;

  /// 拥有者的类型
  TankType ownerType;

  /// 构造函数
  BoomAllNotifier({required this.type, required this.ownerType});
}
