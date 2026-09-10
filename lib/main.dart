import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show SystemSound, SystemSoundType;
import 'package:tank90/scene/splash_screen.dart' show SplashScreenGame;
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tank90/utils/audio_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();
  }
  runApp(MyApplicaption());
  // 音频缓存不应阻塞 Web 首屏；浏览器资源加载失败也不影响游戏启动。
  unawaited(AudioUtils.preloadAll());
}

class MyApplicaption extends StatelessWidget {
  const MyApplicaption({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreenGame(),
      builder: (_, child) => Listener(
        onPointerDown: (_) {
          AudioUtils().allowPlay = true;
          SystemSound.play(SystemSoundType.click);
        },
        child: child!,
      ),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}
