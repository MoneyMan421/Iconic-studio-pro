import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:file_picker/file_picker.dart';

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
          overlayColor: AppColors.gold.withOpacity(0.2),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        ),
      ),
      home: const StudioPage(),
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
  final GlobalKey _previewKey = GlobalKey();

  Future<void> _pickImage() async {
    if (importsUsed >= freeImportLimit) {
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
      builder: (_) => PaywallModal(onUpgrade: () => Navigator.pop(context)),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _exportPng() async {
    try {
      final boundary = _previewKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        _showSnackBar('Preview not ready');
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw StateError('Image encoding returned null');
      }

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Icon',
        fileName: 'icon_export.png',
      );

      if (result != null) {
        await File(result).writeAsBytes(byteData.buffer.asUint8List());
        _showSnackBar('Icon exported successfully');
      }
    } catch (error, stackTrace) {
      debugPrint('Export failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'studio',
          context: ErrorDescription('Icon export failed'),
        ),
      );
      _showSnackBar('Export failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Column(
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
                    ),
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
                      key: _previewKey,
                      child: PreviewCanvas(state: state),
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
              color: AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
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
                onPressed: _exportPng,
                icon: const Icon(Icons.download, size: 18),
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
            Text(
              '$importsUsed/$freeImportLimit free imports used',
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 11),
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
          _StatItem(label: 'Format', value: 'Vector'),
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
class PreviewCanvas extends StatelessWidget {
  final EditorState state;
  const PreviewCanvas({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: const Text('Preview Canvas', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
          const SizedBox(height: 16),
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: state.userImage != null
                ? ShaderBuilder(
                    assetKey: 'shaders/diamond_master.frag',
                    (context, shader, child) => AnimatedSampler(
                      (image, size, canvas) {
                        _configureShader(shader, size);
                        shader.setImageSampler(0, image);
                        canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
                      },
                      child: Image.file(state.userImage!, fit: BoxFit.cover, width: 300, height: 300),
                    ),
                  )
                : _buildPlaceholder(),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => (context.findAncestorStateOfType<_StudioPageState>())?._pickImage(),
            child: Container(
              width: 300,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.uploadZone,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.panelBorder, style: BorderStyle.solid),
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
                  const Text('Upload your icon', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('PNG, SVG, or JPG (max. 5MB)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _configureShader(FragmentShader shader, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, state.refractionIndex);
    shader.setFloat(4, state.sparkleIntensity);
    shader.setFloat(5, state.facetDepth);
    shader.setFloat(6, state.brightness / 100);
    shader.setFloat(7, state.contrast / 100);
    shader.setFloat(8, state.saturation / 100);
    shader.setFloat(9, state.blur / 20);
    shader.setFloat(10, 0.3);
    shader.setFloat(11, -0.5);
    shader.setFloat(12, 0.5);
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.panel,
      child: Center(
        child: CustomPaint(
          size: const Size(120, 120),
          painter: DiamondPlaceholderPainter(),
        ),
      ),
    );
  }
}

class DiamondPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.goldLight, AppColors.gold, Color(0xFF8B6914)],
      ).createShader(Rect.fromCenter(center: center, width: size.width, height: size.height))
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(center.dx, center.dy - size.height * 0.4)
      ..lineTo(center.dx + size.width * 0.4, center.dy)
      ..lineTo(center.dx, center.dy + size.height * 0.4)
      ..lineTo(center.dx - size.width * 0.4, center.dy)
      ..close();
    
    canvas.drawPath(path, paint);
    
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawLine(Offset(center.dx, center.dy - size.height * 0.4), center, linePaint);
    canvas.drawLine(Offset(center.dx + size.width * 0.4, center.dy), center, linePaint);
    canvas.drawLine(Offset(center.dx, center.dy + size.height * 0.4), center, linePaint);
    canvas.drawLine(Offset(center.dx - size.width * 0.4, center.dy), center, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
            const Text('Unlock Pro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('You\'ve used your 2 free imports. Upgrade to continue.', 
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            _buildTier('Pro Monthly', '\$4.99/mo', ['Unlimited imports', 'All shaders', 'Cloud sync']),
            const SizedBox(height: 12),
            _buildTier('Pro Lifetime', '\$49.99', ['Everything in Pro', 'Pay once, keep forever'], isPopular: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Upgrade Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
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
        color: isPopular ? AppColors.gold.withOpacity(0.1) : AppColors.uploadZone,
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
