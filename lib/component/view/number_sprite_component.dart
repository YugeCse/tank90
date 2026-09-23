import 'dart:async';

import 'package:flame/components.dart';
import 'package:tank90/utils/list_utils.dart';
import 'package:tank90/utils/num_utils.dart';
import 'package:tank90/utils/res_img_utils.dart';

/// 数字精灵组件
class NumberSpriteComponent extends PositionComponent {
  /// 具体的数值变量
  int _number;

  /// 数字拆分后对应的数字集合
  final List<int> _numbers = [];

  /// 数字资源占用的UI大小
  final Vector2 _srcSize = Vector2(14, 13);

  /// 数字0在资源上的坐标位置
  final Vector2 _zeroPosition = Vector2(256, 96);

  /// 构造函数
  /// + [number] - 数值
  NumberSpriteComponent({
    int number = 0,
    super.anchor,
    super.angle,
    super.scale,
    super.position,
  }) : _number = number {
    _numbers.replaceAll(_number.spiltToList());
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    _renderNumSpriteComponents(_numbers); //渲染对应的数值
  }

  /// 获取当前的数字值
  int get number => _number;

  /// 设置数字的值
  set number(int value) {
    _number = value;
    _numbers.replaceAll(value.spiltToList());
    _renderNumSpriteComponents(_numbers);
  }

  /// 渲染数字精灵组件集合
  void _renderNumSpriteComponents(List<int> nums) {
    removeAll(children);
    for (var i = 0; i < nums.length; i++) {
      var num = nums[i];
      var position = Vector2(_srcSize.x * i, 0);
      add(
        SpriteComponent(
          sprite: Sprite(
            assetImage,
            srcSize: _srcSize,
            srcPosition: Vector2(
              _zeroPosition.x + num * _srcSize.x,
              _zeroPosition.y,
            ),
          ),
        )..position = position,
      );
    }
    size = Vector2(nums.length * _srcSize.x, _srcSize.y);
  }
}
