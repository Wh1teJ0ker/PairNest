# PairNest 验收证据报告

生成时间（本地）：`2026-05-26 11:49:09 CST`  
生成时间（UTC）：`2026-05-26T03:49:09Z`

构建信息：

- 分支：`main`
- 提交：`cdfaf27`

## 1) 自动化门禁结果

- `flutter analyze`：通过
- `flutter test`：通过
- `./scripts/release_check.sh`：通过

## 2) 需求追踪文档

- `docs/REQUIREMENT_TRACEABILITY_MATRIX.md`
- `docs/MVP_ACCEPTANCE_CHECKLIST.md`
- `docs/NEARBY_DUAL_DEVICE_UAT.md`

## 3) 仍需真机补证项（双机 Nearby）

以下项需按 `docs/NEARBY_DUAL_DEVICE_UAT.md` 在真机上执行并补充截图：

- [ ] 双人绑定（扫码加入）通过
- [ ] 自动模式靠近同步通过
- [ ] 图片跨端同步与回填通过
- [ ] 重复同步幂等通过
- [ ] 跨 `pair_id` 隔离通过

## 4) 命令输出摘要

### flutter analyze（尾部）

```text
Analyzing PairNest...                                           
No issues found! (ran in 1.0s)
```

### flutter test（尾部）

```text
00:00 +0: loading /Users/joker/Code/PairNest/test/anniversary_item_test.dart
00:00 +0: /Users/joker/Code/PairNest/test/anniversary_item_test.dart: AnniversaryItem shouldRemind follows daysLeft and remindDays
00:00 +1: /Users/joker/Code/PairNest/test/anniversary_item_test.dart: Anniversary items can be sorted by daysLeft ascending
00:00 +2: /Users/joker/Code/PairNest/test/timeline_mapping_test.dart: timelineEntryFromEvent maps ADD_NOTE with details
00:00 +3: /Users/joker/Code/PairNest/test/growth_task_mapping_test.dart: growthTaskRecordFromEvent maps COMPLETE_TASK
00:00 +4: /Users/joker/Code/PairNest/test/timeline_mapping_test.dart: timelineEntryFromEvent maps ADD_ANNIVERSARY to timeline text and tags
00:00 +5: /Users/joker/Code/PairNest/test/timeline_mapping_test.dart: timelineEntryFromEvent maps ADD_ANNIVERSARY to timeline text and tags
00:00 +6: /Users/joker/Code/PairNest/test/timeline_mapping_test.dart: timelineEntryFromEvent returns null for anniversary with empty title
00:00 +7: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:00 +8: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:00 +9: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:00 +10: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:00 +11: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:00 +12: All tests passed!
```

### release_check（尾部）

```text
00:00 +9: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:00 +10: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:00 +11: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:01 +12: All tests passed!
[audit] 通过
[Release] 2) MVP 验收自检
[MVP] 1) 代码质量检查
Formatted 30 files (0 changed) in 0.14 seconds.
Analyzing PairNest...                                           
No issues found! (ran in 1.2s)
00:00 +0: loading /Users/joker/Code/PairNest/test/anniversary_item_test.dart
00:00 +0: /Users/joker/Code/PairNest/test/anniversary_item_test.dart: AnniversaryItem shouldRemind follows daysLeft and remindDays
00:00 +1: /Users/joker/Code/PairNest/test/anniversary_item_test.dart: Anniversary items can be sorted by daysLeft ascending
00:00 +2: /Users/joker/Code/PairNest/test/growth_task_mapping_test.dart: growthTaskRecordFromEvent maps COMPLETE_TASK
00:00 +3: /Users/joker/Code/PairNest/test/growth_task_mapping_test.dart: growthTaskRecordFromEvent maps COMPLETE_TASK
00:00 +4: /Users/joker/Code/PairNest/test/timeline_mapping_test.dart: timelineEntryFromEvent maps ADD_ANNIVERSARY to timeline text and tags
00:00 +5: /Users/joker/Code/PairNest/test/timeline_mapping_test.dart: timelineEntryFromEvent maps ADD_ANNIVERSARY to timeline text and tags
00:00 +6: /Users/joker/Code/PairNest/test/timeline_mapping_test.dart: timelineEntryFromEvent returns null for anniversary with empty title
00:00 +7: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:00 +8: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:00 +9: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:00 +10: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:00 +11: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:01 +12: All tests passed!
[MVP] 2) 核心能力文件存在性检查
[MVP] 3) 关键字段检查
[MVP] 基线通过
[Release] 3) 关键文档检查
[Release] 4) 版本号检查
[Release] 发布前检查通过
```
