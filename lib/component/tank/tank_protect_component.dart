import 'dart:async';

import 'package:flame/components.dart';
import 'package:tank90/scene/tank_war_game.dart';

/// 坦克护甲组件
class TankProtectComponent extends SpriteAnimationComponent
    with HasGameReference<TankWarGame> {
  @override
  FutureOr<void> onLoad() async {
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
