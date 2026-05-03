import 'package:flutter/widgets.dart';

/// A ScrollPhysics that adjusts scroll behavior based on user's scroll velocity.
/// 
/// Features:
/// - Faster fling when user scrolls quickly
/// - Smoother deceleration based on initial velocity
/// - Configurable velocity multipliers
class VelocityAwareScrollPhysics extends ScrollPhysics {
  /// Multiplier for fling velocity. Higher values = faster scroll.
  final double velocityMultiplier;

  /// Minimum velocity to start a fling (pixels per second).
  @override
  final double minFlingVelocity;

  /// Maximum velocity for fling (pixels per second).
  @override
  final double maxFlingVelocity;

  /// Creates physics that responds to user's scroll velocity.
  const VelocityAwareScrollPhysics({
    super.parent,
    this.velocityMultiplier = 1.5,
    this.minFlingVelocity = 50.0,
    this.maxFlingVelocity = 8000.0,
  });

  @override
  VelocityAwareScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return VelocityAwareScrollPhysics(
      parent: buildParent(ancestor),
      velocityMultiplier: velocityMultiplier,
      minFlingVelocity: minFlingVelocity,
      maxFlingVelocity: maxFlingVelocity,
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Apply velocity multiplier to make scrolling faster
    return offset * velocityMultiplier;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Use parent's boundary conditions (clamping by default)
    return super.applyBoundaryConditions(position, value);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // Adjust velocity based on user's scroll speed
    final adjustedVelocity = velocity * velocityMultiplier;
    
    // Clamp velocity to reasonable bounds
    final clampedVelocity = adjustedVelocity.clamp(-maxFlingVelocity, maxFlingVelocity);
    
    // Only create simulation if velocity exceeds minimum threshold
    if (clampedVelocity.abs() < minFlingVelocity && !position.outOfRange) {
      return null;
    }

    return super.createBallisticSimulation(position, clampedVelocity);
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 0.5,      // Lighter = faster response
    stiffness: 100, // Higher = stiffer spring
    damping: 1.0,   // Critical damping for smooth stop
  );
}

/// ScrollPhysics với adaptive velocity - tự động điều chỉnh dựa trên device/platform.
class AdaptiveScrollPhysics extends ScrollPhysics {
  final bool isHorizontalScroll;

  const AdaptiveScrollPhysics({
    super.parent,
    this.isHorizontalScroll = false,
  });

  @override
  AdaptiveScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return AdaptiveScrollPhysics(
      parent: buildParent(ancestor),
      isHorizontalScroll: isHorizontalScroll,
    );
  }

  @override
  double get minFlingVelocity {
    // Horizontal scroll cần velocity cao hơn để cảm thấy tự nhiên
    return isHorizontalScroll ? 100.0 : 50.0;
  }

  @override
  double get maxFlingVelocity {
    // Horizontal scroll cho phép velocity cao hơn
    return isHorizontalScroll ? 10000.0 : 8000.0;
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Tăng tốc độ cho horizontal scroll
    final multiplier = isHorizontalScroll ? 1.8 : 1.5;
    return offset * multiplier;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Use parent's boundary conditions
    return super.applyBoundaryConditions(position, value);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // Điều chỉnh velocity cho horizontal/vertical
    final adjustedVelocity = isHorizontalScroll ? velocity * 1.2 : velocity;
    
    if (adjustedVelocity.abs() < minFlingVelocity && !position.outOfRange) {
      return null;
    }

    return super.createBallisticSimulation(position, adjustedVelocity);
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 0.5,
    stiffness: 100,
    damping: 1.0,
  );
}