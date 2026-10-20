/// Avatar appearance and personal VR preferences, independent of social profile,
/// authentication, renderer, tracking and persistence implementations.
library;

export 'domain/models/vr_accessibility_profile.dart';
export 'domain/models/vr_avatar_appearance.dart';
export 'domain/models/vr_avatar_emote_state.dart';
export 'domain/models/vr_avatar_pose.dart';
export 'domain/models/vr_avatar_preferences.dart';
export 'domain/models/vr_avatar_profile.dart';
export 'domain/models/vr_camera_landmark_frame.dart';
export 'domain/models/vr_full_body_kinematic_state.dart';
export 'domain/models/vr_shoulder_kinematics.dart';
export 'domain/models/vr_ultrasonic_range_sample.dart';
export 'domain/models/vr_user_anthropometry.dart';
export 'domain/services/vr_avatar_preset_catalog.dart';
export 'domain/services/vr_avatar_share_code_codec.dart';
export 'domain/services/vr_tri_camera_body_fusion_engine.dart';
export 'domain/services/vr_ultrasonic_tof_solver.dart';
export 'ui/vr_avatar_editor.dart';
export 'ui/vr_avatar_labels.dart';
export 'ui/vr_avatar_painter.dart';
export 'ui/vr_avatar_preview.dart';
export 'utils/constants/vr_avatar_constants.dart';
export 'utils/constants/vr_avatar_translation_constants.dart';
export 'utils/enums/vr_accessibility_posture_mode.dart';
export 'utils/enums/vr_avatar_emote.dart';
export 'utils/enums/vr_avatar_pattern.dart';
export 'utils/enums/vr_avatar_species.dart';
export 'utils/enums/vr_avatar_style.dart';
export 'utils/enums/vr_body_posture_state.dart';
export 'utils/enums/vr_camera_stream_role.dart';
