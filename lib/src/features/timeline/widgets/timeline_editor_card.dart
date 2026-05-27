import 'dart:io';

import 'package:flutter/material.dart';

class TimelineEditorCard extends StatelessWidget {
  const TimelineEditorCard({
    super.key,
    required this.textController,
    required this.moodController,
    required this.tagController,
    required this.pickedImagePath,
    required this.submitting,
    required this.onPickImage,
    required this.onClearImage,
    required this.onSubmit,
  });

  final TextEditingController textController;
  final TextEditingController moodController;
  final TextEditingController tagController;
  final String? pickedImagePath;
  final bool submitting;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDCD6F2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14977C74),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '写下今天的共同片段',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D2327),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '支持文字、心情、标签和图片，奖惩记录也会自动汇入这里。',
            style: TextStyle(color: Color(0xFF6D6563), height: 1.45),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: '今天一起做了什么？',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: moodController,
            decoration: const InputDecoration(
              labelText: '心情（可选）',
              prefixIcon: Icon(Icons.mood_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: tagController,
            decoration: const InputDecoration(
              labelText: '标签（逗号分隔，可选）',
              prefixIcon: Icon(Icons.sell_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: submitting ? null : onPickImage,
                  icon: const Icon(Icons.add_photo_alternate_rounded),
                  label: Text(pickedImagePath == null ? '添加图片' : '更换图片'),
                ),
              ),
              if (pickedImagePath != null) ...[
                const SizedBox(width: 10),
                IconButton.outlined(
                  onPressed: submitting ? null : onClearImage,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ],
          ),
          if (pickedImagePath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(pickedImagePath!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pickedImagePath!.split('/').last,
              style: const TextStyle(color: Colors.black54, fontSize: 12.5),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: submitting ? null : onSubmit,
              icon: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.bookmark_added_rounded),
              label: Text(submitting ? '保存中...' : '保存记录'),
            ),
          ),
        ],
      ),
    );
  }
}
