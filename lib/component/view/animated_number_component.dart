import 'dart:math';
import 'package:flame/text.dart';
import 'package:tank90/component/view/number_sprite_component.dart';

/// 动态数字组件
class AnimatedNumberComponent extends NumberSpriteComponent {
  /// 构造方法
  AnimatedNumberComponent({
    super.anchor,
    super.angle,
    this.duration = 1.0,
    required int initialValue,
    required TextRenderer textRenderer,
  }) : _displayValue = initialValue,
       _targetValue = initialValue,
       _startValue = initialValue;

  /// 动画时长（秒）
  final double duration;

  int _displayValue;
  int _targetValue;
  int _startValue;
  double _elapsed = 0;

  /// 当前显示的值
  int get displayValue => _displayValue;

  /// 目标值
  int get targetValue => _targetValue;

  /// 设置新目标值，会自动触发跑码动画
  set value(int newValue) {
    if (newValue == _targetValue) return;
    _startValue = _displayValue;
    _targetValue = newValue;
    _elapsed = 0;
  }

  /// 瞬间设置，不做动画
  void setValueImmediately(int newValue) {
    _displayValue = newValue;
    _targetValue = newValue;
    _startValue = newValue;
    _elapsed = 0;
    number = newValue;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_displayValue == _targetValue) return;

    _elapsed += dt;
    final t = (_elapsed / duration).clamp(0.0, 1.0);

    // easeOutCubic，可换成其他缓动
    final eased = 1 - pow(1 - t, 3);

    _displayValue = (_startValue + (_targetValue - _startValue) * eased)
        .round();
    number = _displayValue;

    if (t >= 1.0) {
      _displayValue = _targetValue;
      number = _displayValue;
    }
  }
}
