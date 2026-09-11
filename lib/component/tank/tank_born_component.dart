import 'dart:async';

import 'package:tank90/scene/tank_war_game.dart' show TankWarGame;
import 'package:flame/components.dart';

/// 坦克出生组件
class TankBornComponent extends SpriteAnimationComponent
    with HasGameReference<TankWarGame> {
  TankBornComponent({
    super.position,
    super.size,
    required this.onAnimationFinished,
  }) : super(anchor: Anchor.center);

  final void Function() onAnimationFinished;

  @override
  FutureOr<void> onLoad() {
    removeOnFinish = true;
    var assetImage = game.assetImage;
    var spriteImages = <Sprite>[];
    for (var i = 0; i < 7; i++) {
      spriteImages.add(
        Sprite(
          assetImage,
          srcSize: Vector2.all(32),
          srcPosition: Vector2(256 + i * 32, 32),
        ),
      );
    }
    animation = SpriteAnimation.spriteList(
      spriteImages,
      loop: false,
      stepTime: 0.15,
    );
    animationTicker?.onComplete = () => onAnimationFinished();
  }
}
