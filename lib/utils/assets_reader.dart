// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

/// 资源读取工具类
class AssetsReader {
  AssetsReader._();

  /// 地图资源文件的文件目录
  static const String ASSET_MAP_STAGE_DIR = "assets/stages";

  /// 列出所有资源信息
  static Future<List<String>> listAllAssets() async =>
      (await AssetManifest.loadFromAssetBundle(rootBundle)).listAssets();

  /// 列出地图数据文件的名称
  static Future<List<String>> listMapStageAssetNames() async {
    var data = (await listAllAssets());
    return data
        .where((el) => el.startsWith("$ASSET_MAP_STAGE_DIR/"))
        .map((el) => el.replaceFirst("$ASSET_MAP_STAGE_DIR/", ""))
        .toList()
        .sortedByCompare(
          (name) => int.parse(name.replaceAll(RegExp(r'(map|.json)'), "")),
          (a, b) => a - b,
        );
  }
}
