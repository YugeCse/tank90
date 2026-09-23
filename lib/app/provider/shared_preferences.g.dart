// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_preferences.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 创建sharedPreferencesProvider

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// 创建sharedPreferencesProvider

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferencesAsync,
          SharedPreferencesAsync,
          SharedPreferencesAsync
        >
    with $Provider<SharedPreferencesAsync> {
  /// 创建sharedPreferencesProvider
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferencesAsync> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferencesAsync create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferencesAsync value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferencesAsync>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'11857f0a89fb15edd205479893a6c32649f31643';

/// 创建sharedPreferencesHandler

@ProviderFor(sharedPreferencesHandler)
final sharedPreferencesHandlerProvider = SharedPreferencesHandlerProvider._();

/// 创建sharedPreferencesHandler

final class SharedPreferencesHandlerProvider
    extends
        $FunctionalProvider<
          SharedPreferencesHandler,
          SharedPreferencesHandler,
          SharedPreferencesHandler
        >
    with $Provider<SharedPreferencesHandler> {
  /// 创建sharedPreferencesHandler
  SharedPreferencesHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHandlerHash();

  @$internal
  @override
  $ProviderElement<SharedPreferencesHandler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferencesHandler create(Ref ref) {
    return sharedPreferencesHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferencesHandler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferencesHandler>(value),
    );
  }
}

String _$sharedPreferencesHandlerHash() =>
    r'a20c551201e3c9bd7d9101d3a04222feda6f783c';
