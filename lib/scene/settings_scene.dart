import 'package:flutter/material.dart' hide OverlayRoute;
import 'package:tank90/scene/tank_war_game.dart';
import 'package:tank90/utils/audio_utils.dart';

/// 设置界面
class SettingsScene extends StatefulWidget {
  /// 游戏对象
  final TankWarGame game;

  /// 构造方法
  const SettingsScene({super.key, required this.game});

  @override
  State<SettingsScene> createState() => _SettingsSceneState();
}

class _SettingsSceneState extends State<SettingsScene> {
  bool _isSoundOpen = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => setState(() => _isSoundOpen = AudioUtils().allowPlay),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.game.size.x,
        height: widget.game.size.y,
        alignment: Alignment.center,
        color: Colors.black.withAlpha(100),
        child: Container(
          width: 500,
          height: 400,
          decoration: BoxDecoration(
            border: BoxBorder.all(
              width: 5.0,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.grey.withValues(alpha: 0.9),
          ),
          child: Column(
            children: [
              _buildTitleView(),
              Divider(color: Colors.grey),
              _buildItemView(
                title: '开启声音',
                value: _isSoundOpen,
                onChanged: _toggleSoundOpenState,
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: _buildFlatButton(
                  text: '关闭',
                  onClick: () => widget.game.router.pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建标题视图
  Widget _buildTitleView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: Text(
        '游戏设置',
        style: TextStyle(color: Colors.white, fontSize: 32.0),
      ),
    );
  }

  /// 构建 Item 视图
  Widget _buildItemView({
    required String title,
    required bool value,
    required void Function(bool) onChanged,
  }) => Padding(
    padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontSize: 20, color: Colors.white)),
        Spacer(),
        Switch(value: value, onChanged: onChanged),
      ],
    ),
  );

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
  void _toggleSoundOpenState(bool isOpen) {
    AudioUtils().allowPlay = isOpen;
    setState(() => _isSoundOpen = isOpen);
  }
}
