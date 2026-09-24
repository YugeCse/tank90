import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tank90/utils/assets_reader.dart';

/// 地图关卡数组
///
/// 1：水泥墙 2：铁墙 3：草 4：水 5：冰 9：家
///
class MapStageLevel {
  static MapStageLevel? _instance;

  MapStageLevel._internal();

  /// 单例
  factory MapStageLevel() => _instance ??= MapStageLevel._internal();

  /// 地图数据集合
  final Map<int, List<List<int>>> _maps = {};

  /// 获取关卡数量
  int get stageCount => _maps.length;

  /// 初始化操作
  Future<void> initialize() async {
    var mapNames = await AssetsReader.listMapStageAssetNames();
    for (var i = 0; i < mapNames.length; i++) {
      var name = mapNames[i];
      var stage = int.parse(name.replaceAll(RegExp(r'(map|.json)'), ""));
      var mapData = await loadMap(stage);
      if (mapData == null) continue;
      _maps[stage] = mapData; //赋值数据
    }
  }

  /// 加载地图数据，并放置到地图集合中
  Future<List<List<int>>?> loadMap(int stageLevel) async {
    if (stageLevel <= 0) return null;
    if (_maps.containsKey(stageLevel)) return _maps[stageLevel];
    return await _readMapFromJson("map$stageLevel");
  }

  /// 从资源中读取地图数据
  /// + [mapName] - 地图数据文件名称
  Future<List<List<int>>> _readMapFromJson(String mapName) async {
    var mapFile = "${AssetsReader.ASSET_MAP_STAGE_DIR}/$mapName.json";
    var data = await rootBundle.loadString(mapFile);
    var dataList = jsonDecode(data) as List;
    return dataList.map((row) => (row as List).cast<int>()).toList();
  }
}
