import 'package:shared_preferences/shared_preferences.dart';

/// Persists [EditorState] field values and import count across app restarts.
///
/// Uses [SharedPreferences] so that slider settings and the import counter
/// survive process termination without requiring any back-end.
class EditorStorage {
  EditorStorage._();

  // ── preference keys ─────────────────────────────────────────────────────
  static const _kScale = 'es_scale';
  static const _kRotation = 'es_rotation';
  static const _kBrightness = 'es_brightness';
  static const _kContrast = 'es_contrast';
  static const _kSaturation = 'es_saturation';
  static const _kBlur = 'es_blur';
  static const _kRefractionIndex = 'es_refractionIndex';
  static const _kSparkleIntensity = 'es_sparkleIntensity';
  static const _kFacetDepth = 'es_facetDepth';
  static const _kImportsUsed = 'es_importsUsed';

  // ── public API ───────────────────────────────────────────────────────────

  /// Writes every editor value to persistent storage.
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
    required int importsUsed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setDouble(_kScale, scale),
      prefs.setDouble(_kRotation, rotation),
      prefs.setDouble(_kBrightness, brightness),
      prefs.setDouble(_kContrast, contrast),
      prefs.setDouble(_kSaturation, saturation),
      prefs.setDouble(_kBlur, blur),
      prefs.setDouble(_kRefractionIndex, refractionIndex),
      prefs.setDouble(_kSparkleIntensity, sparkleIntensity),
      prefs.setDouble(_kFacetDepth, facetDepth),
      prefs.setInt(_kImportsUsed, importsUsed),
    ]);
  }

  /// Reads previously saved values.  Returns default [EditorState] defaults
  /// when no data has been written yet.
  static Future<SavedEditorData> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SavedEditorData(
      scale: prefs.getDouble(_kScale) ?? 50.0,
      rotation: prefs.getDouble(_kRotation) ?? 0.0,
      brightness: prefs.getDouble(_kBrightness) ?? 100.0,
      contrast: prefs.getDouble(_kContrast) ?? 100.0,
      saturation: prefs.getDouble(_kSaturation) ?? 100.0,
      blur: prefs.getDouble(_kBlur) ?? 0.0,
      refractionIndex: prefs.getDouble(_kRefractionIndex) ?? 2.42,
      sparkleIntensity: prefs.getDouble(_kSparkleIntensity) ?? 0.8,
      facetDepth: prefs.getDouble(_kFacetDepth) ?? 0.6,
      importsUsed: prefs.getInt(_kImportsUsed) ?? 0,
    );
  }
}

/// Typed container for the data returned by [EditorStorage.load].
class SavedEditorData {
  const SavedEditorData({
    required this.scale,
    required this.rotation,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.blur,
    required this.refractionIndex,
    required this.sparkleIntensity,
    required this.facetDepth,
    required this.importsUsed,
  });

  final double scale;
  final double rotation;
  final double brightness;
  final double contrast;
  final double saturation;
  final double blur;
  final double refractionIndex;
  final double sparkleIntensity;
  final double facetDepth;
  final int importsUsed;
}
