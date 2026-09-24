import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/input.dart';
import 'package:tank90/data/game_properties.dart';
import 'package:tank90/utils/res_img_utils.dart';

/// 游戏难度 Radio 组件
class GameLevelRadioComponent extends PositionComponent {
  final GameLevel _level;
  bool _isChecked;
  void Function(bool) onCheckChanged;
  late final List<Sprite> _checkSprites;
  SpriteComponent? _radioSpriteComponent;

  GameLevelRadioComponent({
    super.position,
    bool isChecked = false,
    GameLevel level = GameLevel.easy,
    required this.onCheckChanged,
  }) : _isChecked = isChecked,
       _level = level;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    _checkSprites = [
      Sprite(
        uiDesignImage,
        srcSize: Vector2.all(16),
        srcPosition: Vector2(96, 0),
      ),
      Sprite(
        uiDesignImage,
        srcSize: Vector2.all(16),
        srcPosition: Vector2(96, 16),
      ),
    ];
    add(
      ButtonComponent(
        onPressed: _onRadioButtonClick,
        button: RowComponent(
          crossAxisAlignment: .center,
          children: [
            SpriteComponent(
              sprite: Sprite(
                uiDesignImage,
                srcSize: Vector2(30, 16),
                srcPosition: Vector2(
                  66,
                  (_level == GameLevel.easy
                      ? 0
                      : (_level == GameLevel.normal ? 16 : 32)),
                ),
              ),
            ),
            _radioSpriteComponent = SpriteComponent(
              size: Vector2.all(16),
              sprite: _checkSprites.first,
            ),
          ],
        ),
      ),
    );
    _radioSpriteComponent?.sprite = _isChecked
        ? _checkSprites.last
        : _checkSprites.first;
  }

  GameLevel get level => _level;

  bool get isChecked => _isChecked;

  set isChecked(bool value) {
    _radioSpriteComponent?.sprite = value
        ? _checkSprites.last
        : _checkSprites.first;
    if (value != _isChecked) {
      _isChecked = value;
      if (isMounted) onCheckChanged(value);
    }
  }

  /// Radio按钮点击事件
  void _onRadioButtonClick() => isChecked = !isChecked;
}
