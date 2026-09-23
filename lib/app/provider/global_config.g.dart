// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 全局配置类

@ProviderFor(GlobalConfig)
final globalConfigProvider = GlobalConfigProvider._();

/// 全局配置类
final class GlobalConfigProvider
    extends $NotifierProvider<GlobalConfig, GlobalConfigInfo> {
  /// 全局配置类
  GlobalConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalConfigHash();

  @$internal
  @override
  GlobalConfig create() => GlobalConfig();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GlobalConfigInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GlobalConfigInfo>(value),
    );
  }
}

String _$globalConfigHash() => r'57e6eaca8b7381d324542df2c0992901ff1839ba';

/// 全局配置类

abstract class _$GlobalConfig extends $Notifier<GlobalConfigInfo> {
  GlobalConfigInfo build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GlobalConfigInfo, GlobalConfigInfo>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GlobalConfigInfo, GlobalConfigInfo>,
              GlobalConfigInfo,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
