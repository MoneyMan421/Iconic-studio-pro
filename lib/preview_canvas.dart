import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import 'app_colors.dart';
import 'editor_state.dart';

class PreviewCanvas extends StatefulWidget {
  final EditorState state;
  final VoidCallback onPickImage;

  const PreviewCanvas({
    super.key,
    required this.state,
    required this.onPickImage,
  });

  @override
  State<PreviewCanvas> createState() => _PreviewCanvasState();
}

class _PreviewCanvasState extends State<PreviewCanvas>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _elapsedSeconds = 0;

  static const double _lightOrbitRadius = 0.3;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() => _elapsedSeconds = elapsed.inMilliseconds / 1000.0);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return SizedBox(
      width: 380,
      height: 500,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.panelBorder),
            ),
            child: const Text(
              'Preview Canvas',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: s.userImageBytes != null
                  ? ShaderBuilder(
                      assetKey: 'shaders/diamond_master.frag',
                      (context, shader, child) => AnimatedSampler(
                        (image, size, canvas) {
                          _configureShader(shader, size, s);
                          shader.setImageSampler(0, image);
                          canvas.drawRect(
                            Offset.zero & size,
                            Paint()..shader = shader,
                          );
                        },
                        child: Image.memory(
                          s.userImageBytes!,
                          fit: BoxFit.cover,
                          width: 300,
                          height: 300,
                        ),
                      ),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: widget.onPickImage,
            child: Container(
              width: 300,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.uploadZone,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.panelBorder),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.upload,
                      color: AppColors.gold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload your icon',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PNG or JPG (max. 5 MB)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.uploadZone,
      child: Center(
        child: Icon(
          Icons.diamond,
          color: AppColors.gold.withValues(alpha: 0.3),
          size: 80,
        ),
      ),
    );
  }

  void _configureShader(FragmentShader shader, Size size, EditorState s) {
    final lightX = _lightOrbitRadius * math.cos(_elapsedSeconds * 0.4);
    final lightY = _lightOrbitRadius * math.sin(_elapsedSeconds * 0.4);

    int i = 0;
    shader.setFloat(i++, size.width);
    shader.setFloat(i++, size.height);
    shader.setFloat(i++, _elapsedSeconds);
    shader.setFloat(i++, s.refractionIndex);
    shader.setFloat(i++, s.sparkleIntensity);
    shader.setFloat(i++, s.facetDepth);
    shader.setFloat(i++, s.brightness / 100.0);
    shader.setFloat(i++, s.contrast / 100.0);
    shader.setFloat(i++, s.saturation / 100.0);
    shader.setFloat(i++, s.blur);
    shader.setFloat(i++, lightX);
    shader.setFloat(i++, lightY);
    shader.setFloat(i++, 1.0);
    shader.setFloat(i++, s.rotation * (math.pi / 180.0));
    shader.setFloat(i++, s.scale / 50.0);
  }
}
