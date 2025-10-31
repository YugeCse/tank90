import 'dart:ui';

import 'package:tank90/data/map_constants.dart';
import 'package:flame/components.dart';

class GameCellComponent extends CustomPainterComponent {
  GameCellComponent() : super(size: MapConstants.mapSize, priority: 0);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    var paint = Paint()..color = const Color.fromARGB(255, 129, 128, 128);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, MapConstants.mapSize.x, MapConstants.mapSize.y),
      paint,
    );
    paint.color = const Color.fromARGB(255, 118, 117, 117);
    for (var i = 0; i < MapConstants.mapGridSize.x; i++) {
      canvas.drawLine(Offset(16.0 * i, 0), Offset(16.0 * i, 416), paint);
    }
    for (var j = 0; j < MapConstants.mapGridSize.y; j++) {
      canvas.drawLine(Offset(0, 16.0 * j), Offset(416, 16.0 * j), paint);
    }
    canvas.restore();
  }
}
