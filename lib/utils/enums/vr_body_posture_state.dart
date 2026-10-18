/// High-level physical posture inferred from the fused head height, foot
/// contact state, and vertical velocity.
enum VrBodyPostureState {
  standing,
  walking,
  crouching,
  seated,
  jumping,
}
