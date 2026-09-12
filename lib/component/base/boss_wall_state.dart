/// boss 墙的状态
sealed class BossWallState {}

/// boss 墙无保护
final class NoneBossWallState extends BossWallState {}

/// boss 墙钢铁保护
final class SteelBossWallState extends BossWallState {}

/// Boss 墙泥墙保护
final class MudBossWallState extends BossWallState {}

/// Boss 墙闪烁状态
final class FlickerBossWallState extends BossWallState {}
