import 'package:flame_audio/flame_audio.dart';

class AudioUtils {
  AudioUtils._internal();

  factory AudioUtils() => _instance;

  static final _instance = AudioUtils._internal();

  /// 是否允许播放声音
  bool allowPlay = true;

  /// 检测并播放声音
  void _checkAndPlay(void Function() next) {
    if (allowPlay) next();
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
