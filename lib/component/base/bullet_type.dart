/// 子弹类型
enum BulletType {
  normal(speed: 150.0),
  strong(speed: 180.0),
  xstrong(speed: 180.0);

  /// 速度
  final double speed;

  /// 构造方法
  const BulletType({required this.speed});
}
