import 'package:tank90/scene/game_scene.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class WelcomeScene extends StatefulWidget {
  const WelcomeScene({super.key});

  @override
  State<WelcomeScene> createState() => _WelcomeSceneState();
}

class _WelcomeSceneState extends State<WelcomeScene> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement<void, void>(
        // ignore: use_build_context_synchronously
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => GameWidget(game: GameScene()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset('assets/images/menu.gif', fit: BoxFit.fitHeight),
      ),
    );
  }
}
