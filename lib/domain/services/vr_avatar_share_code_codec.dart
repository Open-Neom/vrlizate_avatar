import 'dart:convert';

import '../../utils/constants/vr_avatar_constants.dart';
import '../models/vr_avatar_appearance.dart';
import '../models/vr_avatar_preferences.dart';
import '../models/vr_avatar_profile.dart';

/// Encodes and decodes [VrAvatarProfile] into a compact shareable string code.
abstract final class VrAvatarShareCodeCodec {
  /// Encodes [profile] into a `VRLZ-AV1:` base64url share code.
  static String encode(
    VrAvatarProfile profile, {
    bool includePreferences = true,
  }) {
    final map = includePreferences ? profile.toJson() : profile.toPublicJson();
    final bytes = utf8.encode(jsonEncode(map));
    final encoded = base64Url.encode(bytes).replaceAll('=', '');
    return '${VrAvatarConstants.shareCodePrefix}$encoded';
  }

  /// Decodes a `VRLZ-AV1:` share code into a validated [VrAvatarProfile].
  ///
  /// When [overrideProfileId] is supplied, the decoded appearance and
  /// preferences are bound to [overrideProfileId]. If the share code only
  /// carried public appearance data, default [VrAvatarPreferences] are used.
  static VrAvatarProfile decode(
    String shareCode, {
    String? overrideProfileId,
  }) {
    final trimmed = shareCode.trim();
    if (!trimmed.startsWith(VrAvatarConstants.shareCodePrefix)) {
      throw const FormatException(VrAvatarConstants.errInvalidShareCode);
    }
    final payload = trimmed.substring(VrAvatarConstants.shareCodePrefix.length);
    if (payload.isEmpty) {
      throw const FormatException(VrAvatarConstants.errInvalidShareCode);
    }
    try {
      final normalized = base64Url.normalize(payload);
      final jsonText = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map) {
        throw const FormatException(VrAvatarConstants.errInvalidShareCode);
      }
      final map = Map<String, dynamic>.from(decoded);
      if (!map.containsKey(VrAvatarConstants.keyPreferences)) {
        map[VrAvatarConstants.keyPreferences] = VrAvatarPreferences().toJson();
      }
      if (overrideProfileId != null) {
        map[VrAvatarConstants.keyProfileId] = overrideProfileId;
      }
      return VrAvatarProfile.fromJson(map);
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException(VrAvatarConstants.errInvalidShareCode);
    }
  }

  /// Extracts only the [VrAvatarAppearance] from a share code.
  static VrAvatarAppearance decodeAppearance(String shareCode) {
    return decode(
      shareCode,
      overrideProfileId: VrAvatarConstants.defaultPresetProfileId,
    ).appearance;
  }
}
