import 'dart:io';

import 'package:tank90/scene/splash_screen.dart' show SplashScreenGame;
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  if (!kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
      WidgetsFlutterBinding.ensureInitialized();
      Flame.device.fullScreen();
      Flame.device.setLandscape();
    }
  }
  runApp(MyApplicaption());
}

class MyApplicaption extends StatelessWidget {
  const MyApplicaption({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreenGame(),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}
