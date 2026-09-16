import 'package:flame/flame.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tank90/app/provider/global_config.dart';
import 'package:tank90/app/provider/shared_preferences.dart';
import 'package:tank90/scene/settings_scene.dart';
import 'package:tank90/scene/splash_screen.dart';
import 'package:tank90/app/tank_war_game.dart';
import 'package:tank90/utils/audio_utils.dart';

/// 应用主类
class Applicaption extends ConsumerStatefulWidget {
  const Applicaption({super.key});

  /// 初始化方法
  static Future<void> initialized() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb &&
        ([
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform))) {
      await Flame.device.fullScreen();
      await Flame.device.setLandscape();
    }
    AudioUtils().preload(); //预加载音频数据，防止后面出现卡顿
  }

  @override
  ConsumerState<Applicaption> createState() => _MyApplicaptionState();
}

class _MyApplicaptionState extends ConsumerState<Applicaption> {
  @override
  void initState() {
    super.initState();
    initializeUserSettings(); //初始化用户配置
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (_, child) => Listener(
        onPointerDown: (_) => AudioUtils.initialize(),
        child: child!,
      ),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      locale: Locale('zh', 'CN'),
      supportedLocales: [Locale('zh', 'CN')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/main',
      onGenerateRoute: _onGeneratePageRoute,
    );
  }

  /// 初始化用户配置
  void initializeUserSettings() async {
    var prefs = ref.read(sharedPreferencesHandlerProvider);
    var globalConfig = ref.read(globalConfigProvider.notifier);
    globalConfig.gameLevel = await prefs.gameLevel;
    globalConfig.soundAvailable = await prefs.isSoundAvailable;
  }

  /// 生成页面路由
  /// + [settings] - 路由配置信息
  Route<dynamic> _onGeneratePageRoute(RouteSettings settings) {
    var routeName = settings.name ?? '/';
    if (['/', '/splash'].contains(routeName)) {
      return PageRouteBuilder(pageBuilder: (context, _, _) => SplashScreen());
    } else if (routeName == '/settings') {
      return PageRouteBuilder(
        pageBuilder: (context, _, _) => SettingsScene(
          rootContainerSize: MediaQuery.sizeOf(context),
          onRequestSceneClose: () {},
        ),
      );
    } else if (routeName == '/main') {
      return PageRouteBuilder(
        pageBuilder: (context, _, _) => RiverpodAwareGameWidget(
          key: GlobalKey<RiverpodAwareGameWidgetState>(),
          game: TankWarGame(),
        ),
      );
    }
    return PageRouteBuilder(
      pageBuilder: (context, _, _) => Material(
        child: Center(child: Text('Unknown Page Route, 404 Not Found!')),
      ),
    );
  }
}
