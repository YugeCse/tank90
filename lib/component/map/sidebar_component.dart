import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tank90/data/map_constants.dart';
import 'package:tank90/scene/tank_war_game.dart';

/// 侧边栏组件
class SidebarComponent extends PositionComponent
    with HasGameReference<TankWarGame> {
  @override
  FutureOr<void> onLoad() async {
    size = Vector2(64, MapConstants.mapSize.y);
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..isAntiAlias = true
          ..color = Colors.grey
          ..style = PaintingStyle.fill,
      ),
    );
    add(
      PositionComponent(
        children: Iterable.generate(
          20,
          (index) => _buildTankSpriteComponent(index),
        ),
      )..size = Vector2(64.0, 320.0),
    );
  }

  /// 构建 Tank 精灵组件
  /// + [index] - 组件索引
  SpriteComponent _buildTankSpriteComponent(int index) {
    var col = index % 2 == 0 ? 0 : 1;
    var row = index / 2 + ((index % 2 == 0) ? 1 : 0);
    return SpriteComponent(
      sprite: Sprite(
        game.assetImage,
        srcSize: Vector2.all(14.0),
        srcPosition: Vector2(92, 112),
      ),
    )..position = Vector2(20.0 * col, 20.0 * row);
  }
}
