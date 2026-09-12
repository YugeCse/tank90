import 'package:tank90/component/base/boss_wall_state.dart';

/// Boss 保护墙通知事件
class BossProtectedNotifier {
  /// 绘制指定的砖块，如果为 NULL 则清除砖块
  BossWallState state;

  /// 构造方法
  BossProtectedNotifier({required this.state});
}
