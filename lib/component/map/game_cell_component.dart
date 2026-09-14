import 'dart:ui';

import 'package:tank90/data/game_constants.dart';
import 'package:flame/components.dart';

class GameCellComponent extends CustomPainterComponent {
  GameCellComponent() : super(size: GameConstants.MAP_SIZE, priority: 0);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    var paint = Paint()..color = const Color.fromARGB(255, 0, 0, 0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, GameConstants.MAP_SIZE.x, GameConstants.MAP_SIZE.y),
      paint,
    );
    paint.color = const Color.fromARGB(255, 21, 21, 21);
    for (var i = 0; i < GameConstants.MAP_GRID_SIZE.x; i++) {
      canvas.drawLine(Offset(16.0 * i, 0), Offset(16.0 * i, 416), paint);
    }
    for (var j = 0; j < GameConstants.MAP_GRID_SIZE.y; j++) {
      canvas.drawLine(Offset(0, 16.0 * j), Offset(416, 16.0 * j), paint);
    }
    canvas.restore();
  }
}
