import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:tank90/data/game_constants.dart';

/// 资源图片扩展类
extension ResImgExtension on Component {
  /// 获取资源图片对象
  Image get assetImage => Flame.images.fromCache(GameConstants.RES_IMG_NAME);
}
