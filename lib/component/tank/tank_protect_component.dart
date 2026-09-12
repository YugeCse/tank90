import 'dart:async';

import 'package:flame/components.dart';
import 'package:tank90/scene/tank_war_game.dart';

/// 坦克护甲组件
class TankProtectComponent extends SpriteAnimationComponent
    with HasGameReference<TankWarGame> {
  /// 失效时长
  final double disableTimeSec;

  /// 销毁事件
  final void Function() onDestroy;

  /// 构造函数
  TankProtectComponent({this.disableTimeSec = 60.0, required this.onDestroy});

  @override
  FutureOr<void> onLoad() async {
    add(
      TimerComponent(
        period: disableTimeSec,
        removeOnFinish: true,
        onTick: () {
          removeFromParent();
          onDestroy();
        },
      ),
    );
    List<SpriteAnimationFrame> imageFrames = [
      SpriteAnimationFrame(
        Sprite(
          game.assetImage,
          srcPosition: Vector2(160.0, 96.0),
          srcSize: Vector2(32.0, 32.0),
        ),
        0.15,
      ),
      SpriteAnimationFrame(
        Sprite(
          game.assetImage,
          srcPosition: Vector2(160.0, 128.0),
          srcSize: Vector2(32.0, 32.0),
        ),
        0.15,
      ),
    ];
    animation = SpriteAnimation(imageFrames, loop: true);
  }
}
