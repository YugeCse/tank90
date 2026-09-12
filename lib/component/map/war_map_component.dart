import 'package:async/async.dart';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:tank90/component/base/boss_wall_state.dart';
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

  /// boss 保护墙的墙面类型
  MapCellType _bossWallMapCellType = MapCellType.mudWall;

  /// boss 保护墙的闪烁定时器
  TimerComponent? _bossWallFlickerTimer;

  CancelableOperation? _cancelableOperationForBossWall;

  /// 当前关卡数据
  List<List<int>>? mapCellDatas;

  /// 当前关卡组件集合
  List<List<MapCellComponent?>>? mapCells;

  /// boss 围墙坐标集合
  final List<Vector2> _bossWallCoordinations = [];

  /// 构造方法
  WarMapComponent({required this.stage, super.position});

  @override
  Future<void>? onLoad() async {
    _setMapLocation();
    await add(GameCellComponent()); //生成地图基础格子
    await generateWarMap(); //生成战争地图数据
    changeBossWallState(FlickerBossWallState());
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

  /// 调整地图位置
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
        // 如果是 boss 这块的数据
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
    // 计算 Boss 这一块的一些坐标数据
    if (_bossGridPosition != null) {
      if (_bossGridPosition == null) return;
      add(
        bossComponent ??= BossComponent(
          isAlive: true,
          position: Vector2(
            _bossGridPosition!.x * MapCellType.size.x,
            _bossGridPosition!.y * MapCellType.size.y,
          ),
        ),
      );
      var wallCellX = (_bossGridPosition!.x - 1).toInt();
      var wallCellMaxX = (_bossGridPosition!.x + 2).toInt();
      var wallCellY = (_bossGridPosition!.y - 1).toInt();
      var wallCellMaxY = (_bossGridPosition!.y + 1).toInt();
      var cols = wallCellMaxX - wallCellX;
      var rows = wallCellMaxY - wallCellY;
      _bossWallCoordinations.clear(); //清空原始数据集合
      for (var y = 0; y <= rows; y++) {
        for (var x = 0; x <= cols; x++) {
          var colX = wallCellX + x;
          var colY = wallCellY + y;
          if (x >= 1 && x <= 2 && y >= 1 && y <= 2) {
            continue; //boss 核心区域，直接下一次循环
          }
          _bossWallCoordinations.add(Vector2(colX.toDouble(), colY.toDouble()));
        }
      }
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

  ///为 boss 绘制保护墙
  void _drawBossProtectWalls(MapCellType cellType) {
    if (_bossWallCoordinations.isEmpty ||
        (cellType != MapCellType.steelWall &&
            cellType != MapCellType.mudWall)) {
      return; //不会只其他类型的墙 //boss 墙数据不存在的时候直接返回
    }
    for (var coord in _bossWallCoordinations) {
      var x = coord.x.toInt();
      var y = coord.y.toInt();
      var cellPosition = Vector2(
        x * MapCellType.size.x,
        y * MapCellType.size.y,
      );
      final cell = MapCellComponent(type: cellType, position: cellPosition);
      // 存入索引表
      mapCells![y][x] = cell;
      add(cell);
    }
  }

  /// 清空 boss 保护墙
  void _clearBossProtectWalls() {
    if (_bossWallCoordinations.isEmpty) return; //boss 墙数据不存在的时候直接返回
    for (var coord in _bossWallCoordinations) {
      var x = coord.x.toInt();
      var y = coord.y.toInt();
      // 存入索引表
      var component = mapCells![y][x];
      if (component != null) {
        component.removeFromParent();
        mapCells![y][x] = null; //清空地图表格的组件数据
      }
    }
  }

  /// 修改 boss 墙状态为闪烁状态
  void _changeBossProtectWallsToFlickerState() {
    if (_bossWallMapCellType == MapCellType.mudWall) {
      _bossWallMapCellType = MapCellType.steelWall;
    } else {
      _bossWallMapCellType = MapCellType.mudWall;
    }
    if (_bossWallCoordinations.isEmpty) return; //boss 墙数据不存在的时候直接返回
    for (var coord in _bossWallCoordinations) {
      var x = coord.x.toInt();
      var y = coord.y.toInt();
      var cellPosition = Vector2(
        x * MapCellType.size.x,
        y * MapCellType.size.y,
      );
      if (mapCells![y][x] == null) {
        final cell = MapCellComponent(
          type: _bossWallMapCellType,
          position: cellPosition,
        );
        // 存入索引表
        mapCells![y][x] = cell;
        add(cell);
      } else {
        var mapCell = mapCells![y][x];
        mapCell?.changeType(_bossWallMapCellType);
      }
    }
    debugPrint('执行了闪烁效果: _changeBossProtectWallsToFlickerState');
  }

  /// 执行保护墙闪烁定时器
  void _execBossWallFlickerTimer() {
    _removeBossWallFlickerTimer();
    add(
      _bossWallFlickerTimer ??= TimerComponent(
        period: 0.5,
        autoStart: true,
        repeat: true,
        tickCount: 20,
        onTick: _changeBossProtectWallsToFlickerState,
      ),
    );
    debugPrint('执行了闪烁效果: _execBossWallFlickerTimer');
  }

  /// 删除保护墙闪烁定时器
  void _removeBossWallFlickerTimer() {
    _bossWallFlickerTimer?.removeFromParent();
    _bossWallFlickerTimer = null;
    debugPrint('执行了闪烁效果: _removeBossWallFlickerTimer');
  }

  /// 修改 Boss 保护墙的状态
  void changeBossWallState(BossWallState state) {
    _removeBossWallFlickerTimer();
    if (_cancelableOperationForBossWall?.isCompleted != true &&
        _cancelableOperationForBossWall?.isCanceled != true) {
      _cancelableOperationForBossWall?.cancel();
      _cancelableOperationForBossWall = null;
    }
    if (state is NoneBossWallState) {
      _clearBossProtectWalls();
    } else if (state is MudBossWallState) {
      _drawBossProtectWalls(MapCellType.mudWall);
    } else if (state is SteelBossWallState) {
      _drawBossProtectWalls(MapCellType.steelWall);
      _cancelableOperationForBossWall = CancelableOperation.fromFuture(
        Future.delayed(
          Duration(seconds: 50),
          () => changeBossWallState(FlickerBossWallState()),
        ),
      );
    } else if (state is FlickerBossWallState) {
      _execBossWallFlickerTimer(); //执行闪烁的保护状态强
    }
  }
}
