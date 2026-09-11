import 'package:flame/game.dart';
import 'package:tank90/scene/tank_war_game.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart'
    show FlameSplashScreen, FlameSplashTheme;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        BuildContext,
        Colors,
        Navigator,
        Scaffold,
        State,
        StatefulWidget,
        Text,
        Widget;

/// 启动界面
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FlameSplashScreen(
        theme: FlameSplashTheme.dark,
        onFinish: (context) => Navigator.pushReplacement<void, void>(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) =>
                GameWidget.controlled(gameFactory: TankWarGame.new),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(seconds: 1),
          ),
        ),
      ),
    );
  }
}
