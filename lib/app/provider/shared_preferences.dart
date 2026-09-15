import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tank90/data/game_properties.dart';

part 'shared_preferences.g.dart';

@Riverpod(keepAlive: true)
SharedPreferencesAsync sharedPreferences(Ref ref) {
  throw UnimplementedError(
    "sharedPreferencesProvider 必须在 ProviderScope 中 override",
  );
}

@Riverpod(keepAlive: true)
SharedPreferencesHandler sharedPreferencesHandler(Ref ref) {
  throw UnimplementedError(
    "sharedPreferencesHandlerProvider 必须在 ProviderScope 中 override",
  );
}

class SharedPreferencesHandler {
  final SharedPreferencesAsync prefs;

  SharedPreferencesHandler(this.prefs);

  Future<bool> get isSoundAvailable async =>
      (await prefs.getBool('is_sound_availabel')) ?? false;

  set isSoundAvailable(bool value) =>
      prefs.setBool('is_sound_availabel', value);

  Future<GameLevel> get gameLevel async {
    var value = (await prefs.getString('game_level') ?? GameLevel.easy.name);
    return value.trim().isEmpty
        ? GameLevel.easy
        : GameLevel.values.firstWhere(
            (el) => el.name == value,
            orElse: () => GameLevel.easy,
          );
  }

  set gameLevel(GameLevel level) => prefs.setString("game_level", level.name);
}
