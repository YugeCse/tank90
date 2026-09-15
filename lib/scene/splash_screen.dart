import 'package:flame_splash_screen/flame_splash_screen.dart'
    show FlameSplashScreen, FlameSplashTheme;
import 'package:flutter/material.dart'
    show BuildContext, Colors, Scaffold, State, StatefulWidget, Widget;
import 'package:go_router/go_router.dart';

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
        onFinish: (context) => context.pushReplacement('/main'),
      ),
    );
  }
}
