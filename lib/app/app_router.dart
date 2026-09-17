// ignore_for_file: constant_identifier_names

import 'dart:ui' show Size;

import 'package:flame/game.dart';
import 'package:tank90/scene/main_scene.dart';
import 'package:tank90/scene/settings_scene.dart';
import 'package:tank90/scene/stage_screen.dart';
import 'package:tank90/scene/statistics_scene.dart';
import 'package:tank90/scene/welcome_scene.dart';

/// 路由管理类
class AppRouter {
  AppRouter._();

  /// 初始界面
  static const INIT_ROUTE = ROUTE_WELCOME;

  /// 启动欢迎页
  static const ROUTE_WELCOME = 'Welcome';

  /// 设置页面
  static const ROUTE_SETTINGS = 'Settings';

  /// 关卡设置页面
  static const ROUTE_STAGE = 'Stage';

  /// 主界面
  static const ROUTE_MAIN = 'Main';

  /// 结算界面
  static const ROUTE_STATISTICS = 'Statistics';

  /// 构建路由配置方法
  /// + [requestRouterPop] - 请求关闭页面
  static Map<String, Route> buildRouteConfigs({
    required void Function() requestRouterPop,
  }) => {
    ROUTE_WELCOME: Route(WelcomeScene.new),
    ROUTE_SETTINGS: OverlayRoute(
      (_, game) => SettingsScene(
        onRequestSceneClose: requestRouterPop,
        rootContainerSize: Size(game.size.x, game.size.y),
      ),
    ),
    ROUTE_STAGE: Route(StageScreen.new),
    ROUTE_MAIN: Route(MainScene.new),
    ROUTE_STATISTICS: Route(StatisticsScene.new),
  };
}
