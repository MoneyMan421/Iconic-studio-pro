// F1 fix: 'package:flutter/services.dart' removed — was never used (dead import → lint warning).
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:file_picker/file_picker.dart';

// ---------------------------------------------------------------------------
// Shape enum — drives which clipper the preview canvas uses
// ---------------------------------------------------------------------------
enum IconShape { circle, chatBubble }

// ---------------------------------------------------------------------------
// App colour palette
// ---------------------------------------------------------------------------
class AppColors {
  static const Color background  = Color(0xFF0A0A0A);
  static const Color panel       = Color(0xFF1A1A1A);
  static const Color panelBorder = Color(0xFF2A2A2A);
  static const Color gold        = Color(0xFFD4AF37);
  static const Color goldLight   = Color(0xFFF4E4BC);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF888888);
  static const Color uploadZone  = Color(0xFF111111);
}

// ---------------------------------------------------------------------------
// Editor state — immutable via copyWith
// ---------------------------------------------------------------------------
class EditorState {
  final double    scale;
  final double    rotation;
  final double    brightness;
  final double    contrast;
  final double    saturation;
  final double    blur;
  final double    refractionIndex;
  final double    sparkleIntensity;
  final double    facetDepth;
  final double    dispersion;
  final double    bevelDepth;
  final int       stoneCount;
  final double    caratSize;
  final IconShape coreShape;
  final File?     userImage;

  const EditorState({
    this.scale            = 50,
    this.rotation         = 0,
    this.brightness       = 100,
    this.contrast         = 100,
    this.saturation       = 100,
    this.blur             = 0,
    this.refractionIndex  = 2.42,
    this.sparkleIntensity = 0.8,
    this.facetDepth       = 0.6,
    this.dispersion       = 0.02,
    this.bevelDepth       = 12.0,
    this.stoneCount       = 64,
    this.caratSize        = 0.05,
    this.coreShape        = IconShape.circle,
    this.userImage,
  });

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
    double?    dispersion,
    double?    bevelDepth,
    int?       stoneCount,
    double?    caratSize,
    IconShape? coreShape,
    File?      userImage,
  }) => EditorState(
    scale:            scale            ?? this.scale,
    rotation:         rotation         ?? this.rotation,
    brightness:       brightness       ?? this.brightness,
    contrast:         contrast         ?? this.contrast,
    saturation:       saturation       ?? this.saturation,
    blur:             blur             ?? this.blur,
    refractionIndex:  refractionIndex  ?? this.refractionIndex,
    sparkleIntensity: sparkleIntensity ?? this.sparkleIntensity,
    facetDepth:       facetDepth       ?? this.facetDepth,
    dispersion:       dispersion       ?? this.dispersion,
    bevelDepth:       bevelDepth       ?? this.bevelDepth,
    stoneCount:       stoneCount       ?? this.stoneCount,
    caratSize:        caratSize        ?? this.caratSize,
    coreShape:        coreShape        ?? this.coreShape,
    userImage:        userImage        ?? this.userImage,
  );

  // "elite-diamond-msg" preset from the JSON spec
  static const EditorState eliteDiamondMsg = EditorState(
    refractionIndex:  2.42,
    dispersion:       0.02,
    bevelDepth:       12.0,
    stoneCount:       64,
    caratSize:        0.05,
    coreShape:        IconShape.chatBubble,
    sparkleIntensity: 0.8,
    facetDepth:       0.6,
  );
}

// ---------------------------------------------------------------------------
// App entry point
// ---------------------------------------------------------------------------
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
          activeTrackColor:   AppColors.gold,
          inactiveTrackColor: AppColors.panelBorder,
          thumbColor:         AppColors.gold,
          overlayColor:       AppColors.gold.withOpacity(0.2),
          trackHeight:        4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        ),
      ),
      home: const StudioPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Studio page
