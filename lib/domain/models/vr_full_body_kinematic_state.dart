import 'package:vector_math/vector_math.dart';

import '../../utils/enums/vr_body_posture_state.dart';
import 'vr_avatar_pose.dart';
import 'vr_user_anthropometry.dart';

/// Complete 3D full-body kinematic state solved in real time from the 3-camera
/// optical streams, dual IMUs, and ultrasonic inter-smartphone ranging.
class VrFullBodyKinematicState {
  const VrFullBodyKinematicState({
    required this.headHeightMeters,
    required this.joystickHeightMeters,
    required this.headToJoystickVerticalMeters,
    required this.headToJoystickDistanceMeters,
    required this.joystickPositionRelativeToHead,
    required this.leftFootPosition,
    required this.rightFootPosition,
    required this.locomotionVelocity,
    required this.postureState,
    required this.anthropometry,
    required this.avatarPose,
    this.stridePhaseRadians = 0.0,
  });

  /// Solved height of the Visor (Head) above the floor plane ($H_{\text{head}}$) in meters.
  final double headHeightMeters;

  /// Solved height of the Joystick smartphone above the floor plane ($H_{\text{joy}}$) in meters.
  final double joystickHeightMeters;

  /// Vertical separation $\Delta H_{\text{head}-\text{joy}} = H_{\text{head}} - H_{\text{joy}}$.
  final double headToJoystickVerticalMeters;

  /// Fused 3D Euclidean distance $\|\mathbf{p}_{\text{head}} - \mathbf{p}_{\text{joy}}\|$ in meters.
  final double headToJoystickDistanceMeters;

  /// 3D vector $\mathbf{p}_{\text{joy}} - \mathbf{p}_{\text{head}}$ in meters
  /// (`+X` right, `+Y` up, `-Z` forward).
  final Vector3 joystickPositionRelativeToHead;

  /// 3D position of the left foot on/above the floor relative to the body ground projection.
  final Vector3 leftFootPosition;

  /// 3D position of the right foot on/above the floor relative to the body ground projection.
  final Vector3 rightFootPosition;

  /// Inferred ground-plane walking velocity (`m/s`) from foot step cadence & swing.
  final Vector3 locomotionVelocity;

  /// Solved physical posture (`standing`, `walking`, `crouching`, `seated`, `jumping`).
  final VrBodyPostureState postureState;

  /// Calibrated user stature and biomechanical limb lengths.
  final VrUserAnthropometry anthropometry;

  /// Procedural rig pose ready to drive any 3D avatar in `vrlizate_avatar` / `vrlizate_scene`.
  final VrAvatarPose avatarPose;

  /// Continuous gait cycle phase in radians.
  final double stridePhaseRadians;
}
