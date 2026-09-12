/// 能力类
sealed class Capability {}

/// 被保护能力
class ProtectedCapability extends Capability {
  /// 持续时间
  double holdOnTimeSec;

  /// 构造函数
  ProtectedCapability({this.holdOnTimeSec = 20});
}

/// 火力加强能力
class StrongFireCapability extends Capability {
  /// 火力等级
  int fireLevel;

  /// 构造函数
  StrongFireCapability({this.fireLevel = 1});
}
