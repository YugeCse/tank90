import 'package:tank90/component/base/capability.dart';
import 'package:tank90/utils/num_utils.dart';

/// 能力控制器类
class CapabilityController {
  final Map<Type, Capability> _capabilities;

  /// 构造函数
  CapabilityController({Map<Type, Capability>? capabilities})
    : _capabilities = capabilities ?? {};

  /// 获取是否有休眠能力
  bool get hasSleepCapability => _capabilities.containsKey(SleepCapability);

  /// 获取是否有被保护的能力
  bool get hasProtectedCapapbility =>
      _capabilities.containsKey(ProtectedCapability);

  /// 获取是否增强火力能力
  bool get hasProwerFireCapability =>
      _capabilities.containsKey(StrongFireCapability);

  /// 获取火力等级
  int get powerFireLevel {
    return !hasProwerFireCapability
        ? 0
        : (_capabilities[StrongFireCapability] as StrongFireCapability?)
                  ?.fireLevel ??
              0;
  }

  /// 获取是否有轮渡能力
  bool get hasFerryCapability => _capabilities.containsKey(FerryCapability);

  /// 放置新能力
  void putCapability(Capability capability) {
    if (capability is! StrongFireCapability) {
      _capabilities[capability.runtimeType] = capability;
    } else {
      var iCapability =
          _capabilities[StrongFireCapability] as StrongFireCapability?;
      if (iCapability == null) {
        _capabilities[StrongFireCapability] = StrongFireCapability();
      } else {
        var level = (iCapability.fireLevel + capability.fireLevel).atMost(4);
        _capabilities[StrongFireCapability] = StrongFireCapability(
          fireLevel: level,
        );
      }
    }
  }

  /// 移除对应能力
  void removeCapability(Type key) => _capabilities.remove(key);

  /// 清除所有能力
  void clearCapabilities() => _capabilities.clear();

  /// 获取所有能力数据
  Map<Type, Capability> get allCapabilities => Map.from(_capabilities);

  /// 根据Key获取能力数据
  T? getCapability<T extends Capability>(Type key) => _capabilities[key] as T?;
}
