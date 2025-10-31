import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

class JoystickFireComponent extends CustomPainterComponent
    with HasGameReference, TapCallbacks {
  JoystickFireComponent({required this.onFireTap})
    : super(size: Vector2.all(80), priority: 1, anchor: Anchor.center);

  Color buttonBgColor = const Color.fromARGB(135, 80, 80, 80);

  final void Function() onFireTap;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    var paint = Paint()
      ..isAntiAlias = true
      ..color = buttonBgColor;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2.0, paint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onFireTap();
    super.onTapDown(event);
    buttonBgColor = const Color(0x88999999);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    buttonBgColor = const Color.fromARGB(135, 80, 80, 80);
  }
}
