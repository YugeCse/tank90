import 'dart:ui' show Canvas, Offset, Paint, Color, PaintingStyle;

import 'package:flame/components.dart' show CustomPainterComponent, Vector2;

class JoystickKnobComponent extends CustomPainterComponent {
  JoystickKnobComponent() : super(size: Vector2.all(60));

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;
    final paint = Paint()
      ..color = const Color(0x99000000)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
    final borderPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, borderPaint);
  }
}
