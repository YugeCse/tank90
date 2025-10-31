import 'dart:ui' show Paint, Color, PaintingStyle, Canvas, Offset;

import 'package:flame/components.dart';

class JoystickBgComponent extends CustomPainterComponent {
  final Paint _paint;

  JoystickBgComponent()
    : _paint = Paint()
        ..color = const Color.fromARGB(119, 114, 112, 112)
        ..style = PaintingStyle.fill,
      super(size: Vector2.all(150));

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;
    canvas.drawCircle(center, radius, _paint);
  }
}
