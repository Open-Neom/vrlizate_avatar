import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

import '../../utils/constants/vr_avatar_constants.dart';
import '../../utils/enums/vr_camera_stream_role.dart';

/// Normalized 2D landmark and geometric observation extracted from one of the
/// three smartphone cameras ([VrCameraStreamRole]).
///
/// Normalized image coordinates `(u, v)` lie in `0.0..1.0`:
/// - `u = 0.0` is image-left, `u = 1.0` is image-right (`0.5` optical center).
/// - `v = 0.0` is image-top, `v = 1.0` is image-bottom (`0.5` optical center).
class VrCameraLandmarkFrame {
  VrCameraLandmarkFrame({
    required this.role,
    required this.cameraOrientation,
    this.horizontalFovRadians =
        VrAvatarConstants.defaultCameraHorizontalFovRadians,
    this.verticalFovRadians = VrAvatarConstants.defaultCameraVerticalFovRadians,
    this.confidence = 1.0,
    this.visorCenterUv,
    this.visorNormalizedWidth,
    this.leftShoulderUv,
    this.rightShoulderUv,
    this.leftFootUv,
    this.rightFootUv,
    this.leftFootGrounded = true,
    this.rightFootGrounded = true,
    this.observedFloorDistanceMeters,
    this.observedJoystickUvInVisor,
  });

  final VrCameraStreamRole role;

  /// Gravity-aligned orientation of the smartphone camera in world coordinates
  /// (`+Y` up, `-Z` forward, `+X` right).
  final Quaternion cameraOrientation;

  final double horizontalFovRadians;
  final double verticalFovRadians;
  final double confidence;

  // --- Camera 3 (Joystick Front / Selfie -> Upper Body & Visor) ---
  /// Center `(u, v)` of the Head/Visor detected in the Joystick front camera.
  final Vector2? visorCenterUv;

  /// Apparent horizontal width (`0..1` fraction of image width) of the Visor
  /// in the Joystick front camera, used to estimate monocular metric range.
  final double? visorNormalizedWidth;

  /// Left and right shoulder landmarks `(u, v)` in the Joystick front camera.
  final Vector2? leftShoulderUv;
  final Vector2? rightShoulderUv;

  // --- Camera 2 (Joystick Rear -> Floor & Feet) ---
  /// Left and right foot/ankle landmarks `(u, v)` in the Joystick rear camera.
  final Vector2? leftFootUv;
  final Vector2? rightFootUv;

  /// Whether each foot is currently in contact with the floor plane (`y = 0`).
  final bool leftFootGrounded;
  final bool rightFootGrounded;

  // --- Camera 1 (Visor Front World -> Floor Plane & Downward Glance) ---
  /// Direct head-to-floor vertical distance in meters when ARCore VIO or floor
  /// plane detection is active on the Visor camera.
  final double? observedFloorDistanceMeters;

  /// Optional `(u, v)` of the Joystick/hands when visible inside the Visor's
  /// world-facing camera during a downward glance.
  final Vector2? observedJoystickUvInVisor;

  /// Converts a normalized image point `uv` (`0..1`) into a unit ray direction
  /// in world space using the pinhole camera intrinsics and [cameraOrientation].
  Vector3 worldRayForUv(Vector2 uv) {
    final tanHalfH = math.tan(horizontalFovRadians * 0.5);
    final tanHalfV = math.tan(verticalFovRadians * 0.5);
    final ndcX = (uv.x - 0.5) * 2.0;
    final ndcY = (0.5 - uv.y) * 2.0;
    // Camera local frame: +X right, +Y up, -Z optical forward axis.
    final v = Vector3(ndcX * tanHalfH, ndcY * tanHalfV, -1.0)..normalize();
    final u = Vector3(
      cameraOrientation.x,
      cameraOrientation.y,
      cameraOrientation.z,
    );
    final w = cameraOrientation.w;
    final uvCross = u.cross(v);
    final uuvCross = u.cross(uvCross);
    return (v + uvCross * (2.0 * w) + uuvCross * 2.0)..normalize();
  }
}
