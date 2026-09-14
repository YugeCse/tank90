import 'dart:async';

import 'package:tank90/component/base/hitbox_mixin.dart';
import 'package:tank90/component/base/map_cell_type.dart' show MapCellType;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:tank90/utils/res_img_utils.dart';

/// 地图单元组件
class MapCellComponent extends SpriteComponent with HitboxMixin {
  /// 地图单元类型
  MapCellType type;

  /// 构造方法
  MapCellComponent({required this.type, super.position})
    : super(size: MapCellType.size);

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    if (type == MapCellType.grass) {
      priority = 900;
    }
    sprite = Sprite(
      assetImage,
      srcSize: MapCellType.size,
      srcPosition: type.srcPosition,
    );
    add(hitbox = RectangleHitbox(size: size - Vector2.all(0.5)));
  }

  /// 修改类型
  void changeType(MapCellType type) {
    this.type = type;
    sprite = Sprite(
      assetImage,
      srcSize: MapCellType.size,
      srcPosition: type.srcPosition,
    );
  }

  /// 从父节点移除
  void setWillRemoveFromParent() {
    removeFromParent();
    hitbox.collisionType = CollisionType.inactive;
  }
}
