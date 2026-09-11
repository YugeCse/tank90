import 'package:flutter/material.dart';
import 'package:tank90/scene/tank_war_game.dart';

class SettingsScene extends StatefulWidget {
  final TankWarGame game;

  const SettingsScene({super.key, required this.game});

  @override
  State<SettingsScene> createState() => _SettingsSceneState();
}

class _SettingsSceneState extends State<SettingsScene> {
  @override
  void initState() {
    super.initState();
    debugPrint('Enter SettingsScene');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: 500,
        height: 300,
        decoration: BoxDecoration(color: Colors.black),
        child: Center(
          child: Text(
            'CenterSettings',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
