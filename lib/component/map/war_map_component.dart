import 'dart:math';

import 'package:tank90/component/base/map_cell_type.dart' show MapCellType;
import 'package:tank90/component/map/boss_component.dart';
import 'package:tank90/component/map/game_cell_component.dart';
import 'package:tank90/component/map/map_cell_component.dart'
    show MapCellComponent;
import 'package:tank90/data/map_constants.dart';
import 'package:tank90/data/map_stage_level.dart';
import 'package:tank90/scene/tank_war_game.dart' show TankWarGame;
import 'package:flame/components.dart';

/// 战场地图组件
class WarMapComponent extends PositionComponent
    with HasGameReference<TankWarGame> {
  /// 关卡数
  int stage = 0;

  /// boss 表格坐标
  Vector2? _bossGridPosition;

  /// boss 组件对象
  BossComponent? bossComponent;

  /// 当前关卡数据
  List<List<int>>? mapCellDatas;

  /// 当前关卡组件集合
  List<List<MapCellComponent?>>? mapCells;

  /// 构造方法
  WarMapComponent({required this.stage, super.position});

  @override
  Future<void>? onLoad() async {
    _setMapLocation();
    add(GameCellComponent()); //生成地图基础格子
    generateWarMap(); //生成战争地图数据
  }

  @override
  void onGameResize(Vector2 size) {
    try {
      _setMapLocation();
      relocationWarMap(size);
    } finally {
      super.onGameResize(size);
    }
  }

  void _setMapLocation() {
    var mapWidth = MapConstants.mapSize.x;
    var mapHeight = MapConstants.mapSize.y;
    var scaleX = game.size.x / mapWidth;
    var scaleY = game.size.y / mapHeight;
    var scaleV = min(scaleX, scaleY);
    scale = Vector2.all(scaleV);
    position.x = (game.size.x - mapWidth * scaleV) / 2;
    position.y = (game.size.y - mapHeight * scaleV) / 2;
  }

  /// 生成战争地图
  Future<void> generateWarMap() async {
    mapCellDatas = MapStageLevel.maps[stage];
    // 初始化 mapCells 为相同的行列结构，方便按行列索引瓦片组件
    mapCells = List.generate(
      mapCellDatas!.length,
      (r) => List<MapCellComponent?>.filled(mapCellDatas![r].length, null),
    );
    for (var row = 0; row < mapCellDatas!.length; row++) {
      for (var col = 0; col < mapCellDatas![row].length; col++) {
        final cellData = mapCellDatas![row][col];
        var cellPosition = Vector2(
          col * MapCellType.size.x,
          row * MapCellType.size.y,
        );
        if (cellData == 9 && _bossGridPosition == null) {
          _bossGridPosition = Vector2(col.toDouble(), row.toDouble());
        }
        final cellType = MapCellType.fromValue(cellData);
        if (cellType == null) continue;
        final cell = MapCellComponent(type: cellType, position: cellPosition);
        // 存入索引表
        mapCells![row][col] = cell;
        await add(cell);
      }
    }
    if (_bossGridPosition != null) {
      add(
        bossComponent ??= BossComponent(
          isAlive: true,
          position: Vector2(
            _bossGridPosition!.x * MapCellType.size.x,
            _bossGridPosition!.y * MapCellType.size.y,
          ),
        ),
      );
    }
  }

  /// 重新定位战场地图
  void relocationWarMap(Vector2 size) {
    if (mapCells?.isNotEmpty == true) {
      for (var row = 0; row < mapCells!.length; row++) {
        for (var col = 0; col < mapCells![row].length; col++) {
          final cell = mapCells![row][col];
          cell?.position = Vector2(
            col * MapCellType.size.x,
            row * MapCellType.size.y,
          );
        }
      }
      if (_bossGridPosition != null) {
        var col = _bossGridPosition!.x;
        var row = _bossGridPosition!.y;
        bossComponent?.position = Vector2(
          col * MapCellType.size.x,
          row * MapCellType.size.y,
        );
      }
    }
  }
}