// ---------------------------------------------------------------------------
class StudioPage extends StatefulWidget {
  const StudioPage({super.key});
  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> with TickerProviderStateMixin {
  EditorState state = const EditorState();
  int importsUsed = 0;

  static const int    freeImportLimit      = 2;
  static const double exportPixelRatio     = 3.0;
  static final RegExp _pngExtensionPattern =
      RegExp(r'\.png$', caseSensitive: false);

  final GlobalKey _previewBoundaryKey = GlobalKey();

  ui.FragmentShader? _shader;
  ui.Image?          _loadedImage;
  late final Ticker  _ticker;
  double             _elapsed = 0;

  // ---- Lifecycle --------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // F3 fix: asset key uses the .frag source path, not .frag.spv.
    // Flutter compiles the shader at build time; the runtime lookup key
    // stays the source path declared in pubspec.yaml.
    _loadShader();

    _ticker = createTicker((d) {
      setState(() => _elapsed = d.inMilliseconds / 1000.0);
    });

    // F2 fix: start the ticker via addPostFrameCallback so Flutter has
    // already laid out the first frame before we request continuous redraws.
    //
    // The buggy version assigned a closure to
    //   SchedulerBinding.instance.schedulingStrategy
    // whose typedef is:
    //   bool Function({required int priority, required SchedulerBinding scheduler})
    // The buggy closure forgot the `bool` return value → compile error.
    SchedulerBinding.instance.addPostFrameCallback((_) => _ticker.start());
  }

