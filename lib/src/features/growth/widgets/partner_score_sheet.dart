import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/permissions.dart';
import '../../../widgets/app_feedback.dart';

class PartnerScoreDraft {
  const PartnerScoreDraft({
    required this.title,
    required this.detail,
    required this.intimacyDelta,
    required this.activityDelta,
    required this.chemistryDelta,
    this.imagePath,
  });

  final String title;
  final String? detail;
  final int intimacyDelta;
  final int activityDelta;
  final int chemistryDelta;
  final String? imagePath;
}

Future<PartnerScoreDraft?> showPartnerScoreSheet(BuildContext context) {
  return showModalBottomSheet<PartnerScoreDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: const Color(0xFFFFFBF8),
    builder: (context) => const _PartnerScoreSheet(),
  );
}

class _PartnerScoreSheet extends StatefulWidget {
  const _PartnerScoreSheet();

  @override
  State<_PartnerScoreSheet> createState() => _PartnerScoreSheetState();
}

class _PartnerScoreSheetState extends State<_PartnerScoreSheet> {
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  int _intimacyDelta = 2;
  int _activityDelta = 0;
  int _chemistryDelta = 1;
  String? _imagePath;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '新增奖惩记录',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D2327),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '因为某件具体的事情，对对方加分或减分。支持附图，后续会出现在成长记录和时间轴中。',
                style: TextStyle(color: Color(0xFF6D6563), height: 1.45),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '事件标题',
                  hintText: '例如：记得带伞来接我',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detailController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '补充说明（可选）',
                  hintText: '记录当时发生了什么，为什么加分或减分',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 18),
              _DeltaEditor(
                label: '亲密度',
                icon: Icons.favorite_rounded,
                value: _intimacyDelta,
                onChanged: (value) => setState(() => _intimacyDelta = value),
              ),
              const SizedBox(height: 10),
              _DeltaEditor(
                label: '活跃度',
                icon: Icons.local_fire_department_rounded,
                value: _activityDelta,
                onChanged: (value) => setState(() => _activityDelta = value),
              ),
              const SizedBox(height: 10),
              _DeltaEditor(
                label: '默契值',
                icon: Icons.diversity_3_rounded,
                value: _chemistryDelta,
                onChanged: (value) => setState(() => _chemistryDelta = value),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_photo_alternate_rounded),
                      label: Text(_imagePath == null ? '添加图片' : '更换图片'),
                    ),
                  ),
                  if (_imagePath != null) ...[
                    const SizedBox(width: 10),
                    IconButton.outlined(
                      onPressed: () => setState(() => _imagePath = null),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ],
              ),
              if (_imagePath != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(_imagePath!),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _SummaryStrip(
                intimacyDelta: _intimacyDelta,
                activityDelta: _activityDelta,
                chemistryDelta: _chemistryDelta,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.done_rounded),
                  label: Text(_submitting ? '保存中...' : '保存奖惩记录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final granted = await Permissions.ensureGalleryRead();
    if (!mounted) {
      return;
    }
    if (!granted) {
      AppFeedback.info(context, '需要相册权限才能选择图片');
      return;
    }
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null || !mounted) {
      return;
    }
    setState(() => _imagePath = image.path);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppFeedback.info(context, '请先填写事件标题');
      return;
    }

    setState(() => _submitting = true);
    Navigator.of(context).pop(
      PartnerScoreDraft(
        title: title,
        detail: _detailController.text.trim().isEmpty
            ? null
            : _detailController.text.trim(),
        intimacyDelta: _intimacyDelta,
        activityDelta: _activityDelta,
        chemistryDelta: _chemistryDelta,
        imagePath: _imagePath,
      ),
    );
  }
}

class _DeltaEditor extends StatelessWidget {
  const _DeltaEditor({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final positive = value >= 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECE1D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${positive ? '+' : ''}$value',
                style: TextStyle(
                  color: positive
                      ? const Color(0xFF2E7A4B)
                      : const Color(0xFFAF4343),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: -10,
            max: 10,
            divisions: 20,
            label: value.toString(),
            onChanged: (next) => onChanged(next.round()),
          ),
          Row(
            children: [
              _QuickDeltaButton(label: '-5', onTap: () => onChanged(-5)),
              const SizedBox(width: 8),
              _QuickDeltaButton(label: '0', onTap: () => onChanged(0)),
              const SizedBox(width: 8),
              _QuickDeltaButton(label: '+5', onTap: () => onChanged(5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickDeltaButton extends StatelessWidget {
  const _QuickDeltaButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F0EA),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.intimacyDelta,
    required this.activityDelta,
    required this.chemistryDelta,
  });

  final int intimacyDelta;
  final int activityDelta;
  final int chemistryDelta;

  @override
  Widget build(BuildContext context) {
    final total = intimacyDelta + activityDelta + chemistryDelta;
    final positive = total >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFEAF5EC) : const Color(0xFFFFEFEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: positive ? const Color(0xFF2E7A4B) : const Color(0xFFAF4343),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '总变化 ${positive ? '+' : ''}$total 分',
              style: TextStyle(
                color: positive
                    ? const Color(0xFF2E7A4B)
                    : const Color(0xFFAF4343),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
