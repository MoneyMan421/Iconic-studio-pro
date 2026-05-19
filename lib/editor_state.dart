import 'dart:typed_data';

class EditorState {
  final double scale;
  final double rotation;
  final double brightness;
  final double contrast;
  final double saturation;
  final double blur;
  final double refractionIndex;
  final double sparkleIntensity;
  final double facetDepth;
  final Uint8List? userImageBytes;

  EditorState({
    this.scale = 50,
    this.rotation = 0,
    this.brightness = 100,
    this.contrast = 100,
    this.saturation = 100,
    this.blur = 0,
    this.refractionIndex = 2.42,
    this.sparkleIntensity = 0.8,
    this.facetDepth = 0.6,
    this.userImageBytes,
  });

  EditorState copyWith({
    double? scale,
    double? rotation,
    double? brightness,
    double? contrast,
    double? saturation,
    double? blur,
    double? refractionIndex,
    double? sparkleIntensity,
    double? facetDepth,
    Uint8List? userImageBytes,
  }) => EditorState(
    scale: scale ?? this.scale,
    rotation: rotation ?? this.rotation,
    brightness: brightness ?? this.brightness,
    contrast: contrast ?? this.contrast,
    saturation: saturation ?? this.saturation,
    blur: blur ?? this.blur,
    refractionIndex: refractionIndex ?? this.refractionIndex,
    sparkleIntensity: sparkleIntensity ?? this.sparkleIntensity,
    facetDepth: facetDepth ?? this.facetDepth,
    userImageBytes: userImageBytes ?? this.userImageBytes,
  );
}
