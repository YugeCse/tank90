import 'dart:async';

import 'package:tank90/scene/game_scene.dart' show GameScene;
import 'package:flame/components.dart';

/// Boss组件
class BossComponent extends SpriteComponent with HasGameReference<GameScene> {
  /// 是否还存活
  bool isAlive;

  BossComponent({super.position, this.isAlive = true});

  @override
  FutureOr<void> onLoad() {
    setSpriteByState(); //设置精灵状态
  }

  @override
  void update(double dt) {
    super.update(dt);
    setSpriteByState(); //设置精灵状态
  }

  /// 设置精灵状态
  void setSpriteByState() {
    sprite = Sprite(
      game.assetImage,
      srcSize: Vector2.all(32),
      srcPosition: Vector2(256 + (isAlive ? 0 : 32), 0),
    );
  }
}
