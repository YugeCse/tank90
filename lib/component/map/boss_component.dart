import 'dart:async';

import 'package:tank90/data/notifier/game_over_notifier.dart';
import 'package:tank90/scene/tank_war_game.dart' show TankWarGame;
import 'package:flame/components.dart';
import 'package:tank90/utils/audio_utils.dart';

/// Boss组件
class BossComponent extends SpriteComponent with HasGameReference<TankWarGame> {
  /// 是否还存活
  bool _isAlive;

  /// 爆炸物组件
  late SpriteAnimationComponent _boomComponent;

  /// 构造方法
  BossComponent({super.position, bool isAlive = true}) : _isAlive = isAlive;

  @override
  FutureOr<void> onLoad() {
    _setSpriteByState(_isAlive); //设置精灵状态
    _boomComponent = SpriteAnimationComponent(
      animation: SpriteAnimation.spriteList([
        Sprite(
          game.assetImage,
          srcPosition: Vector2(320, 0),
          srcSize: Vector2.all(32.0),
        ),
        Sprite(
          game.assetImage,
          srcPosition: Vector2(352, 0),
          srcSize: Vector2.all(32.0),
        ),
        Sprite(
          game.assetImage,
          srcPosition: Vector2(384, 0),
          srcSize: Vector2.all(32.0),
        ),
      ], stepTime: 0.15),
      removeOnFinish: true,
    );
    _boomComponent.animationTicker?.onComplete = () =>
        game.mainScene?.onReceiveNotifier(GameOverNotifier());
  }

  /// 设置精灵状态
  void _setSpriteByState(bool isAlive) {
    sprite = Sprite(
      game.assetImage,
      srcSize: Vector2.all(32),
      srcPosition: Vector2(256 + (isAlive ? 0 : 32), 0),
    );
  }

  /// 显示被破坏的特效
  void _showDestroyEffect() {
    AudioUtils().playPlayerCrack();
    game.warMapComponent?.add(_boomComponent);
  }

  /// 设置为死亡状态
  void setDeathState() {
    _isAlive = false;
    _showDestroyEffect(); //显示爆炸效果
    _setSpriteByState(false); //设置为死亡状态
  }
}
