import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

/// 音频播放控制类
class AudioUtils {
  AudioUtils._internal();

  factory AudioUtils() => _instance;

  static final _instance = AudioUtils._internal();

  late AudioPool _attackPool;

  late AudioPool _movePool;

  late AudioPool _bulletCrackPool;

  late AudioPool _playerCrackPool;

  late AudioPool _propPool;

  late AudioPool _tankCrackPool;

  /// 预加载所有音效到缓存
  Future<void> preload() async {
    _attackPool = await FlameAudio.createPool('attack.mp3', maxPlayers: 5);
    _movePool = await FlameAudio.createPool('move.mp3', maxPlayers: 5);
    _bulletCrackPool = await FlameAudio.createPool(
      'bulletCrack.mp3',
      maxPlayers: 5,
    );
    _playerCrackPool = await FlameAudio.createPool(
      'playerCrack.mp3',
      maxPlayers: 5,
    );
    _tankCrackPool = await FlameAudio.createPool(
      'tankCrack.mp3',
      maxPlayers: 5,
    );
    _propPool = await FlameAudio.createPool('prop.mp3', maxPlayers: 5);
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

  void _checkAndPlayAudioPool(Future<Future<void> Function()> Function() next) {
    if (allowPlay) {
      // Web 浏览器可能因为自动播放策略拒绝 play，不能让异常冒泡到游戏主循环。
      unawaited(_playSafely2(next));
    }
  }

  Future<void> _playSafely2(
    Future<Future<void> Function()> Function() next,
  ) async {
    try {
      await next();
    } catch (_) {
      // 音频失败不应影响游戏逻辑。
    }
  }

  /// 播放开始音乐
  void playStart() =>
      _checkAndPlay(() => FlameAudio.playLongAudio('start.mp3', volume: 0.5));

  /// 播放子弹射击的声音
  void playAttack() => _checkAndPlayAudioPool(() => _attackPool.start());

  /// 播放在冰上移动的声音
  void playMove() => _checkAndPlayAudioPool(() => _movePool.start());

  /// 播放子弹撞击的声音
  void playBulletCrack() =>
      _checkAndPlayAudioPool(() => _bulletCrackPool.start());

  /// 播放玩家被攻击的声音
  void playPlayerCrack() =>
      _checkAndPlayAudioPool(() => _playerCrackPool.start());

  /// 播放获得道具的声音
  void playProp() => _checkAndPlayAudioPool(() => _propPool.start());

  /// 播放坦克被攻击的声音
  void playTankCrack() => _checkAndPlayAudioPool(() => _tankCrackPool.start());
}