  @override
  void dispose() {
    _ticker.dispose();
    _shader?.dispose();
    _loadedImage?.dispose();
    super.dispose();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
          'shaders/diamond_master.frag'); // F3: .frag not .frag.spv
      if (!mounted) return;
      setState(() => _shader = program.fragmentShader());
    } catch (e) {
      debugPrint('Shader load error: $e');
    }
  }

  // ---- Image picking ----------------------------------------------------

  Future<void> _pickImage() async {
    if (importsUsed >= freeImportLimit) {
      _showPaywall();
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    setState(() {
      state = state.copyWith(userImage: File(path));
      importsUsed++;
    });
    _loadUserImage(path);
  }

  Future<void> _loadUserImage(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (!mounted) return;
      _loadedImage?.dispose();
      setState(() => _loadedImage = frame.image);
    } catch (e) {
      debugPrint('Image decode error: $e');
    }
  }

  // ---- Paywall ----------------------------------------------------------

  void _showPaywall() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaywallModal(onUpgrade: () => Navigator.pop(context)),
    );
  }

  // ---- Export -----------------------------------------------------------

  Future<void> _exportIcon() async {
    if (state.userImage == null) {
      _showMessage('Upload an icon before exporting.');
      return;
    }
    final ctx = _previewBoundaryKey.currentContext;
    if (ctx == null) {
      _showMessage('Preview is not ready yet.');
      return;
    }
    try {
      final boundary =
          ctx.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _showMessage('Could not capture preview.');
        return;
      }
      final image    = await boundary.toImage(pixelRatio: exportPixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showMessage('Could not generate image data.');
        return;
      }
      final selectedPath = await FilePicker.platform.saveFile(
        dialogTitle:       'Save exported icon',
        fileName:          'iconic_export.png',
        type:              FileType.custom,
        allowedExtensions: ['png'],
      );
      if (selectedPath == null) return;
      final normalizedPath = _pngExtensionPattern.hasMatch(selectedPath)
          ? selectedPath
          : '$selectedPath.png';
      await File(normalizedPath).writeAsBytes(byteData.buffer.asUint8List());
      _showMessage('Icon exported to $normalizedPath');
    } catch (error, stackTrace) {
      debugPrint('Export failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage('Export failed. Please try again.');
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---- Preset -----------------------------------------------------------

  void _applyEliteDiamondPreset() {
    setState(() {
      state = EditorState.eliteDiamondMsg.copyWith(
        userImage: state.userImage,
        brightness: state.brightness,
        contrast:   state.contrast,
        saturation: state.saturation,
      );
    });
  }

  // ---- Build ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // --- Left panel ---
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection('TRANSFORM'),
                        _buildSlider('Scale',    state.scale,    0, 100,  (v) => setState(() => state = state.copyWith(scale:    v)), suffix: '%'),
                        _buildSlider('Rotation', state.rotation, -180, 180, (v) => setState(() => state = state.copyWith(rotation: v)), suffix: '°'),
                        const SizedBox(height: 32),
                        _buildSection('ADJUSTMENTS'),
                        _buildSlider('Brightness', state.brightness, 0, 200, (v) => setState(() => state = state.copyWith(brightness: v)), suffix: '%'),
                        _buildSlider('Contrast',   state.contrast,   0, 200, (v) => setState(() => state = state.copyWith(contrast:   v)), suffix: '%'),
                        _buildSlider('Saturation', state.saturation, 0, 200, (v) => setState(() => state = state.copyWith(saturation: v)), suffix: '%'),
                        _buildSlider('Blur',       state.blur,       0, 20,  (v) => setState(() => state = state.copyWith(blur:       v)), suffix: 'px'),
                        const SizedBox(height: 32),
                        _buildSection('DIAMOND PHYSICS'),
                        _buildSlider('Refraction',  state.refractionIndex,  1.0, 3.0, (v) => setState(() => state = state.copyWith(refractionIndex:  v)), decimals: 2),
                        _buildSlider('Sparkle',     state.sparkleIntensity, 0,   2.0, (v) => setState(() => state = state.copyWith(sparkleIntensity: v))),
                        _buildSlider('Facet Depth', state.facetDepth,       0,   1.0, (v) => setState(() => state = state.copyWith(facetDepth:       v))),
                        _buildSlider('Dispersion',  state.dispersion,       0,   0.1, (v) => setState(() => state = state.copyWith(dispersion:       v)), decimals: 3),
                        const SizedBox(height: 32),
                        _buildSection('FRAME & STONES'),
                        _buildSlider('Bevel Depth',  state.bevelDepth,           0, 20,  (v) => setState(() => state = state.copyWith(bevelDepth:  v)), decimals: 1),
                        _buildSlider('Stone Count',  state.stoneCount.toDouble(), 0, 64,  (v) => setState(() => state = state.copyWith(stoneCount:  v.round()))),
                        _buildSlider('Carat Size',   state.caratSize,            0.01, 0.2, (v) => setState(() => state = state.copyWith(caratSize: v)), decimals: 2),
                        const SizedBox(height: 32),
                        _buildSection('PRESETS'),
                        _buildPresetButton(),
                        const SizedBox(height: 16),
                        _buildShapeToggle(),
                      ],
                    ),
                  ),
                ),
                _buildExportButton(),
              ],
            ),
          ),
          // --- Right: preview ---
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: RepaintBoundary(
                      key: _previewBoundaryKey,
                      child: PreviewCanvas(
                        state:       state,
                        shader:      _shader,
                        loadedImage: _loadedImage,
                        elapsed:     _elapsed,
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

  // ---- Sidebar helpers -------------------------------------------------

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
              Text('PRO',        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 2)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:        AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border:       Border.all(color: AppColors.gold.withOpacity(0.3)),
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
      child: Text(title, style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2,
      )),
    );
  }

  Widget _buildSlider(
    String label, double value, double min, double max,
    ValueChanged<double> onChanged, {String suffix = '', int decimals = 0}
  ) {
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
                decimals > 0
                    ? '${value.toStringAsFixed(decimals)}$suffix'
                    : '${value.toInt()}$suffix',
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

  Widget _buildPresetButton() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton.icon(
        onPressed: _applyEliteDiamondPreset,
        icon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.gold),
        label: const Text('Elite Diamond Msg', style: TextStyle(color: AppColors.gold, fontSize: 12)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.gold.withOpacity(0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildShapeToggle() {
    return Row(
      children: [
        const Text('Shape', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        const Spacer(),
        _ShapeChip(
          label: 'Circle',
          icon:  Icons.circle_outlined,
          selected: state.coreShape == IconShape.circle,
          onTap: () => setState(() => state = state.copyWith(coreShape: IconShape.circle)),
        ),
        const SizedBox(width: 8),
        _ShapeChip(
          label: 'Chat',
          icon:  Icons.chat_bubble_outline,
          selected: state.coreShape == IconShape.chatBubble,
          onTap: () => setState(() => state = state.copyWith(coreShape: IconShape.chatBubble)),
        ),
      ],
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
              icon:  const Icon(Icons.download, size: 18),
              label: const Text('Export Icon', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (importsUsed > 0) ...[
            const SizedBox(height: 8),
            Text('$importsUsed/$freeImportLimit free imports used',
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 11)),
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
          _StatItem(label: 'Format',  value: 'Vector'),
          SizedBox(width: 48),
          _StatItem(label: 'FPS',     value: '120'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small UI helpers
// ---------------------------------------------------------------------------

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

class _ShapeChip extends StatelessWidget {
  final String   label;
  final IconData icon;
  final bool     selected;
  final VoidCallback onTap;
  const _ShapeChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color:        selected ? AppColors.gold.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: selected ? AppColors.gold : AppColors.panelBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? AppColors.gold : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: selected ? AppColors.gold : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Preview canvas — wraps IconLayerPainter inside the correct shape clipper
// ---------------------------------------------------------------------------

class PreviewCanvas extends StatelessWidget {
  final EditorState      state;
  final ui.FragmentShader? shader;
  final ui.Image?          loadedImage;
  final double             elapsed;
  final VoidCallback       onPickImage;

  const PreviewCanvas({
    super.key,
    required this.state,
    required this.elapsed,
    required this.onPickImage,
    this.shader,
    this.loadedImage,
  });

  @override
  Widget build(BuildContext context) {
    const double canvasSize = 300;
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
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
          const SizedBox(height: 16),
          // Icon preview with glow
          Container(
            width: canvasSize, height: canvasSize,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: AppColors.gold.withOpacity(0.12), blurRadius: 40, spreadRadius: 10),
              ],
            ),
            child: _buildClippedIcon(canvasSize),
          ),
          const SizedBox(height: 24),
          // Upload zone
          GestureDetector(
            onTap: onPickImage,
            child: Container(
              width: canvasSize, height: 100,
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
                      color: AppColors.gold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.upload, color: AppColors.gold, size: 24),
                  ),
                  const SizedBox(height: 8),
                  const Text('Upload your icon',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('PNG, SVG, or JPG (max. 5 MB)',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClippedIcon(double size) {
    final painter = IconLayerPainter(
      state:       state,
      shader:      shader,
      userImage:   loadedImage,
      time:        elapsed,
    );

    final canvas = CustomPaint(
      size:    Size(size, size),
      painter: painter,
    );

    if (state.coreShape == IconShape.chatBubble) {
      return ClipPath(
        clipper: ChatBubbleClipper(),
        child: canvas,
      );
    }
    // Default: circle
    return ClipOval(child: canvas);
  }
}

// ---------------------------------------------------------------------------
// IconLayerPainter
//
// F4 fix: correct layer order is Bed → Frame → Pavé → Glyph.
//   Buggy order was Frame → Pavé → Bed → Glyph, which let the diamond bed
//   paint over the gold inner rim on every frame.
//
// F5 fix: _rng, _glintXFactors, _glintYFactors are static final — allocated
//   once at class load.  Buggy version created math.Random(42) + two Lists
//   inside paint() on every frame (~120 new objects/sec at 120 fps).
// ---------------------------------------------------------------------------

class IconLayerPainter extends CustomPainter {
  // F5 fix: static final — zero allocation per frame
  static final math.Random     _rng          = math.Random(42);
  static final List<double>    _glintXFactors = List.generate(16, (_) => _rng.nextDouble());
  static final List<double>    _glintYFactors = List.generate(16, (_) => _rng.nextDouble());

  final EditorState        state;
  final ui.FragmentShader? shader;
  final ui.Image?          userImage;
  final double             time;

  IconLayerPainter({
    required this.state,
    required this.time,
    this.shader,
    this.userImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // F4 fix: Bed → Frame → Pavé → Glyph
    _paintBed(canvas, size);
    _paintFrame(canvas, size);
    _paintPave(canvas, size);
    _paintGlyph(canvas, size);
  }

  // ---- Layer 1: Bed (user image + shader, or placeholder) ---------------

  void _paintBed(Canvas canvas, Size size) {
    final s   = shader;
    final img = userImage;
    if (s != null && img != null) {
      _configureShader(s, img, size);
      canvas.drawRect(Offset.zero & size, Paint()..shader = s);
    } else {
      _paintPlaceholderBed(canvas, size);
    }
  }

  void _configureShader(ui.FragmentShader s, ui.Image img, Size size) {
    s.setFloat(0,  size.width);
    s.setFloat(1,  size.height);
    s.setFloat(2,  time);
    s.setFloat(3,  state.refractionIndex);
    s.setFloat(4,  state.sparkleIntensity);
    s.setFloat(5,  state.facetDepth);
    s.setFloat(6,  state.brightness / 100);
    s.setFloat(7,  state.contrast   / 100);
    s.setFloat(8,  state.saturation / 100);
    s.setFloat(9,  state.blur       / 20);
    s.setFloat(10, 0.3);   // light x
    s.setFloat(11, -0.5);  // light y
    s.setFloat(12, 0.5);   // light z
    s.setFloat(13, state.dispersion);
    s.setFloat(14, state.bevelDepth);
    s.setFloat(15, state.stoneCount.toDouble());
    s.setFloat(16, state.caratSize);
    s.setImageSampler(0, img);
  }

  void _paintPlaceholderBed(Canvas canvas, Size size) {
    // Dark radial base
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF1E140A), AppColors.background],
        ).createShader(Offset.zero & size),
    );
    // Subtle gold shimmer overlay
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.goldLight.withOpacity(0.08), Colors.transparent,
                   AppColors.gold.withOpacity(0.06)],
        ).createShader(Offset.zero & size),
    );
    // Diamond facet lines
    _paintFacetLines(canvas, size);
    // Diamond glyph in centre
    _paintDiamondGlyph(canvas, size);
  }

  void _paintFacetLines(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r      = math.min(size.width, size.height) * 0.38;
    final paint  = Paint()
      ..color      = AppColors.gold.withOpacity(0.07)
      ..style      = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + time * 0.08;
      canvas.drawLine(center,
          center + Offset(math.cos(angle) * r, math.sin(angle) * r), paint);
    }
    canvas.drawCircle(center, r * 0.6,
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.goldLight.withOpacity(0.12), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: r * 0.6)));
  }

  void _paintDiamondGlyph(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final hw     = size.width * 0.22;
    final hh     = size.height * 0.22;
    final path   = Path()
      ..moveTo(center.dx,      center.dy - hh)
      ..lineTo(center.dx + hw, center.dy)
      ..lineTo(center.dx,      center.dy + hh)
      ..lineTo(center.dx - hw, center.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.goldLight, AppColors.gold, const Color(0xFF8B6914)],
        ).createShader(Rect.fromCenter(center: center, width: hw * 2, height: hh * 2))
        ..style = PaintingStyle.fill,
    );
    final linePaint = Paint()
      ..color      = Colors.white.withOpacity(0.2)
      ..style      = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(center.dx, center.dy - hh), center, linePaint);
    canvas.drawLine(Offset(center.dx + hw, center.dy), center, linePaint);
    canvas.drawLine(Offset(center.dx, center.dy + hh), center, linePaint);
    canvas.drawLine(Offset(center.dx - hw, center.dy), center, linePaint);
  }

  // ---- Layer 2: Frame (gold 24k bevel ring) ------------------------------

  void _paintFrame(Canvas canvas, Size size) {
    final center    = size.center(Offset.zero);
    final maxR      = math.min(size.width, size.height) / 2;
    final bevelNorm = (state.bevelDepth / 20.0).clamp(0.0, 1.0);
    final innerR    = maxR * (1.0 - bevelNorm * 0.20);
    final bandW     = maxR - innerR;
    final goldAngle = time * 0.7;

    for (int i = 0; i < 6; i++) {
      final fi      = i / 5.0;
      final r       = innerR + bandW * fi;
      final sheen   = (math.sin(goldAngle + fi * math.pi) + 1) / 2;
      final color   = Color.lerp(
        const Color(0xFF8B6914), const Color(0xFFF4E4BC), sheen)!
          .withOpacity((0.30 - fi * 0.24).clamp(0.0, 1.0));
      canvas.drawOval(
        Rect.fromCenter(center: center, width: r * 2, height: r * 2),
        Paint()
          ..color      = color
          ..style      = PaintingStyle.stroke
          ..strokeWidth = bandW / 6,
      );
    }
    // Hard outer rim
    canvas.drawOval(
      Rect.fromCenter(center: center, width: maxR * 2, height: maxR * 2),
      Paint()
        ..color      = AppColors.gold.withOpacity(0.55)
        ..style      = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  // ---- Layer 3: Pavé stones ----------------------------------------------

  void _paintPave(Canvas canvas, Size size) {
    final center    = size.center(Offset.zero);
    final maxR      = math.min(size.width, size.height) / 2;
    final bevelNorm = (state.bevelDepth / 20.0).clamp(0.0, 1.0);
    final innerR    = maxR * (1.0 - bevelNorm * 0.20);
    final ringR     = (maxR + innerR) / 2;
    final stoneR    = state.caratSize * 120;
    const goldenAngle = math.pi * (3 - math.sqrt(5));

    for (int i = 0; i < state.stoneCount; i++) {
      final fi      = i.toDouble();
      final angle   = fi * goldenAngle;
      final sc      = center + Offset(ringR * math.cos(angle), ringR * math.sin(angle));
      final shimmer = (math.sin(time * 3 + fi * 0.7) + 1) / 2;
      canvas.drawCircle(
        sc, stoneR,
        Paint()
          ..color = Color.lerp(const Color(0xFFB0C4DE), Colors.white, shimmer)!
              .withOpacity(0.65 + shimmer * 0.35),
      );
      if (shimmer > 0.75) {
        final gp  = Paint()
          ..color      = Colors.white.withOpacity((shimmer - 0.75) * 4)
          ..strokeWidth = 0.8
          ..style      = PaintingStyle.stroke;
        final arm = stoneR * 2.5;
        canvas.drawLine(sc - Offset(arm, 0), sc + Offset(arm, 0), gp);
        canvas.drawLine(sc - Offset(0, arm), sc + Offset(0, arm), gp);
      }
    }
  }

  // ---- Layer 4: Glyph (animated glint stars) ----------------------------

  void _paintGlyph(Canvas canvas, Size size) {
    // Uses F5's static precomputed factor arrays — no allocation here
    for (int i = 0; i < _glintXFactors.length; i++) {
      final x       = _glintXFactors[i] * size.width;
      final y       = _glintYFactors[i] * size.height;
      final shimmer = (math.sin(time * 2.1 + i * 1.7) + 1) / 2;
      if (shimmer < 0.6) continue;
      final opacity = ((shimmer - 0.6) * 2.5).clamp(0.0, 1.0);
      final gp      = Paint()
        ..color      = Colors.white.withOpacity(opacity * 0.9)
        ..strokeWidth = 1.0
        ..style      = PaintingStyle.stroke;
      final arm  = 3.0 + shimmer * 9;
      final dArm = arm * 0.6;
      canvas.drawLine(Offset(x - arm,  y),       Offset(x + arm,  y),       gp);
      canvas.drawLine(Offset(x,        y - arm),  Offset(x,        y + arm),  gp);
      canvas.drawLine(Offset(x - dArm, y - dArm), Offset(x + dArm, y + dArm), gp);
      canvas.drawLine(Offset(x - dArm, y + dArm), Offset(x + dArm, y - dArm), gp);
    }
  }

  @override
  bool shouldRepaint(IconLayerPainter old) =>
      old.state     != state     ||
      old.shader    != shader    ||
      old.userImage != userImage ||
      old.time      != time;
}

// ---------------------------------------------------------------------------
// Chat bubble clipper
// ---------------------------------------------------------------------------

class ChatBubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double r    = 18.0;
    const double tailH = 22.0;
    const double tailW = 28.0;
    const double tailX = 18.0;
    final double bodyH = size.height - tailH;

    return Path()
      ..moveTo(r, 0)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r),      radius: const Radius.circular(r))
      ..lineTo(size.width, bodyH - r)
      ..arcToPoint(Offset(size.width - r, bodyH), radius: const Radius.circular(r))
      ..lineTo(tailX + tailW, bodyH)
      ..lineTo(tailX + tailW / 2, size.height)   // tail tip
      ..lineTo(tailX, bodyH)
      ..lineTo(r, bodyH)
      ..arcToPoint(Offset(0, bodyH - r),       radius: const Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0),               radius: const Radius.circular(r))
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ---------------------------------------------------------------------------
// Paywall modal
// ---------------------------------------------------------------------------

class PaywallModal extends StatelessWidget {
  final VoidCallback onUpgrade;
  const PaywallModal({super.key, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
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
            const Text('Unlock Pro',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text("You've used your 2 free imports. Upgrade to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            _buildTier('Pro Monthly',  r'$4.99/mo', ['Unlimited imports', 'All shaders', 'Cloud sync']),
            const SizedBox(height: 12),
            _buildTier('Pro Lifetime', r'$49.99',   ['Everything in Pro', 'Pay once, keep forever'], isPopular: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold, foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Upgrade Now',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTier(String name, String price, List<String> features,
      {bool isPopular = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        isPopular ? AppColors.gold.withOpacity(0.1) : AppColors.uploadZone,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: isPopular ? AppColors.gold : AppColors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              if (isPopular) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(4)),
                child: const Text('POPULAR',
                    style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              const Icon(Icons.check, color: AppColors.gold, size: 14),
              const SizedBox(width: 8),
              Text(f, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          )),
        ],
      ),
    );
  }
}
