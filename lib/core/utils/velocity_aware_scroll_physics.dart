import 'package:flutter/widgets.dart';

/// ScrollPhysics tăng tốc scroll dựa trên velocity của user.
/// 
/// Kế thừa ClampingScrollPhysics để có ClampingScrollSimulation thực sự
/// (base ScrollPhysics.createBallisticSimulation trả về null).
///
/// pdfrx dùng InteractiveViewer fork, gọi:
/// - applyPhysicsToUserOffset() khi user drag
/// - createBallisticSimulation() khi user fling
/// - applyBoundaryConditions() để kiểm tra boundary
class VelocityAwareScrollPhysics extends ClampingScrollPhysics {
  /// Multiplier cho tốc độ scroll khi drag. Default 1.5.
  final double velocityMultiplier;

  /// Multiplier cho tốc độ fling. Default 2.0.
  final double flingMultiplier;

  const VelocityAwareScrollPhysics({
    super.parent,
    this.velocityMultiplier = 1.5,
    this.flingMultiplier = 2.0,
  });

  @override
  VelocityAwareScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return VelocityAwareScrollPhysics(
      parent: buildParent(ancestor),
      velocityMultiplier: velocityMultiplier,
      flingMultiplier: flingMultiplier,
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset * velocityMultiplier;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // Nhân velocity trước khi tạo simulation
    final boostedVelocity = velocity * flingMultiplier;
    return super.createBallisticSimulation(position, boostedVelocity);
  }
}
