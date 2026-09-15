// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_statistics.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 数据结算类

@ProviderFor(ScoreStatistics)
final scoreStatisticsProvider = ScoreStatisticsProvider._();

/// 数据结算类
final class ScoreStatisticsProvider
    extends $NotifierProvider<ScoreStatistics, List<ScoreStatisticsInfo>> {
  /// 数据结算类
  ScoreStatisticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scoreStatisticsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scoreStatisticsHash();

  @$internal
  @override
  ScoreStatistics create() => ScoreStatistics();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ScoreStatisticsInfo> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ScoreStatisticsInfo>>(value),
    );
  }
}

String _$scoreStatisticsHash() => r'650ea784e319a1de0bb70a5dbadd5f186e127db1';

/// 数据结算类

abstract class _$ScoreStatistics extends $Notifier<List<ScoreStatisticsInfo>> {
  List<ScoreStatisticsInfo> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<ScoreStatisticsInfo>, List<ScoreStatisticsInfo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ScoreStatisticsInfo>, List<ScoreStatisticsInfo>>,
              List<ScoreStatisticsInfo>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
