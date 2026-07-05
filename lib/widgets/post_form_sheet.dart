import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/food_post.dart';
import '../models/stage.dart';
import '../services/image_service.dart';
import '../services/post_repository.dart';
import '../theme/app_colors.dart';
import 'pill_chip.dart';

/// 「記録する」ボタンから開く投稿フォーム（ボトムシート）。
class PostFormSheet extends StatefulWidget {
  final PostRepository repository;
  final String initialStage;
  final int initialMonth;
  final ValueChanged<FoodPost> onSaved;

  const PostFormSheet({
    super.key,
    required this.repository,
    required this.initialStage,
    required this.initialMonth,
    required this.onSaved,
  });

  @override
  State<PostFormSheet> createState() => _PostFormSheetState();
}

class _PostFormSheetState extends State<PostFormSheet> {
  final _picker = ImagePicker();
  final _memoController = TextEditingController();

  late String _stage;
  late int _month;
  Uint8List? _draftImage;
  bool _isPickingImage = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _stage = widget.initialStage;
    final stage = stageByKey(_stage);
    _month = widget.initialMonth == kAllMonths ? stage.months.first : widget.initialMonth;
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void _onStageChanged(String key) {
    setState(() {
      _stage = key;
      _month = stageByKey(key).months.first;
    });
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: AppColors.moss),
              title: const Text('カメラで撮る'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.moss),
              title: const Text('アルバムから選ぶ'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;

    setState(() => _isPickingImage = true);
    try {
      final bytes = await picked.readAsBytes();
      final compressed = await ImageService.compress(bytes);
      if (mounted) setState(() => _draftImage = compressed);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('画像の読み込みに失敗しました')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _submit() async {
    if (_draftImage == null || _saving) return;
    setState(() => _saving = true);
    try {
      final post = await widget.repository.addPost(
        imageBytes: _draftImage!,
        memo: _memoController.text.trim(),
        stage: _stage,
        month: _month,
      );
      widget.onSaved(post);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存に失敗しました')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final months = stageByKey(_stage).months;
    final canSubmit = _draftImage != null && !_saving;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '今日のごはん',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.ink),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.ink.withValues(alpha: 0.08),
                      shape: const CircleBorder(),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _isPickingImage ? null : _pickImage,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.moss.withValues(alpha: 0.35), width: 2),
                    ),
                    child: _buildDropzoneContent(),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: kStages
                    .map(
                      (s) => PillChip(
                        label: s.label,
                        active: _stage == s.key,
                        onTap: () => _onStageChanged(s.key),
                        activeColor: AppColors.leaf,
                        idleBorderColor: AppColors.moss.withValues(alpha: 0.3),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: months
                    .map(
                      (m) => PillChip(
                        label: '$mヶ月',
                        active: _month == m,
                        onTap: () => setState(() => _month = m),
                        activeColor: AppColors.clay,
                        idleBorderColor: AppColors.clay.withValues(alpha: 0.35),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _memoController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'メモ（例：かぼちゃペースト、初めての人参）',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.moss.withValues(alpha: 0.25)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.moss.withValues(alpha: 0.25)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.clay,
                  disabledBackgroundColor: AppColors.clay.withValues(alpha: 0.4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  _saving ? '保存中…' : '記録する',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '※この記録はこの端末に保存されます',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.ink.withValues(alpha: 0.45)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropzoneContent() {
    if (_isPickingImage) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.moss),
        ),
      );
    }
    if (_draftImage != null) {
      return Image.memory(_draftImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.camera_alt_outlined, size: 26, color: AppColors.moss),
          SizedBox(height: 6),
          Text('写真を選ぶ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.moss)),
        ],
      ),
    );
  }
}
