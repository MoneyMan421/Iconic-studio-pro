import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_colors.dart';
import 'firebase_service.dart';
import 'main.dart';

class PackEditorScreen extends StatefulWidget {
  final String packId;
  final Map<String, dynamic> packData;

  const PackEditorScreen({
    super.key,
    required this.packId,
    required this.packData,
  });

  @override
  State<PackEditorScreen> createState() => _PackEditorScreenState();
}

class _PackEditorScreenState extends State<PackEditorScreen> {
  bool _publishing = false;

  void _openIconEditor({String? iconId, Map<String, dynamic>? iconData}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IconEditorSheet(
          packId: widget.packId,
          iconId: iconId,
          existingData: iconData,
        ),
      ),
    );
  }

  Future<void> _publishPack() async {
    final priceCtrl = TextEditingController(text: '4.99');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Publish to Marketplace',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set a price for your pack. You keep 70%, we take 30%.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Price (USD)',
                labelStyle:
                    const TextStyle(color: AppColors.textSecondary),
                prefixText: '\$ ',
                prefixStyle: const TextStyle(color: AppColors.gold),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.panelBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
            ),
            child: const Text('Publish',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _publishing = true);
      try {
        final price = double.tryParse(priceCtrl.text) ?? 4.99;
        await FirebaseService.publishPack(
            packId: widget.packId, price: price);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pack published to marketplace! 🎉'),
              backgroundColor: AppColors.gold,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _publishing = false);
      }
    }
  }

  Future<void> _deleteIcon(String iconId) async {
    await FirebaseService.deleteIcon(widget.packId, iconId);
  }

  @override
  Widget build(BuildContext context) {
    final isPublic = widget.packData['isPublic'] ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.packData['name'] ?? 'Icon Pack',
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        actions: [
          if (!isPublic)
            TextButton.icon(
              onPressed: _publishing ? null : _publishPack,
              icon: _publishing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.gold))
                  : const Icon(Icons.rocket_launch,
                      color: AppColors.gold, size: 18),
              label: const Text('Publish',
                  style: TextStyle(
                      color: AppColors.gold, fontWeight: FontWeight.bold)),
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('LIVE',
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Pack stats bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.panel,
              border: Border(
                  bottom: BorderSide(color: AppColors.panelBorder)),
            ),
            child: Row(
              children: [
                _statChip(
                    Icons.grid_view,
                    '${widget.packData['iconCount'] ?? 0} icons'),
                const SizedBox(width: 16),
                _statChip(Icons.download_outlined,
                    '${widget.packData['downloads'] ?? 0} downloads'),
                const Spacer(),
                if (widget.packData['description'] != null &&
                    (widget.packData['description'] as String).isNotEmpty)
                  Flexible(
                    child: Text(
                      widget.packData['description'],
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          // Icons grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getPackIcons(widget.packId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.gold));
                }

                final icons = snapshot.data?.docs ?? [];

                if (icons.isEmpty) {
                  return _buildEmptyIconState();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: icons.length + 1,
                  itemBuilder: (context, index) {
                    if (index == icons.length) {
                      return _buildAddIconCard();
                    }
                    final icon = icons[index];
                    final data = icon.data() as Map<String, dynamic>;
                    return _buildIconCard(icon.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openIconEditor(),
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 14),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyIconState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              color: AppColors.gold.withValues(alpha: 0.3), size: 64),
          const SizedBox(height: 16),
          const Text('No icons yet',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add your first icon to this pack',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAddIconCard() {
    return GestureDetector(
      onTap: () => _openIconEditor(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add,
                color: AppColors.gold.withValues(alpha: 0.7), size: 28),
            const SizedBox(height: 6),
            Text('Add',
                style: TextStyle(
                    color: AppColors.gold.withValues(alpha: 0.7),
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconCard(String iconId, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => _openIconEditor(iconId: iconId, iconData: data),
      onLongPress: () => _confirmDelete(iconId),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.panelBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            data['storageUrl'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      data['storageUrl'],
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.diamond,
                    color: AppColors.gold, size: 36),
            const SizedBox(height: 6),
            Text(
              data['name'] ?? 'Icon',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String iconId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: const Text('Delete Icon',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Remove this icon from the pack?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirmed == true) await _deleteIcon(iconId);
  }
}

// ── Icon Editor Sheet ─────────────────────────────────────────────────────────

class IconEditorSheet extends StatefulWidget {
  final String packId;
  final String? iconId;
  final Map<String, dynamic>? existingData;

  const IconEditorSheet({
    super.key,
    required this.packId,
    this.iconId,
    this.existingData,
  });

  @override
  State<IconEditorSheet> createState() => _IconEditorSheetState();
}

class _IconEditorSheetState extends State<IconEditorSheet> {
  late EditorState editorState;
  final _nameCtrl = TextEditingController();
  bool _saving = false;
  final GlobalKey _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.existingData?['name'] ?? '';
    final settings =
        widget.existingData?['editorSettings'] as Map<String, dynamic>?;
    editorState = settings != null
        ? EditorState(
            scale: (settings['scale'] as num?)?.toDouble() ?? 50,
            rotation: (settings['rotation'] as num?)?.toDouble() ?? 0,
            brightness: (settings['brightness'] as num?)?.toDouble() ?? 100,
            contrast: (settings['contrast'] as num?)?.toDouble() ?? 100,
            saturation: (settings['saturation'] as num?)?.toDouble() ?? 100,
            blur: (settings['blur'] as num?)?.toDouble() ?? 0,
            refractionIndex:
                (settings['refractionIndex'] as num?)?.toDouble() ?? 2.42,
            sparkleIntensity:
                (settings['sparkleIntensity'] as num?)?.toDouble() ?? 0.8,
            facetDepth: (settings['facetDepth'] as num?)?.toDouble() ?? 0.6,
          )
        : EditorState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give your icon a name first')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final settings = {
        'scale': editorState.scale,
        'rotation': editorState.rotation,
        'brightness': editorState.brightness,
        'contrast': editorState.contrast,
        'saturation': editorState.saturation,
        'blur': editorState.blur,
        'refractionIndex': editorState.refractionIndex,
        'sparkleIntensity': editorState.sparkleIntensity,
        'facetDepth': editorState.facetDepth,
      };

      if (widget.iconId != null) {
        // Update existing
        await FirebaseService.updateIcon(
          widget.packId,
          widget.iconId!,
          {'name': _nameCtrl.text.trim(), 'editorSettings': settings},
        );
      } else {
        // Add new
        await FirebaseService.addIconToPack(
          packId: widget.packId,
          name: _nameCtrl.text.trim(),
          editorSettings: settings,
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _nameCtrl,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            hintText: 'Icon name...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            border: InputBorder.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.gold))
                : const Text('Save',
                    style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
          ),
        ],
      ),
      body: StudioPage(
        embeddedMode: true,
        initialState: editorState,
        onStateChanged: (s) => setState(() => editorState = s),
      ),
    );
  }
}
