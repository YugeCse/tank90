import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:tank90/app/application.dart';
import 'package:tank90/app/provider/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:tank90/data/map_stage_level.dart';

/// 入口函数
void main() async {
  await Applicaption.initialized();
  await MapStageLevel().initialize();
  var prefs = getDefaultSharedPreferencesAsync();
  List<Override> overrides = [
    sharedPreferencesProvider.overrideWithValue(prefs),
    sharedPreferencesHandlerProvider.overrideWithValue(
      SharedPreferencesHandler(prefs),
    ),
  ];
  runApp(ProviderScope(overrides: overrides, child: Applicaption()));
}
