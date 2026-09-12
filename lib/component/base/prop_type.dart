import 'package:flame/extensions.dart';

/// 装备类型
sealed class PropType {
  /// 资源尺寸
  final Vector2 srcSize;

  /// 资源坐标
  final Vector2 srcPosition;

  /// 构造方法
  PropType({required this.srcSize, required this.srcPosition});
}

/// 坦克装备，增加一个玩家生命
class TankPropType extends PropType {
  TankPropType()
    : super(srcSize: Vector2(30.0, 28.0), srcPosition: Vector2(256.0, 110.0));
}

/// 定时器装备，暂停画面中对方的坦克
class TimerPropType extends PropType {
  TimerPropType()
    : super(srcSize: Vector2(30.0, 28.0), srcPosition: Vector2(286, 110));
}

/// BOSS保护装备
class BossProtectPropType extends PropType {
  BossProtectPropType()
    : super(srcSize: Vector2(30.0, 28.0), srcPosition: Vector2(316, 110));
}

/// 炸弹装备
class BoomPropType extends PropType {
  BoomPropType()
    : super(srcSize: Vector2(30, 28), srcPosition: Vector2(346, 110));
}

/// 五角星装备
class StarPropType extends PropType {
  StarPropType()
    : super(srcSize: Vector2(30, 28), srcPosition: Vector2(376, 110));
}

/// 钢盔帽装备
class HatProtectPropType extends PropType {
  HatProtectPropType()
    : super(srcSize: Vector2(30, 28), srcPosition: Vector2(406, 110));
}
