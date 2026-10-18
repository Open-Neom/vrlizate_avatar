/// Identifies each of the three optical camera streams in the dual-smartphone
/// VRlizate full-body tracking setup.
enum VrCameraStreamRole {
  /// Camera 1: Smartphone Visor rear (world-facing) camera looking forward and
  /// downward at the room horizon, floor plane, hands, and feet when glancing down.
  visorFrontWorld,

  /// Camera 2: Smartphone Joystick rear camera looking downward toward the
  /// floor plane and the user's legs/feet.
  joystickRearFloor,

  /// Camera 3: Smartphone Joystick front (selfie) camera looking upward toward
  /// the user's chest, shoulders, neck, and Head/Visor.
  joystickFrontUpperBody,
}
