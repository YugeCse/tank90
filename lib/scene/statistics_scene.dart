import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tank90/app/app_router.dart';
import 'package:tank90/app/provider/global_config.dart'
    show globalConfigProvider;
import 'package:tank90/app/provider/score_statistics.dart';
import 'package:tank90/app/tank_war_game.dart';
import 'package:tank90/component/base/tank_type.dart';
import 'package:tank90/component/view/animated_number_text_component.dart';
import 'package:tank90/data/game_constants.dart';
import 'package:tank90/data/game_properties.dart';
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

  /// 底部分割线组件
  RectangleComponent? _footerDividerComponent;

  /// 统计组件集合
  List<_StatisticsComponentGroupInfo>? _itemStatisticsComponentInfos;

  /// 总和组件集合
  _StatisticsComponentGroupInfo? _itemStatisticsFooterComponentInfo;

  @override
  FutureOr<void> onLoad() async {
    add(
      _titleTextComponent ??= TextComponent(
        anchor: Anchor.topCenter,
        text: '数据结算',
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 20.0, color: Colors.white),
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
    add(
      _footerDividerComponent ??= RectangleComponent(
        paint: Paint()
          ..isAntiAlias
          ..color = Colors.white.withValues(alpha: 0.8),
      ),
    );
    _itemStatisticsFooterComponentInfo = _buildStatistisFooterItemComponent();
    add(_itemStatisticsFooterComponentInfo!.root!);
  }

  @override
  void onMount() {
    addToGameWidgetBuild(_showDataStatistics);
    super.onMount();
    Future.delayed(Duration(seconds: 15), () {
      var canSwitchToNextStage = ref
          .read(globalConfigProvider.notifier)
          .switchToNextStageLevel();
      if (canSwitchToNextStage) {
        if (ref.read(globalConfigProvider).state == GameState.gameOver) {
          ref.read(globalConfigProvider.notifier).resetState();
          game.router.pushReplacementNamed(AppRouter.ROUTE_WELCOME);
          return;
        }
        game.router.pushReplacementNamed(AppRouter.ROUTE_MAIN);
      } else {
        ///TODO 恭喜你，你已经完全通关！！！
      }
    });
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

  /// 显示结算数据
  void _showDataStatistics() {
    var dataList = ref.read(scoreStatisticsProvider);
    var grouped = dataList.groupListsBy((e) => e.type);
    for (var type in TankType.enemyTankTypes) {
      var list = grouped[type];
      var componentInfo = _itemStatisticsComponentInfos?.elementAtOrNull(
        TankType.enemyTankTypes.indexOf(type),
      );
      componentInfo?.numText?.value = list?.length ?? 0;
      componentInfo?.scoreText?.value =
          list?.fold(0, (sum, n) => (sum ?? 0) + n.score) ?? 0;
    }
    var scoreText = _itemStatisticsFooterComponentInfo?.scoreText;
    scoreText?.value = dataList.fold(0, (sum, n) => sum + n.totalScore);
    _itemStatisticsFooterComponentInfo?.numText?.value = dataList.length;
  }

  /// 布局所有组件
  /// + [size] - 可见区域视图大小
  void _layoutAllComponents(Vector2 size) {
    double requiredWidth = GameConstants.CANVAS_SIZE.x;
    // 标题文字组件
    var layoutYOffset = 0.0;
    if (_titleTextComponent != null) {
      _titleTextComponent?.position = Vector2(requiredWidth / 2.0, 30);
      layoutYOffset = _titleTextComponent?.toRect().bottom ?? 0;
    }
    // 第一条分割线
    if (_dividerComponent != null) {
      layoutYOffset = layoutYOffset + 10;
      _dividerComponent?.size = Vector2(requiredWidth, 3.0);
      _dividerComponent?.position = Vector2(0, layoutYOffset);
      layoutYOffset = layoutYOffset + (_dividerComponent?.size.y ?? 0);
    }
    // 表格头部视图
    if (_headerItemComponent != null) {
      layoutYOffset = layoutYOffset + 10;
      _headerItemComponent?.position = Vector2(0, layoutYOffset);
      _headerItemComponent?.size = Vector2(
        requiredWidth,
        _headerItemComponent!.size.y,
      );
      layoutYOffset = layoutYOffset + (_headerItemComponent?.size.y ?? 0);
    }
    // 第二条分割线
    if (_dividerComponent2 != null) {
      layoutYOffset = layoutYOffset + 10;
      _dividerComponent2?.position = Vector2(0, layoutYOffset);
      _dividerComponent2?.size = Vector2(requiredWidth, 3.0);
      layoutYOffset = layoutYOffset + (_dividerComponent2?.size.y ?? 0);
    }
    // 统计内容区域
    if (_itemStatisticsComponentInfos != null) {
      for (var info in _itemStatisticsComponentInfos!) {
        layoutYOffset = layoutYOffset + 10.0;
        info.root?.position = Vector2(0, layoutYOffset);
        info.root?.size = Vector2(requiredWidth, info.root?.size.y ?? 0);
        layoutYOffset = layoutYOffset + (info.root?.size.y ?? 0);
      }
    }
    // 底部分割线
    if (_footerDividerComponent != null) {
      layoutYOffset = layoutYOffset + 10;
      _footerDividerComponent?.position = Vector2(0, layoutYOffset);
      _footerDividerComponent?.size = Vector2(requiredWidth, 3.0);
      layoutYOffset = layoutYOffset + (_footerDividerComponent?.size.y ?? 0);
    }
    // 小计内容区域
    if (_itemStatisticsFooterComponentInfo != null) {
      layoutYOffset = layoutYOffset += 12;
      var rootComponent = _itemStatisticsFooterComponentInfo?.root;
      rootComponent?.position = Vector2(0, layoutYOffset);
      rootComponent?.size = Vector2(
        requiredWidth,
        _footerDividerComponent?.size.y ?? 0,
      );
    }
  }

  /// 构建结算表格头部视图
  PositionComponent _buildStatisticsHeaderItemComponent() {
    double requiredWidth = GameConstants.CANVAS_SIZE.x;
    var title = '类型';
    var textPaint = TextPaint(
      style: TextStyle(fontSize: 14, color: Colors.white),
    );
    var titleTextPainter = textPaint.toTextPainter(title);
    var containerHeight = 30.0;
    var titleOffsetY = (containerHeight - titleTextPainter.height) / 2.0;
    var valueOffsetY = (containerHeight - titleTextPainter.height) / 2.0;
    PositionComponent rootContainer = PositionComponent(
      anchor: .topLeft,
      size: Vector2(requiredWidth, containerHeight),
      children: [
        TextComponent(anchor: .topLeft, text: title, textRenderer: textPaint)
          ..position = Vector2(20.0, titleOffsetY),
        PositionComponent(
          anchor: .topRight,
          children: [
            TextComponent(
              anchor: .topRight,
              text: '数量',
              textRenderer: textPaint,
              size: Vector2(30.0, titleTextPainter.height),
            ),
          ],
        )..position = Vector2(requiredWidth - 120.0, valueOffsetY),
        PositionComponent(
          anchor: .topRight,
          size: Vector2(100.0, titleTextPainter.height),
          children: [
            TextComponent(
              anchor: .topRight,
              text: '得分',
              textRenderer: textPaint,
            )..position = Vector2(100.0, 0),
          ],
        )..position = Vector2(requiredWidth - 20.0, valueOffsetY),
      ],
    )..position = Vector2.zero();
    return rootContainer;
  }

  /// 构建结算Item视图信息组件
  /// + [tankType] - 类型
  _StatisticsComponentGroupInfo _buildStatistisRowItemComponent({
    required TankType tankType,
  }) {
    double requiredWidth = GameConstants.CANVAS_SIZE.x;
    AnimatedNumberTextComponent numText;
    AnimatedNumberTextComponent scoreText;
    TextPaint textPaint = TextPaint(
      style: TextStyle(fontSize: 14, color: Colors.white),
    );
    double textDrawHeight = textPaint.toTextPainter('测试文字').height;
    double containerHeight = 36.0;
    double titleOffsetY = (containerHeight - tankType.srcSize.y) / 2.0;
    double valueOffsetY = (containerHeight - textDrawHeight) / 2.0;
    PositionComponent root = PositionComponent(
      anchor: .topLeft,
      size: Vector2(requiredWidth, containerHeight),
      children: [
        SpriteComponent(
          anchor: .topLeft,
          sprite: Sprite(
            assetImage,
            srcSize: tankType.srcSize,
            srcPosition: tankType.srcPosition,
          ),
          position: Vector2(20.0, titleOffsetY),
        ),
        numText = AnimatedNumberTextComponent(
          anchor: .topRight,
          initialValue: 0,
          textRenderer: textPaint,
          size: Vector2(30.0, textDrawHeight),
        )..position = Vector2(requiredWidth - 120.0, valueOffsetY),
        scoreText = AnimatedNumberTextComponent(
          anchor: .topRight,
          initialValue: 0,
          textRenderer: textPaint,
          size: Vector2(100.0, textDrawHeight),
        )..position = Vector2(requiredWidth - 20.0, valueOffsetY),
      ],
    )..position = Vector2.zero();
    return _StatisticsComponentGroupInfo(
      root: root,
      numText: numText,
      scoreText: scoreText,
    );
  }

  /// 构建总和结算Item视图信息组件
  _StatisticsComponentGroupInfo _buildStatistisFooterItemComponent() {
    double requiredWidth = GameConstants.CANVAS_SIZE.x;
    AnimatedNumberTextComponent numText;
    AnimatedNumberTextComponent scoreText;
    TextPaint textPaint = TextPaint(
      style: TextStyle(fontSize: 14, color: Colors.white),
    );
    TextPaint titleTextPaint = textPaint.copyWith(
      (s) => s.copyWith(fontWeight: FontWeight.bold),
    );
    double textDrawHeight = textPaint.toTextPainter('测试文字').height;
    double titleDrawHeight = titleTextPaint.toTextPainter("合计").height;
    double containerHeight = 30.0;
    double titleOffsetY = (containerHeight - titleDrawHeight) / 2.0;
    double valueOffsetY = (containerHeight - textDrawHeight) / 2.0;
    PositionComponent root = PositionComponent(
      anchor: .topLeft,
      size: Vector2(requiredWidth, containerHeight),
      children: [
        TextComponent(text: '合计', textRenderer: titleTextPaint)
          ..position = Vector2(20.0, titleOffsetY),
        numText = AnimatedNumberTextComponent(
          anchor: .topRight,
          initialValue: 0,
          textRenderer: textPaint,
          size: Vector2(30.0, textDrawHeight),
        )..position = Vector2(requiredWidth - 120.0, valueOffsetY),
        scoreText = AnimatedNumberTextComponent(
          anchor: .topRight,
          initialValue: 0,
          textRenderer: textPaint,
          size: Vector2(100.0, textDrawHeight),
        )..position = Vector2(requiredWidth - 20.0, valueOffsetY),
      ],
    )..position = Vector2.zero();
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
    this.numText,
    required this.scoreText,
  });

  /// Item根视图容器组件
  final PositionComponent? root;

  /// 计数组件
  final AnimatedNumberTextComponent? numText;

  /// 记分组件
  final AnimatedNumberTextComponent? scoreText;
}
