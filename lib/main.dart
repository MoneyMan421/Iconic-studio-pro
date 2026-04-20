import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Constants / theme colours
// ---------------------------------------------------------------------------

class AppColors {
  static const Color background   = Color(0xFF0A0A0A);
  static const Color panel        = Color(0xFF1A1A1A);
  static const Color panelBorder  = Color(0xFF2A2A2A);
  static const Color gold         = Color(0xFFD4AF37);
  static const Color goldLight    = Color(0xFFF4E4BC);
  static const Color textPrimary  = Color(0xFFFFFFFF);
  static const Color textSecondary= Color(0xFF888888);
  static const Color uploadZone   = Color(0xFF111111);
}

// ---------------------------------------------------------------------------
// Editor state (immutable value object)
// ---------------------------------------------------------------------------

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
  final File?  userImage;

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
    File?   userImage,
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
    userImage:        userImage        ?? this.userImage,
  );
}

// ---------------------------------------------------------------------------
// Persistence helpers
// ---------------------------------------------------------------------------

const _kScale            = 'scale';
const _kRotation         = 'rotation';
const _kBrightness       = 'brightness';
const _kContrast         = 'contrast';
const _kSaturation       = 'saturation';
const _kBlur             = 'blur';
const _kRefractionIndex  = 'refractionIndex';
const _kSparkleIntensity = 'sparkleIntensity';
const _kFacetDepth       = 'facetDepth';
const _kIsPro            = 'isPro';
const _kImportsUsed      = 'importsUsed';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

void main() {
  // Global error handling — surfaces caught Flutter errors to logs and the
  // framework's default presentation handler.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
    debugPrintStack(stackTrace: details.stack);
  };

  runApp(const DiamondApp());
}

// ---------------------------------------------------------------------------
// DiamondApp — multi-route application root
// ---------------------------------------------------------------------------

