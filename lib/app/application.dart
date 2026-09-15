import 'package:flame/flame.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tank90/app/provider/global_config.dart';
import 'package:tank90/app/provider/shared_preferences.dart';
import 'package:tank90/scene/settings_scene.dart';
import 'package:tank90/scene/splash_screen.dart';
import 'package:tank90/scene/tank_war_game.dart';
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
  final _router = GoRouter(
    initialLocation: '/settings',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/main',
        builder: (context, state) => RiverpodAwareGameWidget(
          key: GlobalKey<RiverpodAwareGameWidgetState>(),
          game: TankWarGame(),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsScene(
          rootContainerSize: MediaQuery.sizeOf(context),
          onRequestSceneClose: () => context.pushReplacement('/test'),
        ),
      ),
      GoRoute(
        path: '/test',
        builder: (context, state) => Material(
          child: Center(
            child: InkWell(
              onTap: () => context.pushReplacement('/settings'),
              child: Text('Unknown Page Route'),
            ),
          ),
        ),
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    initializeUserSettings(); //初始化用户配置
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
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
    );
  }

  /// 初始化用户配置
  void initializeUserSettings() async {
    var prefs = ref.read(sharedPreferencesHandlerProvider);
    var globalConfig = ref.read(globalConfigProvider.notifier);
    globalConfig.gameLevel = await prefs.gameLevel;
    globalConfig.soundAvailable = await prefs.isSoundAvailable;
  }
}
