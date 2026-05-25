import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models.dart';
import '../../widgets/section_card.dart';

class AnniversaryPage extends ConsumerStatefulWidget {
  const AnniversaryPage({super.key});

  @override
  ConsumerState<AnniversaryPage> createState() => _AnniversaryPageState();
}

class _AnniversaryPageState extends ConsumerState<AnniversaryPage> {
  final _titleController = TextEditingController();
  final _kindController = TextEditingController(text: '纪念日');
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _kindController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final list = ref.watch(anniversaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('纪念日')),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: '标题'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _kindController,
                        decoration: const InputDecoration(labelText: '类型'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('日期: ${_date.year}-${_date.month}-${_date.day}'),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(1990),
                                lastDate: DateTime(2100),
                                initialDate: _date,
                              );
                              if (picked != null) {
                                setState(() => _date = picked);
                              }
                            },
                            child: const Text('选择'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _save(profile),
                        child: const Text('添加纪念日'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                list.when(
                  data: (items) => Column(
                    children: items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SectionCard(
                              child: Row(
                                children: [
                                  const Icon(Icons.favorite_outline),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${item.kind} · ${item.date.year}.${item.date.month}.${item.date.day}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text('倒计时 ${item.daysLeft} 天'),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('纪念日加载失败: $e')),
                ),
              ],
            ),
    );
  }

  Future<void> _save(CoupleProfile? profile) async {
    if (profile == null) {
      return;
    }
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入标题')));
      return;
    }

    await ref
        .read(pairRepositoryProvider)
        .addAnniversary(
          profile: profile,
          title: title,
          date: _date,
          kind: _kindController.text.trim().isEmpty
              ? '纪念日'
              : _kindController.text.trim(),
        );

    _titleController.clear();
    ref.invalidate(anniversaryProvider);
  }
}
