import 'package:shared_preferences/shared_preferences.dart';

/// Persists and restores the numeric editor parameters between sessions.
/// Does NOT store the user image — that must be re-imported each session.
class EditorStorage {
  // ── Keys ────────────────────────────────────────────────────────────────
  static const _kScale            = 'es_scale';
  static const _kRotation         = 'es_rotation';
  static const _kBrightness       = 'es_brightness';
  static const _kContrast         = 'es_contrast';
  static const _kSaturation       = 'es_saturation';
  static const _kBlur             = 'es_blur';
  static const _kRefractionIndex  = 'es_refractionIndex';
  static const _kSparkleIntensity = 'es_sparkleIntensity';
  static const _kFacetDepth       = 'es_facetDepth';
  static const _kImportsUsed      = 'es_importsUsed';

  // ── Load ────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'scale':            prefs.getDouble(_kScale)            ?? 1.0,
      'rotation':         prefs.getDouble(_kRotation)         ?? 0.0,
      'brightness':       prefs.getDouble(_kBrightness)       ?? 1.0,
      'contrast':         prefs.getDouble(_kContrast)         ?? 1.0,
      'saturation':       prefs.getDouble(_kSaturation)       ?? 1.0,
      'blur':             prefs.getDouble(_kBlur)             ?? 0.0,
      'refractionIndex':  prefs.getDouble(_kRefractionIndex)  ?? 2.42,
      'sparkleIntensity': prefs.getDouble(_kSparkleIntensity) ?? 1.0,
      'facetDepth':       prefs.getDouble(_kFacetDepth)       ?? 1.0,
      'importsUsed':      prefs.getInt(_kImportsUsed)         ?? 0,
    };
  }

  // ── Save ────────────────────────────────────────────────────────────────
  static Future<void> save({
    required double scale,
    required double rotation,
    required double brightness,
    required double contrast,
    required double saturation,
    required double blur,
    required double refractionIndex,
    required double sparkleIntensity,
    required double facetDepth,
    required int    importsUsed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setDouble(_kScale,            scale),
      prefs.setDouble(_kRotation,         rotation),
      prefs.setDouble(_kBrightness,       brightness),
      prefs.setDouble(_kContrast,         contrast),
      prefs.setDouble(_kSaturation,       saturation),
      prefs.setDouble(_kBlur,             blur),
      prefs.setDouble(_kRefractionIndex,  refractionIndex),
      prefs.setDouble(_kSparkleIntensity, sparkleIntensity),
      prefs.setDouble(_kFacetDepth,       facetDepth),
      prefs.setInt(_kImportsUsed,         importsUsed),
    ]);
  }
}
