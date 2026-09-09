import 'dart:io';

import 'package:flutter/services.dart' show SystemSound, SystemSoundType;
import 'package:tank90/scene/splash_screen.dart' show SplashScreenGame;
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tank90/utils/audio_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
      await Flame.device.fullScreen();
      await Flame.device.setLandscape();
    }
  }
  await AudioUtils.preloadAll();
  runApp(MyApplicaption());
}

class MyApplicaption extends StatelessWidget {
  const MyApplicaption({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreenGame(),
      builder: (context, child) {
        // 拦截所有按钮声音
        return Listener(
          onPointerDown: (event) {
            SystemSound.play(SystemSoundType.click);
          },
          child: child!,
        );
      },
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}
