import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show SystemSound, SystemSoundType;
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

  static Future<void> initialized() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await Flame.device.fullScreen();
      await Flame.device.setLandscape();
    }
    await AudioUtils.preloadAll();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
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
