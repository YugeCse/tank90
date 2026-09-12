/// 能力类
sealed class Capability {}

/// 休眠能力
class SleepCapability extends Capability {
  /// 休眠时长
  double sleepTimeSec;

  /// 构造函数
  SleepCapability({this.sleepTimeSec = 30});
}

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
