import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

class AudioUtils {
  AudioUtils._internal();

  factory AudioUtils() => _instance;

  static final _instance = AudioUtils._internal();

  /// 预加载所有音效到缓存
  static Future<void> preloadAll() async {
    final files = [
      'start.mp3',
      'attack.mp3',
      'move.mp3',
      'bulletCrack.mp3',
      'playerCrack.mp3',
      'prop.mp3',
      'tankCrack.mp3',
    ];

    // 一个音频资源失败不能阻止游戏启动，尤其是 Web 端的资源加载。
    await Future.wait(
      files.map((file) async {
        try {
          await FlameAudio.audioCache.load(file);
        } catch (_) {
          // 播放时还会再次尝试，预加载失败不影响游戏运行。
        }
      }),
    );
  }

  /// 是否允许播放声音
  bool allowPlay = false;

  /// 检测并播放声音
  void _checkAndPlay(Future<AudioPlayer> Function() next) {
    if (allowPlay) {
      // Web 浏览器可能因为自动播放策略拒绝 play，不能让异常冒泡到游戏主循环。
      unawaited(_playSafely(next));
    }
  }

  Future<void> _playSafely(Future<AudioPlayer> Function() next) async {
    try {
      await next();
    } catch (_) {
      // 音频失败不应影响游戏逻辑。
    }
  }

  /// 播放开始音乐
  void playStart() =>
      _checkAndPlay(() => FlameAudio.playLongAudio('start.mp3', volume: 0.5));

  void playAttack() => _checkAndPlay(() => FlameAudio.play('attack.mp3'));

  void playMove() => _checkAndPlay(() => FlameAudio.play('move.mp3'));

  void playBulletCrack() =>
      _checkAndPlay(() => FlameAudio.play('bulletCrack.mp3'));

  void playPlayerCrack() =>
      _checkAndPlay(() => FlameAudio.play('playerCrack.mp3'));

  void playProp() => _checkAndPlay(() => FlameAudio.play('prop.mp3'));

  void playTankCrack() => _checkAndPlay(() => FlameAudio.play('tankCrack.mp3'));
}
