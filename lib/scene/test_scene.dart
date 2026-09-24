import 'dart:async';

import 'package:flame/components.dart';
import 'package:tank90/scene/settings_scene.dart';

/// 测试页面
class TestScene extends PositionComponent {
  @override
  FutureOr<void> onLoad() async {
    add(SettingsScene());
  }
}
