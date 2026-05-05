import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:file_picker/file_picker.dart';

import 'app_colors.dart';
import 'auth_screen.dart';
import 'editor_storage.dart';
import 'export_helper.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const int    freeImportLimit  = 2;
const double exportPixelRatio = 3.0;

// ─── EditorState ─────────────────────────────────────────────────────────────

class EditorState {
  const EditorState({
    this.scale            = 1.0,
    this.rotation         = 0.0,
    this.brightness       = 1.0,
    this.contrast         = 1.0,
    this.saturation       = 1.0,
    this.blur             = 0.0,
    this.refractionIndex  = 2.42,
    this.sparkleIntensity = 1.0,
    this.facetDepth       = 1.0,
    this.userImageBytes,
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
  final Uint8List? userImageBytes;

  EditorState copyWith({
    double?    scale,
    double?    rotation,
    double?    brightness,
    double?    contrast,
    double?    saturation,
    double?    blur,
    double?    refractionIndex,
    double?    sparkleIntensity,
    double?    facetDepth,
    Uint8List? userImageBytes,
    bool       clearImage = false,
  }) {
    return EditorState(
      scale:            scale            ?? this.scale,
      rotation:         rotation         ?? this.rotation,
      brightness:       brightness       ?? this.brightness,
      contrast:         contrast         ?? this.contrast,
      saturation:       saturation       ?? this.saturation,
      blur:             blur             ?? this.blur,
      refractionIndex:  refractionIndex  ?? this.refractionIndex,
      sparkleIntensity: sparkleIntensity ?? this.sparkleIntensity,
      facetDepth:       facetDepth       ?? this.facetDepth,
      userImageBytes:   clearImage ? null : (userImageBytes ?? this.userImageBytes),
    );
  }
}

// ─── App root ────────────────────────────────────────────────────────────────

class IconStudioPro extends StatelessWidget {
  const IconStudioPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iconic Studio Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary:   AppColors.gold,
          secondary: AppColors.goldLight,
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor:   AppColors.gold,
          thumbColor:         AppColors.gold,
          overlayColor:       AppColors.gold.withValues(alpha: 0.2),
          inactiveTrackColor: AppColors.panelBorder,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.panel,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
      ),
      home: const AuthGate(child: StudioPage()),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IconStudioPro());
}

// ─── StudioPage ──────────────────────────────────────────────────────────────

class StudioPage extends StatefulWidget {
  const StudioPage({super.key});

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> with SingleTickerProviderStateMixin {
  // Editor state
  EditorState _state     = const EditorState();
  int         _importsUsed = 0;
  bool        _loading   = true;

  // FPS tracking
  late final Ticker _fpsTicker;
  double _fps          = 0;
  int    _frameCount   = 0;
  double _fpsElapsed   = 0;

  // Export key
  final GlobalKey _previewBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadState();

    // Real-time FPS counter — counts frames each second.
    _fpsTicker = createTicker((elapsed) {
      final dt = elapsed.inMicroseconds / 1e6;
      _fpsElapsed += dt;
      _frameCount++;
      if (_fpsElapsed >= 1.0) {
        if (mounted) {
          setState(() {
            _fps = _frameCount / _fpsElapsed;
          });
        }
        _frameCount = 0;
        _fpsElapsed = 0;
      }
    })..start();
  }

  @override
  void dispose() {
    _fpsTicker.dispose();
    super.dispose();
  }

  // ── Persistence ────────────────────────────────────────────────────────

  Future<void> _loadState() async {
    final data = await EditorStorage.load();
    if (!mounted) return;
    setState(() {
      _state = EditorState(
        scale:            data['scale']            as double,
        rotation:         data['rotation']         as double,
        brightness:       data['brightness']       as double,
        contrast:         data['contrast']         as double,
        saturation:       data['saturation']       as double,
        blur:             data['blur']             as double,
        refractionIndex:  data['refractionIndex']  as double,
        sparkleIntensity: data['sparkleIntensity'] as double,
        facetDepth:       data['facetDepth']       as double,
      );
      _importsUsed = data['importsUsed'] as int;
      _loading = false;
    });
  }

  Future<void> _saveState() async {
    await EditorStorage.save(
      scale:            _state.scale,
      rotation:         _state.rotation,
      brightness:       _state.brightness,
      contrast:         _state.contrast,
      saturation:       _state.saturation,
      blur:             _state.blur,
      refractionIndex:  _state.refractionIndex,
      sparkleIntensity: _state.sparkleIntensity,
      facetDepth:       _state.facetDepth,
      importsUsed:      _importsUsed,
    );
  }

