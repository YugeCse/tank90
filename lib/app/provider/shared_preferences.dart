import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:tank90/data/game_properties.dart';

part 'shared_preferences.g.dart';

/// 创建sharedPreferencesProvider
@Riverpod(keepAlive: true)
SharedPreferencesAsync sharedPreferences(Ref ref) {
  throw UnimplementedError(
    "sharedPreferencesProvider 必须在 ProviderScope 中 override",
  );
}

/// 创建sharedPreferencesHandler
@Riverpod(keepAlive: true)
SharedPreferencesHandler sharedPreferencesHandler(Ref ref) {
  throw UnimplementedError(
    "sharedPreferencesHandlerProvider 必须在 ProviderScope 中 override",
  );
}

/// 获取默认的SharePreferencesAsync
SharedPreferencesAsync getDefaultSharedPreferencesAsync() {
  return SharedPreferencesAsync(
    options: defaultTargetPlatform == TargetPlatform.android
        ? SharedPreferencesAsyncAndroidOptions(
            backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
            originalSharedPreferencesOptions:
                AndroidSharedPreferencesStoreOptions(fileName: 'app_config'),
          )
        : SharedPreferencesOptions(),
  );
}

/// SharedPreferencesHandler的操作类
class SharedPreferencesHandler {
  /// Prefs对象
  final SharedPreferencesAsync prefs;

  /// 构造方法
  SharedPreferencesHandler(this.prefs);

  /// 获取是否打开了音乐
  Future<bool> get isSoundAvailable async =>
      (await prefs.getBool('is_sound_availabel')) ?? false;

  /// 设置是否打开音乐
  set isSoundAvailable(bool value) =>
      prefs.setBool('is_sound_availabel', value);

  /// 获取用户存储的难易程度
  Future<GameLevel> get gameLevel async {
    var value = (await prefs.getString('game_level') ?? GameLevel.easy.name);
    return value.trim().isEmpty
        ? GameLevel.easy
        : GameLevel.values.firstWhere(
            (el) => el.name == value,
            orElse: () => GameLevel.easy,
          );
  }

  /// 设置难易程度
  /// + [level] - 难易程度
  set gameLevel(GameLevel level) => prefs.setString("game_level", level.name);
}
