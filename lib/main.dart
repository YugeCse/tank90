import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tank90/app/application.dart';
import 'package:tank90/app/provider/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

void main() async {
  await Applicaption.initialized();
  var prefs = SharedPreferencesAsync(
    options: defaultTargetPlatform == TargetPlatform.android
        ? SharedPreferencesAsyncAndroidOptions(
            backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
            originalSharedPreferencesOptions:
                AndroidSharedPreferencesStoreOptions(fileName: 'app_config'),
          )
        : SharedPreferencesOptions(),
  );
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sharedPreferencesHandlerProvider.overrideWithValue(
          SharedPreferencesHandler(prefs),
        ),
      ],
      child: Applicaption(),
    ),
  );
}
