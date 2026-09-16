import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tank90/app/tank_war_game.dart';
import 'package:tank90/component/base/tank_type.dart';
import 'package:tank90/component/view/animated_number_text_component.dart';
import 'package:tank90/utils/num_utils.dart';
import 'package:tank90/utils/res_img_utils.dart';

/// 结算场景页面
class StatisticsScene extends PositionComponent
    with HasGameReference<TankWarGame>, RiverpodComponentMixin {
  /// 标题组件
  TextComponent? _titleTextComponent;

  /// 分割线组件
  RectangleComponent? _dividerComponent;

  /// 头部视图组件
  PositionComponent? _headerItemComponent;

  /// 第二个分割线组件
  RectangleComponent? _dividerComponent2;

  /// 统计组件集合
  List<_StatisticsComponentGroupInfo>? _itemStatisticsComponentInfos;

  @override
  FutureOr<void> onLoad() async {
    add(
      _titleTextComponent ??= TextComponent(
        anchor: Anchor.topCenter,
        text: 'Stage Data Statistics',
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 32.0, color: Colors.white),
        ),
      ),
    );
    add(
      _dividerComponent ??= RectangleComponent(
        paint: Paint()
          ..isAntiAlias
          ..color = Colors.white.withValues(alpha: 0.8),
      ),
    );
    add(_headerItemComponent ??= _buildStatisticsHeaderItemComponent());
    add(
      _dividerComponent2 ??= RectangleComponent(
        paint: Paint()
          ..isAntiAlias
          ..color = Colors.white.withValues(alpha: 0.8),
      ),
    );
    _itemStatisticsComponentInfos ??= [];
    for (var type in TankType.enemyTankTypes) {
      var groupInfo = _buildStatistisRowItemComponent(tankType: type);
      _itemStatisticsComponentInfos?.add(groupInfo);
      add(groupInfo.root!); //添加布局到界面中
    }
  }

  @override
  void onMount() {
    super.onMount();
    Future.delayed(
      Duration(seconds: 5),
      () => _itemStatisticsComponentInfos?.firstOrNull?.scoreText?.value = 1000,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layoutAllComponents(size);
  }

  @override
  void render(Canvas canvas) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(255, 29, 29, 29);
    canvas.drawRect(Rect.fromLTWH(0, 0, game.size.x, game.size.y), paint);
    super.render(canvas);
  }

  /// 布局所有组件
  /// + [size] - 可见区域视图大小
  void _layoutAllComponents(Vector2 size) {
    double requiredWidth = (size.x * 0.8).clamp(400.0, 800.0);
    double offsetX = ((size.x - requiredWidth) / 2.0).atLeast(0.0);
    var layoutYOffset = 0.0;
    if (_titleTextComponent != null) {
      _titleTextComponent?.position = Vector2(
        offsetX + requiredWidth / 2.0,
        30,
      );
      layoutYOffset = _titleTextComponent?.toRect().bottom ?? 0;
    }

    if (_dividerComponent != null) {
      layoutYOffset = layoutYOffset + 20;
      _dividerComponent?.size = Vector2(requiredWidth, 3.0);
      _dividerComponent?.position = Vector2(offsetX, layoutYOffset);
      layoutYOffset = layoutYOffset + (_dividerComponent?.size.y ?? 0);
    }

    if (_headerItemComponent != null) {
      layoutYOffset = layoutYOffset + 20;
      _headerItemComponent?.position = Vector2(offsetX, layoutYOffset);
      _headerItemComponent?.size = Vector2(
        requiredWidth,
        _headerItemComponent!.size.y,
      );
      layoutYOffset = layoutYOffset + (_headerItemComponent?.size.y ?? 0);
    }

    if (_dividerComponent2 != null) {
      layoutYOffset = layoutYOffset + 20;
      _dividerComponent2?.position = Vector2(offsetX, layoutYOffset);
      _dividerComponent2?.size = Vector2(requiredWidth, 3.0);
      layoutYOffset = layoutYOffset + (_dividerComponent2?.size.y ?? 0);
    }

    if (_itemStatisticsComponentInfos != null) {
      for (var info in _itemStatisticsComponentInfos!) {
        layoutYOffset = layoutYOffset + 20.0;
        info.root?.position = Vector2(offsetX, layoutYOffset);
        info.root?.size = Vector2(requiredWidth, info.root?.size.y ?? 0);
        layoutYOffset = layoutYOffset + (info.root?.size.y ?? 0);
      }
    }
  }

  /// 构建结算表格头部视图
  PositionComponent _buildStatisticsHeaderItemComponent() {
    double requiredWidth = (game.size.x * 0.8).clamp(400.0, 800.0);
    double offsetX = ((game.size.x - requiredWidth) / 2.0).atLeast(0.0);
    var title = '类型';
    var textPaint = TextPaint(
      style: TextStyle(fontSize: 28, color: Colors.white),
    );
    var titleTextPainter = textPaint.toTextPainter(title);
    var containerHeight = 50.0;
    var titleOffsetY = (containerHeight - titleTextPainter.height) / 2.0;
    var valueOffsetY = (containerHeight - titleTextPainter.height) / 2.0;
    PositionComponent rootContainer = PositionComponent(
      anchor: .topLeft,
      size: Vector2(requiredWidth, containerHeight),
      children: [
        TextComponent(anchor: .topLeft, text: title, textRenderer: textPaint)
          ..position = Vector2(20.0, titleOffsetY),
        TextComponent(
          anchor: .topRight,
          text: '数量',
          textRenderer: textPaint,
          size: Vector2(80.0, titleTextPainter.height),
        )..position = Vector2(requiredWidth - 220.0, valueOffsetY),
        TextComponent(
          anchor: .topRight,
          text: '得分',
          textRenderer: textPaint,
          size: Vector2(200.0, titleTextPainter.height),
        )..position = Vector2(requiredWidth - 20.0, valueOffsetY),
      ],
    )..position = Vector2(offsetX, 0);
    return rootContainer;
  }

  /// 添加结算Item视图信息组件
  /// + [tankType] - 类型
  _StatisticsComponentGroupInfo _buildStatistisRowItemComponent({
    required TankType tankType,
  }) {
    double requiredWidth = (game.size.x * 0.8).clamp(400.0, 800.0);
    double offsetX = ((game.size.x - requiredWidth) / 2.0).atLeast(0.0);
    AnimatedNumberTextComponent numText;
    AnimatedNumberTextComponent scoreText;
    TextPaint textPaint = TextPaint(
      style: TextStyle(fontSize: 28, color: Colors.white),
    );
    double textDrawHeight = textPaint.toTextPainter('测试文字').height;
    double containerHeight = 50.0;
    double titleOffsetY = (containerHeight - tankType.srcSize.y) / 2.0;
    double valueOffsetY = (containerHeight - textDrawHeight) / 2.0;
    PositionComponent root = PositionComponent(
      anchor: .topLeft,
      size: Vector2(requiredWidth, containerHeight),
      children: [
        SpriteComponent(
          anchor: .topLeft,
          sprite: Sprite(
            game.assetImage,
            srcSize: tankType.srcSize,
            srcPosition: tankType.srcPosition,
          ),
          position: Vector2(20.0, titleOffsetY),
        ),
        numText = AnimatedNumberTextComponent(
          anchor: .topRight,
          initialValue: 0,
          textRenderer: textPaint,
          size: Vector2(80.0, textDrawHeight),
        )..position = Vector2(requiredWidth - 220.0, valueOffsetY),
        scoreText = AnimatedNumberTextComponent(
          anchor: .topRight,
          initialValue: 0,
          textRenderer: textPaint,
          size: Vector2(200.0, textDrawHeight),
        )..position = Vector2(requiredWidth - 20.0, valueOffsetY),
      ],
    )..position = Vector2(offsetX, 0);
    return _StatisticsComponentGroupInfo(
      root: root,
      numText: numText,
      scoreText: scoreText,
    );
  }
}

/// 结算组件组信息
class _StatisticsComponentGroupInfo {
  _StatisticsComponentGroupInfo({
    required this.root,
    required this.numText,
    required this.scoreText,
  });

  /// Item根视图容器组件
  final PositionComponent? root;

  /// 计数组件
  final AnimatedNumberTextComponent? numText;

  /// 记分组件
  final AnimatedNumberTextComponent? scoreText;
}