  // ── Image import ───────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    if (_importsUsed >= freeImportLimit) {
      _showPaywall();
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    setState(() {
      _state = _state.copyWith(userImageBytes: result.files.single.bytes);
      _importsUsed++;
    });
    await _saveState();
  }

  // ── Export ─────────────────────────────────────────────────────────────

  Future<void> _exportImage() async {
    try {
      final boundary = _previewBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: exportPixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      await exportImage(byteData.buffer.asUint8List(), 'iconic_studio_export.png');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Icon exported successfully!'),
            backgroundColor: AppColors.panel,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Paywall ────────────────────────────────────────────────────────────

  void _showPaywall() {
    showDialog<void>(
      context: context,
      builder: (_) => const PaywallModal(),
    );
  }

  // ── State helpers ──────────────────────────────────────────────────────

  void _update(EditorState next) {
    setState(() => _state = next);
  }

  // ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatsBar(),
          Expanded(
            child: Row(
              children: [
                // ── Preview ──────────────────────────────────────────
                Expanded(
                  flex: 3,
                  child: RepaintBoundary(
                    key: _previewBoundaryKey,
                    child: PreviewCanvas(state: _state),
                  ),
                ),
                // ── Controls ──────────────────────────────────────────
                SizedBox(
                  width: 280,
                  child: _buildControlPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Iconic Studio Pro',
        style: TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.4,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.file_upload_outlined, color: AppColors.gold),
          tooltip: 'Import Image',
          onPressed: _pickImage,
        ),
        IconButton(
          icon: const Icon(Icons.download_outlined, color: AppColors.gold),
          tooltip: 'Export PNG',
          onPressed: _exportImage,
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.textSecondary),
          tooltip: 'Sign Out',
          onPressed: () async {
            final auth = AuthState();
            await auth.load();
            await auth.logout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const AuthGate(child: StudioPage())),
                (_) => false,
              );
            }
          },
        ),
      ],
    );
  }

  // ── Stats bar ──────────────────────────────────────────────────────────

  Widget _buildStatsBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      color: AppColors.panel,
      child: Row(
        children: [
          _StatItem(label: 'FPS',     value: _fps.toStringAsFixed(0)),
          const SizedBox(width: 24),
          _StatItem(label: 'IMPORTS', value: '$_importsUsed / $freeImportLimit'),
          const SizedBox(width: 24),
          _StatItem(label: 'SCALE',   value: '${(_state.scale * 100).toStringAsFixed(0)}%'),
          const SizedBox(width: 24),
          _StatItem(label: 'ROTATE',  value: '${(_state.rotation * 180 / math.pi).toStringAsFixed(1)}°'),
          const Spacer(),
          if (_state.userImageBytes != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: const Text(
                '● LIVE',
                style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  // ── Control panel ──────────────────────────────────────────────────────

  Widget _buildControlPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(left: BorderSide(color: AppColors.panelBorder)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('TRANSFORM', [
            _buildSlider('Scale',    _state.scale,            0.5, 3.0,
                (v) => _update(_state.copyWith(scale: v))),
            _buildSlider('Rotation', _state.rotation,         -math.pi, math.pi,
                (v) => _update(_state.copyWith(rotation: v))),
          ]),
          _buildSection('IMAGE', [
            _buildSlider('Brightness', _state.brightness,     0.2, 3.0,
                (v) => _update(_state.copyWith(brightness: v))),
            _buildSlider('Contrast',   _state.contrast,       0.2, 3.0,
                (v) => _update(_state.copyWith(contrast: v))),
            _buildSlider('Saturation', _state.saturation,     0.0, 3.0,
                (v) => _update(_state.copyWith(saturation: v))),
            _buildSlider('Blur',       _state.blur,           0.0, 1.0,
                (v) => _update(_state.copyWith(blur: v))),
          ]),
          _buildSection('DIAMOND', [
            _buildSlider('Refraction',  _state.refractionIndex,  1.0, 4.0,
                (v) => _update(_state.copyWith(refractionIndex: v))),
            _buildSlider('Sparkle',     _state.sparkleIntensity, 0.0, 3.0,
                (v) => _update(_state.copyWith(sparkleIntensity: v))),
            _buildSlider('Facet Depth', _state.facetDepth,       0.0, 3.0,
                (v) => _update(_state.copyWith(facetDepth: v))),
          ]),
          const SizedBox(height: 16),
          _buildGoldButton(
            icon: Icons.file_upload_outlined,
            label: 'Import Image  ($_importsUsed/$freeImportLimit)',
            onPressed: _pickImage,
          ),
          const SizedBox(height: 8),
          _buildGoldButton(
            icon: Icons.download_outlined,
            label: 'Export PNG',
            onPressed: _exportImage,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            label: const Text('Reset', style: TextStyle(color: AppColors.textSecondary)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.panelBorder),
            ),
            onPressed: () {
              setState(() => _state = EditorState(userImageBytes: _state.userImageBytes));
              _saveState();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: (v) {
              onChanged(v);
              _saveState();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoldButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: AppColors.background),
      label: Text(label, style: const TextStyle(color: AppColors.background)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        minimumSize: const Size(double.infinity, 44),
      ),
      onPressed: onPressed,
    );
  }
}

// ─── PreviewCanvas ────────────────────────────────────────────────────────────

class PreviewCanvas extends StatefulWidget {
  const PreviewCanvas({super.key, required this.state});
  final EditorState state;

  @override
  State<PreviewCanvas> createState() => _PreviewCanvasState();
}

class _PreviewCanvasState extends State<PreviewCanvas>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _elapsedSeconds = 0;
  Duration _lastElapsed  = Duration.zero;

  ui.Image? _image;
  bool _imageLoading = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _decodeImage();
  }

  void _onTick(Duration elapsed) {
    final dt = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    setState(() {
      _elapsedSeconds += dt.inMicroseconds / 1e6;
    });
  }

  @override
  void didUpdateWidget(PreviewCanvas old) {
    super.didUpdateWidget(old);
    if (old.state.userImageBytes != widget.state.userImageBytes) {
      _decodeImage();
    }
  }

  Future<void> _decodeImage() async {
    final bytes = widget.state.userImageBytes;
    if (bytes == null) {
      setState(() => _image = null);
      return;
    }
    if (_imageLoading) return;
    _imageLoading = true;
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) setState(() => _image = frame.image);
    _imageLoading = false;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;

    if (_image == null) {
      return _UploadZone(onTap: () {});
    }

    return ShaderBuilder(
      assetKey: 'shaders/diamond_master.frag',
      (context, shader, child) {
        return AnimatedSampler(
          (image, size, canvas) {
            shader
              ..setFloat(0, size.width)
              ..setFloat(1, size.height)
              ..setFloat(2, _elapsedSeconds)
              ..setFloat(3, s.refractionIndex)
              ..setFloat(4, s.sparkleIntensity)
              ..setFloat(5, s.facetDepth)
              ..setFloat(6, s.brightness)
              ..setFloat(7, s.contrast)
              ..setFloat(8, s.saturation)
              ..setFloat(9, s.blur)
              // uLightPosition (vec3 → 3 floats)
              ..setFloat(10, 0.3)
              ..setFloat(11, 0.3)
              ..setFloat(12, 1.0)
              ..setFloat(13, s.rotation)
              ..setFloat(14, s.scale)
              ..setImageSampler(0, image);

            final paint = Paint()..shader = shader;
            canvas.drawRect(Offset.zero & size, paint);
          },
          child: SizedBox.expand(
            child: Image(
              image: MemoryImage(widget.state.userImageBytes!),
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

// ─── Upload zone ──────────────────────────────────────────────────────────────

class _UploadZone extends StatelessWidget {
  const _UploadZone({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.uploadZone,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 72,
                color: AppColors.gold.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap "Import Image" to begin',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Supports PNG · JPG · WEBP',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat chip ────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                letterSpacing: 1.5)),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ─── Paywall modal ────────────────────────────────────────────────────────────

class PaywallModal extends StatelessWidget {
  const PaywallModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.diamond, color: AppColors.gold, size: 52),
            const SizedBox(height: 16),
            const Text(
              'Go Pro',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You've used your $freeImportLimit free imports.\n"
              'Upgrade for unlimited imports and\nexclusive diamond shader presets.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            // ── Pro Monthly ───────────────────────────────────────────
            _PaywallTier(
              label: 'Pro Monthly',
              price: r'$2.99 / month',
              onPressed: () => _handleUpgrade(context, 'monthly'),
            ),
            const SizedBox(height: 8),
            // ── Pro Lifetime ──────────────────────────────────────────
            _PaywallTier(
              label: 'Pro Lifetime',
              price: r'$14.99 once',
              highlighted: true,
              onPressed: () => _handleUpgrade(context, 'lifetime'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe later',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleUpgrade(BuildContext context, String tier) {
    // TODO: integrate payment SDK (RevenueCat / Stripe).
    // Currently shows a coming-soon message.
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('💎 $tier purchase coming soon — stay tuned!'),
        backgroundColor: AppColors.panel,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _PaywallTier extends StatelessWidget {
  const _PaywallTier({
    required this.label,
    required this.price,
    required this.onPressed,
    this.highlighted = false,
  });

  final String   label;
  final String   price;
  final VoidCallback onPressed;
  final bool     highlighted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              highlighted ? AppColors.gold : AppColors.panelBorder,
          foregroundColor:
              highlighted ? AppColors.background : AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: highlighted
                ? BorderSide.none
                : const BorderSide(color: AppColors.gold),
          ),
        ),
        onPressed: onPressed,
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(price, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
