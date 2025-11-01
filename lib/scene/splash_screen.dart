import 'package:tank90/scene/welcome_scene.dart';
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
class SplashScreenGame extends StatefulWidget {
  const SplashScreenGame({super.key});

  @override
  SplashScreenGameState createState() => SplashScreenGameState();
}

class SplashScreenGameState extends State<SplashScreenGame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FlameSplashScreen(
        showAfter: (BuildContext context) {
          return const Text('90坦克大战');
        },
        theme: FlameSplashTheme.dark,
        onFinish: (context) => Navigator.pushReplacement<void, void>(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) => WelcomeScene(),
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
