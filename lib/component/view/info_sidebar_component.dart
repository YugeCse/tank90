import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tank90/app/provider/global_config.dart';
import 'package:tank90/component/view/number_sprite_component.dart';
import 'package:tank90/data/game_constants.dart';
import 'package:tank90/utils/res_img_utils.dart';

/// 信息侧边栏组件
class InfoSidebarComponent extends PositionComponent
    with RiverpodComponentMixin {
  /// 信息面板宽度
  final double _infoBoardWidth = 64.0;

  /// 敌人的精灵装载容器
  late final PositionComponent _enemiesContainer;

  /// 关卡数显示组件
  late final NumberSpriteComponent _stageNumComponent;

  /// 玩家生命数显示组件
  late final NumberSpriteComponent _playerLifesComponent;

  @override
  FutureOr<void> onLoad() async {
    size = Vector2(_infoBoardWidth, GameConstants.CANVAS_SIZE.y);
    add(
      _enemiesContainer = PositionComponent(
        children: Iterable.generate(
          GameConstants.ENEMEY_MAX_COUNT,
          (index) => _buildTankSpriteComponent(index),
        ),
      )..size = Vector2(_infoBoardWidth, GameConstants.CANVAS_SIZE.y),
    );
    add(
      PositionComponent(
        anchor: .center,
        children: [
          SpriteComponent(
            sprite: Sprite(
              assetImage,
              srcSize: Vector2(30, 31),
              srcPosition: Vector2(61, 112),
            ),
            size: Vector2(30, 31),
          ),
          _stageNumComponent = NumberSpriteComponent(number: 1)
            ..position = Vector2(10.0, 18.0),
        ],
      )..position = Vector2(12.0, GameConstants.CANVAS_SIZE.y - 96.0),
    );
    add(
      PositionComponent(
        anchor: .center,
        children: [
          SpriteComponent(
            sprite: Sprite(
              assetImage,
              srcSize: Vector2(30, 32),
              srcPosition: Vector2(0, 112),
            ),
          ),
          _playerLifesComponent = NumberSpriteComponent(number: 0)
            ..position = Vector2(18.0, 17),
        ],
      )..position = Vector2(12.0, GameConstants.CANVAS_SIZE.y - 32.0),
    );
  }

  @override
  void onMount() {
    addToGameWidgetBuild(_listenDataChanged);
    super.onMount();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _infoBoardWidth, GameConstants.CANVAS_SIZE.y),
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..color = GameConstants.CANVAS_BG_COLOR,
    );
    super.render(canvas);
  }

  /// 监听数据变化
  void _listenDataChanged() {
    var globalConfigInfo = ref.read(globalConfigProvider);
    _setStageLevel(globalConfigInfo.stageLevel);
    _setPlayerLifes(globalConfigInfo.playerLifes);
    ref.listen(globalConfigProvider, (_, next) {
      _setStageLevel(next.stageLevel);
      _setPlayerLifes(next.playerLifes);
    });
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

  /// 设置关卡等级显示
  void _setStageLevel(int level) {
    _stageNumComponent.number = level;
  }

  /// 设置玩家生命数
  void _setPlayerLifes(int count) {
    _playerLifesComponent.number = count;
  }
}
