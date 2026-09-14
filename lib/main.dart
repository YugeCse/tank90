import 'dart:async';
import 'dart:io';

import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:tank90/scene/splash_screen.dart' show SplashScreen;
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tank90/scene/tank_war_game.dart';
import 'package:tank90/utils/audio_utils.dart';

void main() async {
  await MyApplicaption.initialized();
  runApp(MyApplicaption());
}

class MyApplicaption extends StatelessWidget {
  MyApplicaption({super.key});

  /// 初始化方法
  static Future<void> initialized() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await Flame.device.fullScreen();
      await Flame.device.setLandscape();
    }
    AudioUtils().preload(); //预加载音频数据，防止后面出现卡顿
  }

  /// 必须有一个稳定的Key对象
  final _gameWidgetKey = GlobalKey<RiverpodAwareGameWidgetState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'Splash',
      onGenerateRoute: (settings) {
        if (settings.name == 'Splash') {
          return PageRouteBuilder(
            pageBuilder: (_, _, _) => const SplashScreen(),
          );
        }
        return PageRouteBuilder(
          pageBuilder: (_, _, _) =>
              RiverpodAwareGameWidget(key: _gameWidgetKey, game: TankWarGame()),
        );
      },
      builder: (_, child) => Listener(
        onPointerDown: (_) => AudioUtils().setAllowPlay(false),
        child: child!,
      ),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}
