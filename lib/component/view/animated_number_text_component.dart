import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/text.dart';

/// 动态数字组件
class AnimatedNumberTextComponent extends TextComponent {
  AnimatedNumberTextComponent({
    required int initialValue,
    required TextRenderer textRenderer,
    this.duration = 1.0,
    this.formatter,
    super.anchor,
    super.angle,
    super.size,
  }) : _displayValue = initialValue,
       _targetValue = initialValue,
       _startValue = initialValue,
       super(
         text: formatter?.call(initialValue) ?? '$initialValue',
         textRenderer: textRenderer,
       );

  /// 动画时长（秒）
  final double duration;

  /// 自定义格式化，比如千分位、补零
  final String Function(int value)? formatter;

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
    text = formatter?.call(newValue) ?? '$newValue';
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
    text = formatter?.call(_displayValue) ?? '$_displayValue';

    if (t >= 1.0) {
      _displayValue = _targetValue;
      text = formatter?.call(_displayValue) ?? '$_displayValue';
    }
  }
}
