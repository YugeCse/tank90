import 'dart:async';
import 'dart:io';

import 'package:tank90/scene/splash_screen.dart' show SplashScreen;
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tank90/utils/audio_utils.dart';

void main() async {
  await MyApplicaption.initialized();
  runApp(MyApplicaption());
}

class MyApplicaption extends StatelessWidget {
  const MyApplicaption({super.key});

  /// 初始化方法
  static Future<void> initialized() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await Flame.device.fullScreen();
      await Flame.device.setLandscape();
    }
    AudioUtils().preload(); //预加载音频数据，防止后面出现播放卡顿
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
      builder: (_, child) => Listener(
        onPointerDown: (_) => AudioUtils().setAllowPlay(false),
        child: child!,
      ),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}