class DiamondApp extends StatelessWidget {
  const DiamondApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iconic Studio Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0a0a0a),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00d4ff),
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/':            (context) => const HomePage(),
        '/marketplace': (context) => const MarketplacePage(),
        '/studio':      (context) => const StudioPage(),
        '/dashboard':   (context) => const DashboardPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/product/') ?? false) {
          final id = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (_) => ProductDetailPage(id: id),
          );
        }
        return null;
      },
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const NotFoundPage(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// IconStudioPro — legacy single-page shell kept for test compatibility
// ---------------------------------------------------------------------------

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
      home: const IconEditorPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Pages
// ---------------------------------------------------------------------------

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShaderBackground(
        shaderAsset: 'shaders/diamond_master.frag',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Iconic Studio Pro',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              _NavButton(
                label: 'Marketplace',
                onPressed: () => Navigator.pushNamed(context, '/marketplace'),
              ),
              _NavButton(
                label: 'Studio',
                onPressed: () => Navigator.pushNamed(context, '/studio'),
              ),
              _NavButton(
                label: 'Dashboard',
                onPressed: () => Navigator.pushNamed(context, '/dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final List<Map<String, dynamic>> _products = [
    {'id': 'diamond-01', 'name': 'Prismatic Diamond', 'price': 2.5},
    {'id': 'diamond-02', 'name': 'Neon Cutter',       'price': 1.8},
    {'id': 'diamond-03', 'name': 'Crystal Matrix',    'price': 3.2},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(
                Icons.diamond_outlined,
                color: Color(0xFF00d4ff),
              ),
              title:    Text(product['name'] as String),
              subtitle: Text('${product['price']} ETH'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pushNamed(
                context,
                '/product/${product['id']}',
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final String id;
  const ProductDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product $id')),
      body: Center(
        child: Hero(
          tag: 'product-$id',
          child: ShaderBackground(
            shaderAsset: 'shaders/diamond_master.frag',
            child: Container(
              width:  300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF00d4ff).withOpacity(0.3),
                ),
              ),
              child: const Center(
                child: Text(
                  'Live Preview',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// StudioPage — shader file editor
// ---------------------------------------------------------------------------

class StudioPage extends StatefulWidget {
  const StudioPage({super.key});

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  String? _shaderSource;
  bool    _isLoading = false;

  final GlobalKey _previewKey = GlobalKey();

  // -------------------------------------------------------------------------
  // Shader file operations
  // -------------------------------------------------------------------------

  Future<void> _pickShaderFile() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type:          FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file   = File(result.files.single.path!);
        final source = await file.readAsString();
        setState(() => _shaderSource = source);
      }
    } catch (error, stackTrace) {
      debugPrint('Shader load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack:     stackTrace,
          library:   'studio',
          context:   ErrorDescription('Shader file load failed'),
        ),
      );
      _showSnackBar('Load failed: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportPng() async {
    try {
      final boundary = _previewKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        _showSnackBar('Preview not ready');
        return;
      }

      final image    = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData == null) {
        throw StateError('Image encoding returned null');
      }

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Icon',
        fileName:    'icon_export.png',
      );

      if (result != null) {
        await File(result).writeAsBytes(byteData.buffer.asUint8List());
        _showSnackBar('Icon exported successfully');
      }
    } catch (error, stackTrace) {
      debugPrint('PNG export failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack:     stackTrace,
          library:   'studio',
          context:   ErrorDescription('Icon export failed'),
        ),
      );
      _showSnackBar('Export failed: $error');
    }
  }

  Future<void> _exportShader() async {
    try {
      if (_shaderSource == null) {
        _showSnackBar('No shader loaded');
        return;
      }

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Shader',
        fileName:    'diamond_master.frag',
      );

      if (result != null) {
        await File(result).writeAsString(_shaderSource!);
        _showSnackBar('Shader exported successfully');
      }
    } catch (error, stackTrace) {
      debugPrint('Shader export failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack:     stackTrace,
          library:   'studio',
          context:   ErrorDescription('Shader export failed'),
        ),
      );
      _showSnackBar('Shader export failed: $error');
    }
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio'),
        actions: [
          IconButton(
            icon:    const Icon(Icons.folder_open),
            tooltip: 'Load shader',
            onPressed: _isLoading ? null : _pickShaderFile,
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview area
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _previewKey,
                child: _shaderSource != null
                    ? ShaderBackground(
                        // The loaded shader path is shown in the source viewer;
                        // the background asset is the bundled default shader.
                        shaderAsset: 'shaders/diamond_master.frag',
                        child: Container(
                          width:  300,
                          height: 300,
                          alignment: Alignment.center,
                          child: const Text(
                            'Shader loaded',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                    : const Text(
                        'Load a shader file to preview',
                        style: TextStyle(color: Colors.white54),
                      ),
              ),
            ),
          ),
          // Shader source viewer
          if (_shaderSource != null)
            Container(
              height:  200,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color:  Color(0xFF1A1A1A),
                border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _shaderSource!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize:   12,
                    color:      Color(0xFF00d4ff),
                  ),
                ),
              ),
            ),
          // Action bar
          Container(
            padding:    const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickShaderFile,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.folder_open),
                    label: Text(_isLoading ? 'Loading…' : 'Load Shader'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shaderSource != null ? _exportPng : null,
                    icon:  const Icon(Icons.image),
                    label: const Text('Export PNG'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shaderSource != null ? _exportShader : null,
                    icon:  const Icon(Icons.code),
                    label: const Text('Export Shader'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DashboardPage
// ---------------------------------------------------------------------------

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(
        child: Text(
          'Dashboard',
          style: TextStyle(color: Colors.white54, fontSize: 24),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NotFoundPage
// ---------------------------------------------------------------------------

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white30),
            const SizedBox(height: 16),
            const Text(
              '404 – Page not found',
              style: TextStyle(color: Colors.white54, fontSize: 20),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/', (_) => false,
              ),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// IconEditorPage — full diamond-shader icon editor (formerly StudioPage)
// ---------------------------------------------------------------------------

class IconEditorPage extends StatefulWidget {
  const IconEditorPage({super.key});

  @override
  State<IconEditorPage> createState() => _IconEditorPageState();
}

class _IconEditorPageState extends State<IconEditorPage> with WidgetsBindingObserver {
  EditorState state          = const EditorState();
  int         importsUsed    = 0;
  bool        isPro          = false;
  bool        _isExporting   = false;

  static const int freeImportLimit = 2;
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  /// Key used to capture the preview canvas for export.
  final GlobalKey _previewKey = GlobalKey();

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPrefs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _savePrefs();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.inactive) {
      _savePrefs();
    }
  }

  // -------------------------------------------------------------------------
  // Persistence
  // -------------------------------------------------------------------------

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        isPro       = prefs.getBool(_kIsPro)       ?? false;
        importsUsed = prefs.getInt(_kImportsUsed)  ?? 0;
        state = EditorState(
          scale:            prefs.getDouble(_kScale)            ?? 50,
          rotation:         prefs.getDouble(_kRotation)         ?? 0,
          brightness:       prefs.getDouble(_kBrightness)       ?? 100,
          contrast:         prefs.getDouble(_kContrast)         ?? 100,
          saturation:       prefs.getDouble(_kSaturation)       ?? 100,
          blur:             prefs.getDouble(_kBlur)             ?? 0,
          refractionIndex:  prefs.getDouble(_kRefractionIndex)  ?? 2.42,
          sparkleIntensity: prefs.getDouble(_kSparkleIntensity) ?? 0.8,
          facetDepth:       prefs.getDouble(_kFacetDepth)       ?? 0.6,
        );
      });
    } catch (_) {
      // Non-fatal: keep default state if prefs cannot be read.
    }
  }

  Future<void> _savePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kIsPro,            isPro);
      await prefs.setInt(_kImportsUsed,       importsUsed);
      await prefs.setDouble(_kScale,            state.scale);
      await prefs.setDouble(_kRotation,         state.rotation);
      await prefs.setDouble(_kBrightness,       state.brightness);
      await prefs.setDouble(_kContrast,         state.contrast);
      await prefs.setDouble(_kSaturation,       state.saturation);
      await prefs.setDouble(_kBlur,             state.blur);
      await prefs.setDouble(_kRefractionIndex,  state.refractionIndex);
      await prefs.setDouble(_kSparkleIntensity, state.sparkleIntensity);
      await prefs.setDouble(_kFacetDepth,       state.facetDepth);
    } catch (_) {
      // Non-fatal.
    }
  }

  // -------------------------------------------------------------------------
  // Import
  // -------------------------------------------------------------------------

  Future<void> _pickImage() async {
    if (!isPro && importsUsed >= freeImportLimit) {
      _showPaywall();
      return;
    }

    PlatformFile? pickedFile;
    try {
      final result = await FilePicker.platform.pickFiles(
        type:          FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
        allowMultiple: false,
      );
      pickedFile = result?.files.single;
    } catch (error, stackTrace) {
      debugPrint('Error picking image file: $error');
      debugPrintStack(stackTrace: stackTrace);
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'studio',
          context: ErrorDescription('Image file picker failed'),
        ),
      );
      _showSnackBar('Could not open file picker: $error');
      return;
    }

    if (pickedFile == null || pickedFile.path == null) return;

    // Validate file size.
    final file = File(pickedFile.path!);
    final int fileSize;
    try {
      fileSize = await file.length();
    } catch (error, stackTrace) {
      debugPrint('Error reading selected image file: $error');
      debugPrintStack(stackTrace: stackTrace);
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'studio',
          context: ErrorDescription('Selected image file read failed'),
        ),
      );
      _showSnackBar('Cannot read file: $error');
      return;
    }

    if (fileSize > maxFileSizeBytes) {
      _showSnackBar('File is too large (${(fileSize / 1048576).toStringAsFixed(1)} MB). Maximum is 5 MB.');
      return;
    }

    setState(() {
      state = state.copyWith(userImage: file);
      importsUsed++;
    });
    _savePrefs();
  }

  // -------------------------------------------------------------------------
  // Export
  // -------------------------------------------------------------------------

  Future<void> _exportIcon() async {
    if (state.userImage == null) {
      _showSnackBar('Upload an image first.');
      return;
    }
    if (_isExporting) return;

    setState(() => _isExporting = true);
    try {
      final boundary = _previewKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _showSnackBar('Preview not ready for export.');
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData == null) {
        _showSnackBar('Export failed: could not encode image.');
        return;
      }

      final Directory exportDir = await _resolveExportDirectory();
      final String timestamp   = DateTime.now().millisecondsSinceEpoch.toString();
      final File   outputFile  = File('${exportDir.path}/iconic_export_$timestamp.png');
      await outputFile.writeAsBytes(byteData.buffer.asUint8List());

      _showSnackBar('Saved to ${outputFile.path}');
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
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<Directory> _resolveExportDirectory() async {
    try {
      final dir = await getDownloadsDirectory();
      if (dir != null) return dir;
    } catch (_) {}
    return getApplicationDocumentsDirectory();
  }

  // -------------------------------------------------------------------------
  // Paywall / upgrade
  // -------------------------------------------------------------------------

  void _showPaywall() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaywallModal(
        onUpgrade: () {
          Navigator.pop(context);
          _activatePro();
        },
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  void _activatePro() {
    setState(() => isPro = true);
    _savePrefs();
    _showSnackBar('Pro unlocked! Enjoy unlimited imports.');
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.panel,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ---- Left panel: controls ----------------------------------------
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
                        _buildSlider('Scale',    state.scale,    0,    100,  (v) => setState(() => state = state.copyWith(scale:    v)), suffix: '%'),
                        _buildSlider('Rotation', state.rotation, -180, 180,  (v) => setState(() => state = state.copyWith(rotation: v)), suffix: '°'),
                        const SizedBox(height: 32),
                        _buildSection('ADJUSTMENTS'),
                        _buildSlider('Brightness', state.brightness, 0,   200, (v) => setState(() => state = state.copyWith(brightness: v)), suffix: '%'),
                        _buildSlider('Contrast',   state.contrast,   0,   200, (v) => setState(() => state = state.copyWith(contrast:   v)), suffix: '%'),
                        _buildSlider('Saturation', state.saturation, 0,   200, (v) => setState(() => state = state.copyWith(saturation: v)), suffix: '%'),
                        _buildSlider('Blur',       state.blur,       0,   20,  (v) => setState(() => state = state.copyWith(blur:       v)), suffix: 'px'),
                        const SizedBox(height: 32),
                        _buildSection('DIAMOND PHYSICS'),
                        _buildSlider('Refraction',   state.refractionIndex,  1.0, 3.0, (v) => setState(() => state = state.copyWith(refractionIndex:  v)), decimals: 2),
                        _buildSlider('Sparkle',      state.sparkleIntensity, 0,   2.0, (v) => setState(() => state = state.copyWith(sparkleIntensity: v))),
                        _buildSlider('Facet Depth',  state.facetDepth,       0,   1.0, (v) => setState(() => state = state.copyWith(facetDepth:       v))),
                      ],
                    ),
                  ),
                ),
                _buildExportButton(),
              ],
            ),
          ),
          // ---- Right panel: preview + stats --------------------------------
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: PreviewCanvas(
                      state:      state,
                      previewKey: _previewKey,
                      onUpload:   _pickImage,
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

  // ---- Widget builders --------------------------------------------------------

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
            child: Text(
              isPro ? 'Pro' : 'Free',
              style: const TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600),
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
          color:       AppColors.textSecondary,
          fontSize:    11,
          fontWeight:  FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label, double value, double min, double max,
    ValueChanged<double> onChanged, {
    String suffix  = '',
    int    decimals = 0,
  }) {
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

  Widget _buildExportButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.panelBorder)),
      ),
      child: Column(
        children: [
          SizedBox(
            width:  double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportIcon,
              icon:  _isExporting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.download, size: 18),
              label: Text(
                _isExporting ? 'Exporting…' : 'Export Icon',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                disabledBackgroundColor: AppColors.gold.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (!isPro && importsUsed > 0) ...[
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
          _StatItem(label: 'Format',  value: 'PNG'),
          SizedBox(width: 48),
          _StatItem(label: 'FPS',     value: '120'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _StatItem
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
        Text(value,  style: const TextStyle(color: AppColors.textPrimary,   fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Preview canvas
// ---------------------------------------------------------------------------

class PreviewCanvas extends StatelessWidget {
  final EditorState state;
  final GlobalKey   previewKey;
  final VoidCallback onUpload;

  const PreviewCanvas({
    super.key,
    required this.state,
    required this.previewKey,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  380,
      height: 500,
      child: Column(
        children: [
          // Header label
          Container(
            padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:        AppColors.panel,
              borderRadius: BorderRadius.circular(8),
              border:       Border.all(color: AppColors.panelBorder),
            ),
            child: const Text('Preview Canvas', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
          const SizedBox(height: 16),
          // Canvas circle — wrapped in RepaintBoundary for export.
          RepaintBoundary(
            key: previewKey,
            child: Container(
              width:  300,
              height: 300,
              decoration: BoxDecoration(
                shape:    BoxShape.circle,
                border:   Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color:       AppColors.gold.withOpacity(0.1),
                    blurRadius:  40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(child: _buildCanvasContent()),
            ),
          ),
          const SizedBox(height: 24),
          // Upload drop-zone
          GestureDetector(
            onTap: onUpload,
            child: Container(
              width:  300,
              height: 100,
              decoration: BoxDecoration(
                color:        AppColors.uploadZone,
                borderRadius: BorderRadius.circular(16),
                border:       Border.all(color: AppColors.panelBorder),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:    const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.upload, color: AppColors.gold, size: 24),
                  ),
                  const SizedBox(height: 8),
                  const Text('Upload your icon',          style: TextStyle(color: AppColors.textPrimary,   fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('PNG or JPG (max. 5 MB)',    style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasContent() {
    if (state.userImage == null) {
      return _buildPlaceholder();
    }

    // Apply scale and rotation around the image, then run the diamond shader.
    final scaleFactor = state.scale / 100.0;
    final rotationRad = state.rotation * math.pi / 180.0;

    return Transform.rotate(
      angle: rotationRad,
      child: Transform.scale(
        scale: scaleFactor,
        child: ShaderBuilder(
          assetKey: 'shaders/diamond_master.frag',
          (context, shader, child) => AnimatedSampler(
            (image, size, canvas) {
              _configureShader(shader, size);
              shader.setImageSampler(0, image);
              canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
            },
            child: Image.file(
              state.userImage!,
              fit:    BoxFit.cover,
              width:  300,
              height: 300,
            ),
          ),
        ),
      ),
    );
  }

  void _configureShader(FragmentShader shader, Size size) {
    final double time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    shader.setFloat(0,  size.width);
    shader.setFloat(1,  size.height);
    shader.setFloat(2,  time);
    shader.setFloat(3,  state.refractionIndex);
    shader.setFloat(4,  state.sparkleIntensity);
    shader.setFloat(5,  state.facetDepth);
    shader.setFloat(6,  state.brightness       / 100.0);
    shader.setFloat(7,  state.contrast         / 100.0);
    shader.setFloat(8,  state.saturation       / 100.0);
    shader.setFloat(9,  state.blur             / 20.0);
    shader.setFloat(10, 0.3);   // uLightPosition.x  (upper-right light source)
    shader.setFloat(11, -0.5);  // uLightPosition.y  (negative = above in screen-space Y-down)
    shader.setFloat(12, 0.5);   // uLightPosition.z
    // Note: setImageSampler(0, image) is called by the AnimatedSampler callback.
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.panel,
      child: Center(
        child: CustomPaint(
          size:    const Size(120, 120),
          painter: DiamondPlaceholderPainter(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Diamond placeholder painter
// ---------------------------------------------------------------------------

class DiamondPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect   = Rect.fromCenter(center: center, width: size.width, height: size.height);

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin:  Alignment.topLeft,
        end:    Alignment.bottomRight,
        colors: [AppColors.goldLight, AppColors.gold, Color(0xFF8B6914)],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx,                    center.dy - size.height * 0.4)
      ..lineTo(center.dx + size.width * 0.4, center.dy)
      ..lineTo(center.dx,                    center.dy + size.height * 0.4)
      ..lineTo(center.dx - size.width * 0.4, center.dy)
      ..close();

    canvas.drawPath(path, fillPaint);

    final linePaint = Paint()
      ..color       = Colors.white.withOpacity(0.3)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 1;

    final top    = Offset(center.dx,                    center.dy - size.height * 0.4);
    final right  = Offset(center.dx + size.width * 0.4, center.dy);
    final bottom = Offset(center.dx,                    center.dy + size.height * 0.4);
    final left   = Offset(center.dx - size.width * 0.4, center.dy);

    canvas.drawLine(top,    center, linePaint);
    canvas.drawLine(right,  center, linePaint);
    canvas.drawLine(bottom, center, linePaint);
    canvas.drawLine(left,   center, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Paywall modal
// ---------------------------------------------------------------------------

class PaywallModal extends StatelessWidget {
  final VoidCallback onUpgrade;
  final VoidCallback onDismiss;

  const PaywallModal({
    super.key,
    required this.onUpgrade,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width:   400,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.diamond, color: AppColors.gold, size: 48),
            const SizedBox(height: 16),
            const Text('Unlock Pro',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              "You've used your 2 free imports. Upgrade to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            _buildTier('Pro Monthly',  '\$4.99/mo', ['Unlimited imports', 'All shaders', 'Cloud sync']),
            const SizedBox(height: 12),
            _buildTier('Pro Lifetime', '\$49.99',   ['Everything in Pro', 'Pay once, keep forever'], isPopular: true),
            const SizedBox(height: 24),
            SizedBox(
              width:  double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Upgrade Now',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onDismiss,
              child: const Text('Maybe later',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTier(String name, String price, List<String> features, {bool isPopular = false}) {
    return Container(
      padding:    const EdgeInsets.all(16),
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
              Text(name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              if (isPopular)
                Container(
                  padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

// ---------------------------------------------------------------------------
// ShaderBackground — decorative gradient background referencing the shader asset
// ---------------------------------------------------------------------------

class ShaderBackground extends StatelessWidget {
  // TODO(dev): Replace gradient with a live FragmentShader render once the
  // shader pipeline supports backgrounds without an image sampler input.
  final String shaderAsset;
  final Widget child;

  const ShaderBackground({
    super.key,
    required this.shaderAsset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: [Color(0xFF0a0a0a), Color(0xFF0d1b2a), Color(0xFF0a0a0a)],
        ),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// _NavButton — styled navigation button used on HomePage
// ---------------------------------------------------------------------------

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _NavButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width:  220,
        height: 48,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF00d4ff), width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(label, style: const TextStyle(fontSize: 15)),
        ),
      ),
    );
  }
}
