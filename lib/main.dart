import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'auth_screen.dart';
import 'billing_service.dart';

class AppColors {
  static const Color background = Color(0xFF0A0A0A);
  static const Color panel = Color(0xFF1A1A1A);
  static const Color panelBorder = Color(0xFF2A2A2A);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF4E4BC);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF888888);
  static const Color uploadZone = Color(0xFF111111);
}

class EditorState {
  double scale;
  double rotation;
  double brightness;
  double contrast;
  double saturation;
  double blur;
  double refractionIndex;
  double sparkleIntensity;
  double facetDepth;
  File? userImage;

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
    this.userImage,
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
    File? userImage,
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
    userImage: userImage ?? this.userImage,
  );
}
void main() => runApp(const IconStudioPro());

class IconStudioPro extends StatelessWidget {
  const IconStudioPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.gold,
          inactiveTrackColor: AppColors.panelBorder,
          thumbColor: AppColors.gold,
          overlayColor: AppColors.gold.withValues(alpha: 0.2),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        ),
      ),
      home: const AuthGate(child: StudioPage()),
    );
  }
}

class StudioPage extends StatefulWidget {
  const StudioPage({super.key});

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  EditorState state = EditorState();
  int importsUsed = 0;
  static const int freeImportLimit = 2;
  static const double exportPixelRatio = 3.0;
  static final RegExp _pngExtensionPattern = RegExp(r'\.png$', caseSensitive: false);
  final GlobalKey _previewBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    BillingService.instance.init();
    BillingService.instance.isPro.addListener(_onProStatusChanged);
  }

  @override
  void dispose() {
    BillingService.instance.isPro.removeListener(_onProStatusChanged);
    super.dispose();
  }

  void _onProStatusChanged() => setState(() {});

  Future<void> _pickImage() async {
    if (!BillingService.instance.isPro.value &&
        importsUsed >= freeImportLimit) {
      _showPaywall();
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        state = state.copyWith(userImage: File(result.files.single.path!));
        importsUsed++;
      });
    }
  }

  void _showPaywall() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PaywallModal(),
    );
  }

  Future<void> _exportIcon() async {
    if (state.userImage == null) {
      _showMessage('Upload an icon before exporting.');
      return;
    }

    final boundaryContext = _previewBoundaryKey.currentContext;
    if (boundaryContext == null) {
      _showMessage('Preview is not ready yet.');
      return;
    }

    try {
      final boundary = boundaryContext.findRenderObject() as RenderRepaintBoundary?;
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

      String? savePath;

      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile: save to the downloads / documents directory
        Directory? dir;
        if (Platform.isAndroid) {
          try {
            dir = await getExternalStorageDirectory();
          } catch (_) {
            dir = null;
          }
          dir ??= await getApplicationDocumentsDirectory();
        } else {
          dir = await getApplicationDocumentsDirectory();
        }
        savePath = '${dir.path}/iconic_export_${DateTime.now().millisecondsSinceEpoch}.png';
      } else {
        // Desktop/web: show native save dialog
        final selectedPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save exported icon',
          fileName: 'iconic_export.png',
          type: FileType.custom,
          allowedExtensions: ['png'],
        );
        if (selectedPath == null) return;
        final hasPngExtension = _pngExtensionPattern.hasMatch(selectedPath);
        savePath = hasPngExtension ? selectedPath : '$selectedPath.png';
      }

      await File(savePath).writeAsBytes(byteData.buffer.asUint8List());
      _showMessage('Icon exported to $savePath');
    } catch (error, stackTrace) {
      debugPrint('Export failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage('Export failed. Please try again.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                      child: PreviewCanvas(state: state, onPickImage: _pickImage),
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
                        child: PreviewCanvas(state: state, onPickImage: _pickImage),
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
        _buildSlider('Scale', state.scale, 0, 100, (v) => setState(() => state = state.copyWith(scale: v)), suffix: '%'),
        _buildSlider('Rotation', state.rotation, -180, 180, (v) => setState(() => state = state.copyWith(rotation: v)), suffix: '°'),
        const SizedBox(height: 32),
        _buildSection('ADJUSTMENTS'),
        _buildSlider('Brightness', state.brightness, 0, 200, (v) => setState(() => state = state.copyWith(brightness: v)), suffix: '%'),
        _buildSlider('Contrast', state.contrast, 0, 200, (v) => setState(() => state = state.copyWith(contrast: v)), suffix: '%'),
        _buildSlider('Saturation', state.saturation, 0, 200, (v) => setState(() => state = state.copyWith(saturation: v)), suffix: '%'),
        _buildSlider('Blur', state.blur, 0, 20, (v) => setState(() => state = state.copyWith(blur: v)), suffix: 'px'),
        const SizedBox(height: 32),
        _buildSection('DIAMOND PHYSICS'),
        _buildSlider('Refraction', state.refractionIndex, 1.0, 3.0, (v) => setState(() => state = state.copyWith(refractionIndex: v)), decimals: 2),
        _buildSlider('Sparkle', state.sparkleIntensity, 0, 2.0, (v) => setState(() => state = state.copyWith(sparkleIntensity: v))),
        _buildSlider('Facet Depth', state.facetDepth, 0, 1.0, (v) => setState(() => state = state.copyWith(facetDepth: v))),
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
              Text('IconStudio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text('PRO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 2)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: const Text('Premium', style: TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600)),
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

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged, {String suffix = '', int decimals = 0}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
              Text(
                decimals > 0 ? '${value.toStringAsFixed(decimals)}$suffix' : '${value.toInt()}$suffix',
                style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600),
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
              label: const Text('Export Icon', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (importsUsed > 0 && !BillingService.instance.isPro.value) ...[
            const SizedBox(height: 8),
            Text(
              '$importsUsed/$freeImportLimit free imports used',
              style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 11),
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
          _StatItem(label: 'FPS', value: '120'),
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
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
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

  // Light position orbits for sparkle
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
          // Label bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.panelBorder),
            ),
            child: const Text('Preview Canvas',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
          const SizedBox(height: 16),
          // Diamond preview circle
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
              child: s.userImage != null
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
                        child: Image.file(
                          s.userImage!,
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
          // Upload zone
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
                    child: const Icon(Icons.upload,
                        color: AppColors.gold, size: 24),
                  ),
                  const SizedBox(height: 8),
                  const Text('Upload your icon',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('PNG, SVG, or JPG (max. 5 MB)',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
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
        child: Icon(Icons.diamond,
            color: AppColors.gold.withValues(alpha: 0.3), size: 80),
      ),
    );
  }

  /// Sets every uniform the shader expects. Indices must match GLSL!
  void _configureShader(FragmentShader shader, Size size, EditorState s) {
    // Orbiting light position for sparkle
    final lightX = _lightOrbitRadius * math.cos(_elapsedSeconds * 0.4);
    final lightY = _lightOrbitRadius * math.sin(_elapsedSeconds * 0.4);

    shader.setFloat(0, size.width);                                        // uSize.x
    shader.setFloat(1, size.height);                                       // uSize.y
    shader.setFloat(2, _elapsedSeconds);                                   // uTime
    shader.setFloat(3, s.refractionIndex);                                 // uRefractionIndex
    shader.setFloat(4, s.sparkleIntensity);                                // uSparkleIntensity
    shader.setFloat(5, s.facetDepth);                                      // uFacetDepth
    shader.setFloat(6, s.brightness / 100.0);                             // uBrightness
    shader.setFloat(7, s.contrast / 100.0);                               // uContrast
    shader.setFloat(8, s.saturation / 100.0);                             // uSaturation
    shader.setFloat(9, s.blur);                                            // uBlur
    shader.setFloat(10, lightX);                                           // uLightPosition.x
    shader.setFloat(11, lightY);                                           // uLightPosition.y
    shader.setFloat(12, 1.0);                                              // uLightPosition.z
    shader.setFloat(13, s.rotation * (math.pi / 180.0));                  // uRotation (radians)
  }
}

class PaywallModal extends StatefulWidget {
  const PaywallModal({super.key});

  @override
  State<PaywallModal> createState() => _PaywallModalState();
}

class _PaywallModalState extends State<PaywallModal> {
  @override
  void initState() {
    super.initState();
    BillingService.instance.isPro.addListener(_onProChanged);
  }

  @override
  void dispose() {
    BillingService.instance.isPro.removeListener(_onProChanged);
    super.dispose();
  }

  void _onProChanged() {
    if (BillingService.instance.isPro.value && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final billing = BillingService.instance;
    return Dialog(
      backgroundColor: AppColors.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.diamond, color: AppColors.gold, size: 48),
            const SizedBox(height: 16),
            const Text('Unlock Pro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('You\'ve used your 2 free imports. Upgrade to continue.',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            _buildTier('Pro Monthly', '\$4.99/mo', ['Unlimited imports', 'All shaders', 'Cloud sync']),
            const SizedBox(height: 12),
            _buildTier('Pro Lifetime', '\$49.99', ['Everything in Pro', 'Pay once, keep forever'], isPopular: true),
            const SizedBox(height: 24),
            if (billing.products.isNotEmpty)
              ...billing.products.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => billing.buy(p),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('${p.title} — ${p.price}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ))
            else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.4),
                    disabledForegroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Loading plans…',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe Later',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTier(String name, String price, List<String> features, {bool isPopular = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPopular ? AppColors.gold.withValues(alpha: 0.1) : AppColors.uploadZone,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPopular ? AppColors.gold : AppColors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              if (isPopular) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(4)),
                child: const Text('POPULAR', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.check, color: AppColors.gold, size: 14),
                const SizedBox(width: 8),
                Text(f, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
