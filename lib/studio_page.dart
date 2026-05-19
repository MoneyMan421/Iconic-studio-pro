import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'app_colors.dart';
import 'editor_state.dart';
import 'editor_storage.dart';
import 'export_helper.dart';
import 'paywall_modal.dart';
import 'preview_canvas.dart';

class StudioPage extends StatefulWidget {
  final bool embeddedMode;
  final EditorState? initialState;
  final ValueChanged<EditorState>? onStateChanged;

  const StudioPage({
    super.key,
    this.embeddedMode = false,
    this.initialState,
    this.onStateChanged,
  });

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  EditorState editorState = EditorState();
  int importsUsed = 0;
  static const int freeImportLimit = 2;
  static const double exportPixelRatio = 3.0;
  final GlobalKey _previewBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.embeddedMode) {
      if (widget.initialState != null) {
        editorState = widget.initialState!;
      }
      return;
    }
    _loadState();
  }

  Future<void> _loadState() async {
    final saved = await EditorStorage.load();
    if (!mounted) return;
    setState(() {
      editorState = EditorState(
        scale: saved.scale,
        rotation: saved.rotation,
        brightness: saved.brightness,
        contrast: saved.contrast,
        saturation: saved.saturation,
        blur: saved.blur,
        refractionIndex: saved.refractionIndex,
        sparkleIntensity: saved.sparkleIntensity,
        facetDepth: saved.facetDepth,
      );
      importsUsed = saved.importsUsed;
    });
  }

  void _saveState() {
    if (widget.embeddedMode) {
      return;
    }
    EditorStorage.save(
      scale: editorState.scale,
      rotation: editorState.rotation,
      brightness: editorState.brightness,
      contrast: editorState.contrast,
      saturation: editorState.saturation,
      blur: editorState.blur,
      refractionIndex: editorState.refractionIndex,
      sparkleIntensity: editorState.sparkleIntensity,
      facetDepth: editorState.facetDepth,
      importsUsed: importsUsed,
    );
  }

  void _setEditorState(EditorState state, {int importDelta = 0}) {
    setState(() {
      editorState = state;
      importsUsed += importDelta;
    });
    widget.onStateChanged?.call(state);
    _saveState();
  }

  Future<void> _pickImage() async {
    if (importsUsed >= freeImportLimit) {
      _showPaywall();
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    final bytes = result?.files.single.bytes;
    if (bytes != null) {
      final nextState = editorState.copyWith(userImageBytes: bytes);
      _setEditorState(nextState, importDelta: 1);
    }
  }

  void _showPaywall() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaywallModal(
        onUpgrade: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Pro upgrade coming soon! Thank you for your interest.',
              ),
              backgroundColor: AppColors.gold,
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportIcon() async {
    if (editorState.userImageBytes == null) {
      _showMessage('Upload an icon before exporting.');
      return;
    }

    final boundaryContext = _previewBoundaryKey.currentContext;
    if (boundaryContext == null) {
      _showMessage('Preview is not ready yet.');
      return;
    }

    try {
      final boundary =
          boundaryContext.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _showMessage('Could not capture preview.');
        return;
      }

      final image = await boundary.toImage(pixelRatio: exportPixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showMessage('Could not generate image data.');
        return;
      }

      final bytes = byteData.buffer.asUint8List();
      final suggestedName =
          'iconic_export_${DateTime.now().millisecondsSinceEpoch}.png';
      final savePath = await saveExportedImage(suggestedName, bytes);

      if (kIsWeb) {
        _showMessage('Icon downloaded.');
      } else if (savePath.isNotEmpty) {
        _showMessage('Icon exported to $savePath');
      } else {
        _showMessage('Export cancelled.');
      }
    } catch (error, stackTrace) {
      debugPrint('Export failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage('Export failed. Please try again.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return isMobile ? _buildMobileLayout() : _buildDesktopLayout();
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Container(
            width: 300,
            color: AppColors.panel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildControls(),
                  ),
                ),
                _buildExportButton(),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: RepaintBoundary(
                      key: _previewBoundaryKey,
                      child: PreviewCanvas(
                        state: editorState,
                        onPickImage: _pickImage,
                      ),
                    ),
                  ),
                ),
                _buildStatsBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: RepaintBoundary(
                        key: _previewBoundaryKey,
                        child: PreviewCanvas(
                          state: editorState,
                          onPickImage: _pickImage,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildControls(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.panel,
              child: _buildExportButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection('TRANSFORM'),
        _buildSlider(
          'Scale',
          editorState.scale,
          0,
          100,
          (value) => _setEditorState(editorState.copyWith(scale: value)),
          suffix: '%',
        ),
        _buildSlider(
          'Rotation',
          editorState.rotation,
          -180,
          180,
          (value) => _setEditorState(editorState.copyWith(rotation: value)),
          suffix: '°',
        ),
        const SizedBox(height: 32),
        _buildSection('ADJUSTMENTS'),
        _buildSlider(
          'Brightness',
          editorState.brightness,
          0,
          200,
          (value) => _setEditorState(editorState.copyWith(brightness: value)),
          suffix: '%',
        ),
        _buildSlider(
          'Contrast',
          editorState.contrast,
          0,
          200,
          (value) => _setEditorState(editorState.copyWith(contrast: value)),
          suffix: '%',
        ),
        _buildSlider(
          'Saturation',
          editorState.saturation,
          0,
          200,
          (value) => _setEditorState(editorState.copyWith(saturation: value)),
          suffix: '%',
        ),
        _buildSlider(
          'Blur',
          editorState.blur,
          0,
          20,
          (value) => _setEditorState(editorState.copyWith(blur: value)),
          suffix: 'px',
        ),
        const SizedBox(height: 32),
        _buildSection('DIAMOND PHYSICS'),
        _buildSlider(
          'Refraction',
          editorState.refractionIndex,
          1.0,
          3.0,
          (value) =>
              _setEditorState(editorState.copyWith(refractionIndex: value)),
          decimals: 2,
        ),
        _buildSlider(
          'Sparkle',
          editorState.sparkleIntensity,
          0,
          2.0,
          (value) =>
              _setEditorState(editorState.copyWith(sparkleIntensity: value)),
        ),
        _buildSlider(
          'Facet Depth',
          editorState.facetDepth,
          0,
          1.0,
          (value) => _setEditorState(editorState.copyWith(facetDepth: value)),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.panelBorder)),
      ),
      child: Row(
        children: [
          const Icon(Icons.diamond, color: AppColors.gold, size: 28),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IconStudio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'PRO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
              ),
            ),
            child: const Text(
              'Premium',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    String suffix = '',
    int decimals = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              Text(
                decimals > 0
                    ? '${value.toStringAsFixed(decimals)}$suffix'
                    : '${value.toInt()}$suffix',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(value: value, min: min, max: max, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.panelBorder)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _exportIcon,
              icon: const Icon(Icons.download, size: 18),
              label: const Text(
                'Export Icon',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (importsUsed > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$importsUsed/$freeImportLimit free imports used',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.panelBorder)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StatItem(label: 'Quality', value: 'Ultra HD'),
          SizedBox(width: 48),
          _StatItem(label: 'Format', value: 'PNG'),
          SizedBox(width: 48),
          _StatItem(label: 'Export', value: '3x Density'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
