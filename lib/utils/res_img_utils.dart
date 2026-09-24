import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:tank90/data/game_constants.dart';

/// 资源图片扩展类
extension ResImgExtension on Component {
  /// 预加载
  Future<void> preloadImages() async {
    await Flame.images.load('tankAll.png');
    await Flame.images.load('ui-design.png');
  }

  /// 获取资源图片对象
  Image get assetImage => Flame.images.fromCache(GameConstants.RES_IMG_NAME);

  /// 获取 UI 设计图对象
  Image get uiDesignImage =>
      Flame.images.fromCache(GameConstants.UI_IMAGE_NAME);
}
