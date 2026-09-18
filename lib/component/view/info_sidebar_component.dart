import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tank90/data/game_constants.dart';
import 'package:tank90/utils/res_img_utils.dart';

/// 信息侧边栏组件
class InfoSidebarComponent extends PositionComponent {
  /// 敌人的精灵装载容器
  late final PositionComponent _enemiesContainer;

  late final SpriteComponent _stageFlagComponent;

  late final List<SpriteComponent> _stageNumComponents;

  late final SpriteComponent _playerTagComponent;

  late final List<SpriteComponent> _playerLifesComponents;

  @override
  FutureOr<void> onLoad() async {
    size = Vector2(64, GameConstants.CANVAS_SIZE.y);
    add(
      _enemiesContainer = PositionComponent(
        children: Iterable.generate(
          GameConstants.ENEMEY_MAX_COUNT,
          (index) => _buildTankSpriteComponent(index),
        ),
      )..size = Vector2(64.0, 320.0),
    );
  }

  @override
  void render(Canvas canvas) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Colors.grey;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 64, GameConstants.CANVAS_SIZE.y),
      paint,
    );
    super.render(canvas);
  }

  /// 构建 Tank 精灵组件
  /// + [index] - 组件索引
  SpriteComponent _buildTankSpriteComponent(int index) {
    var col = index % 2 == 0 ? 0 : 1;
    var row = (index / 2).toInt();
    var position = Vector2(
      12.0 * (col + 1) + 14.0 * col,
      12.0 * (row + 1) + 14.0 * row,
    );
    return SpriteComponent(
      anchor: .topLeft,
      sprite: Sprite(
        assetImage,
        srcSize: Vector2.all(14.0),
        srcPosition: Vector2(92, 112),
      ),
    )..position = position;
  }

  /// 清空敌方精灵
  void clearEnemySprites() {
    var enemySprites = _enemiesContainer.children.whereType<SpriteComponent>();
    for (var sprite in enemySprites) {
      sprite.removeFromParent();
    }
  }

  /// 添加敌方精灵
  void addEnemySprite() {
    var index = _enemiesContainer.children.length;
    var sprite = _buildTankSpriteComponent(index);
    _enemiesContainer.add(sprite);
  }

  /// 删除一个敌方精灵
  void removeOneEnemySprite() {
    var sprites = _enemiesContainer.children.whereType<SpriteComponent>();
    if (sprites.isEmpty) return;
    _enemiesContainer.remove(sprites.last);
  }
}
