import 'package:flutter/material.dart' hide OverlayRoute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tank90/data/game_constants.dart';
import 'package:tank90/data/game_properties.dart';
import 'package:tank90/app/provider/global_config.dart';

/// 设置界面
class SettingsScene extends ConsumerStatefulWidget {
  /// 构造方法
  const SettingsScene({
    super.key,
    required this.rootContainerSize,
    required this.onRequestSceneClose,
  });

  /// 根容器尺寸大小
  final Size rootContainerSize;

  /// 请求场景关闭
  final void Function() onRequestSceneClose;

  @override
  ConsumerState<SettingsScene> createState() => _SettingsSceneState();
}

class _SettingsSceneState extends ConsumerState<SettingsScene>
    with SingleTickerProviderStateMixin {
  late Animation<Offset> _animation;

  late AnimationController _shakeController;

  @override
  void initState() {
    _shakeController = AnimationController(vsync: this)
      ..duration = Duration(seconds: 2)
      ..repeat(count: 3, period: Duration(milliseconds: 500));
    _animation = Tween(begin: Offset(-15, 0), end: Offset(15, 0)).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
    _shakeController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var globalConfigInfo = ref.watch(globalConfigProvider);
    var level = globalConfigInfo.gameLevel;
    var soundAvailable = globalConfigInfo.soundAvailable;
    debugPrint('global config: $level, $soundAvailable');
    return Material(
      color: Colors.transparent,
      child: Container(
        alignment: .center,
        color: Colors.black.withAlpha(100),
        width: widget.rootContainerSize.width,
        height: widget.rootContainerSize.height,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (_, _) => _buildDialogContentView(
            level: level,
            soundAvailable: soundAvailable,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  /// 构建窗口内容区域
  /// + []
  Widget _buildDialogContentView({
    required GameLevel level,
    required bool soundAvailable,
  }) => Container(
    alignment: .center,
    width: GameConstants.CANVAS_SIZE.x,
    height: GameConstants.CANVAS_SIZE.y,
    decoration: BoxDecoration(
      border: .all(width: 5.0, color: Colors.white.withValues(alpha: 0.5)),
      borderRadius: .circular(12.0),
      color: Colors.grey.withValues(alpha: 0.9),
    ),
    child: Column(
      children: [
        _buildTitleView(),
        Divider(color: Colors.grey),
        _buildSwitchItemView(
          title: '开启声音',
          value: soundAvailable,
          onChanged: _toggleSoundOpenState,
        ),
        Divider(color: Colors.transparent, height: 16.0),
        _buildLevelChoiceItemView(level: level),
        Spacer(),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: _buildFlatButton(
            text: '关闭',
            onClick: widget.onRequestSceneClose,
          ),
        ),
      ],
    ),
  );

  /// 构建标题视图
  Widget _buildTitleView() {
    return Padding(
      padding: .symmetric(horizontal: 0, vertical: 8.0),
      child: Text('设置', style: TextStyle(color: Colors.white, fontSize: 32.0)),
    );
  }

  /// 构建开关 Item 视图
  Widget _buildSwitchItemView({
    required String title,
    required bool value,
    required void Function(bool) onChanged,
  }) => Padding(
    padding: .symmetric(horizontal: 20),
    child: Row(
      crossAxisAlignment: .center,
      children: [
        Text(title, style: TextStyle(fontSize: 20, color: Colors.white)),
        Spacer(),
        Switch(value: value, onChanged: onChanged),
      ],
    ),
  );

  /// 构建模式 Item 视图
  Widget _buildLevelChoiceItemView({required GameLevel level}) {
    var textStyle = TextStyle(fontSize: 20, color: Colors.white);
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: .center,
        children: [
          Text('模式选择', style: TextStyle(fontSize: 20, color: Colors.white)),
          Spacer(),
          RadioGroup<GameLevel>(
            groupValue: level,
            onChanged: _toggleGameLevel,
            child: Row(
              crossAxisAlignment: .center,
              children: [
                Radio(value: GameLevel.easy),
                Padding(
                  padding: .only(right: 8),
                  child: Text('简单', style: textStyle),
                ),
                Radio(value: GameLevel.normal),
                Padding(
                  padding: .only(right: 8),
                  child: Text('一般', style: textStyle),
                ),
                Radio(value: GameLevel.difficulty),
                Padding(
                  padding: .only(right: 8),
                  child: Text('困难', style: textStyle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建按钮
  Widget _buildFlatButton({
    required String text,
    required void Function() onClick,
  }) => FilledButton(
    onPressed: onClick,
    style: ButtonStyle(
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 32, vertical: 12.0),
      ),
    ),
    child: Text(text, style: TextStyle(fontSize: 20, color: Colors.white)),
  );

  /// 切换声音是否打开的状态
  /// + [isOpen] - 是否打开声音
  void _toggleSoundOpenState(bool isOpen) {
    ref.read(globalConfigProvider.notifier).soundAvailable = isOpen;
  }

  /// 切换模式
  /// + [level] - 模式
  void _toggleGameLevel(GameLevel? level) {
    ref.read(globalConfigProvider.notifier).gameLevel = level ?? GameLevel.easy;
  }
}
