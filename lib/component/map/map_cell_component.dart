import 'dart:async';

import 'package:tank90/component/base/hitbox_mixin.dart';
import 'package:tank90/component/base/map_cell_type.dart' show MapCellType;
import 'package:tank90/scene/game_scene.dart' show GameScene;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// 地图单元组件
class MapCellComponent extends SpriteComponent
    with HasGameReference<GameScene>, HitboxMixin {
  /// 地图单元类型
  MapCellType type;

  MapCellComponent({required this.type, super.position})
    : super(size: MapCellType.size);

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    if (type == MapCellType.grass) {
      priority = 900;
    }
    sprite = Sprite(
      game.assetImage,
      srcSize: MapCellType.size,
      srcPosition: type.srcPosition,
    );
    add(hitbox = RectangleHitbox(size: size - Vector2.all(2.0)));
  }

  void setRemoveFromParent() {
    removeFromParent();
    hitbox.collisionType = CollisionType.inactive;
  }
}
