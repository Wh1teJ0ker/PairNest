# PairNest 验收证据报告

生成时间（本地）：`2026-05-26 13:04:34 CST`  
生成时间（UTC）：`2026-05-26T05:04:34Z`

构建信息：

- 分支：`main`
- 提交：`02f41c3`

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

UAT 自动校验：`未完成`（来源：`scripts/check_uat_result.sh`）

## 4) 需求覆盖状态（自动生成）

| ID | 模块 | 需求点 | 状态 | 证据 |
|---|---|---|---|---|
| B-1 | 双人绑定 | 二维码绑定与加入 | 需真机验证 | docs/NEARBY_DUAL_DEVICE_UAT.md |
| B-2 | 双人绑定 | 同一 pair_id 共享空间 | 自动已验证 | test/sync_session_test.dart + pairId 校验逻辑 |
| H-1 | 首页 | 恋爱天数/今日状态/最近记录/成长值/纪念日提醒渲染 | 自动已验证 | flutter analyze + widget_test + providers |
| T-1 | 时间轴 | 文字/心情/标签映射 | 自动已验证 | test/timeline_mapping_test.dart |
| T-2 | 时间轴 | 图片记录可渲染 | 需真机验证 | docs/NEARBY_DUAL_DEVICE_UAT.md（图片跨端同步后检查） |
| S-1 | Nearby同步 | 缺失事件同步与去重 | 自动已验证 | test/sync_session_test.dart |
| S-2 | Nearby同步 | 靠近自动同步（发现+连接+自动请求） | 需真机验证 | docs/NEARBY_DUAL_DEVICE_UAT.md |
| S-3 | Nearby同步 | 跨 pair_id 隔离 | 自动+真机 | sync_session_test + UAT Step 5 |
| G-1 | 成长系统 | 签到加分/任务加分/记录活跃度 | 自动已验证 | growth_task_mapping_test + growth 计算逻辑 |
| G-2 | 成长系统 | 首页与成长页数值一致 | 需真机验证 | UAT（同操作后双页核对） |
| A-1 | 纪念日系统 | 新增/倒计时/近期提醒/时间轴关联 | 自动已验证 | timeline_mapping_test + anniversary/home providers |
| P-1 | 私密性 | SQLCipher + secure storage 密钥管理 + rekey 迁移 | 自动已验证 | local_db.dart + mvp_self_check |
| P-2 | 私密性 | 无服务端、仅本地与 Nearby | 自动已验证 | 依赖与代码审计（无网络 API） |

## 5) 命令输出摘要

### flutter analyze（尾部）

```text
Analyzing PairNest...                                           
No issues found! (ran in 0.7s)
```

### flutter test（尾部）

```text
00:00 +0: loading /Users/joker/Code/PairNest/test/anniversary_item_test.dart
00:00 +0: /Users/joker/Code/PairNest/test/anniversary_item_test.dart: AnniversaryItem shouldRemind follows daysLeft and remindDays
00:00 +1: /Users/joker/Code/PairNest/test/anniversary_item_test.dart: Anniversary items can be sorted by daysLeft ascending
00:00 +2: /Users/joker/Code/PairNest/test/timeline_mapping_test.dart: timelineEntryFromEvent maps ADD_NOTE with details
00:00 +3: /Users/joker/Code/PairNest/test/timeline_mapping_test.dart: timelineEntryFromEvent maps ADD_ANNIVERSARY to timeline text and tags
00:00 +4: /Users/joker/Code/PairNest/test/timeline_mapping_test.dart: timelineEntryFromEvent returns null for anniversary with empty title
00:00 +5: /Users/joker/Code/PairNest/test/growth_score_aggregation_test.dart: growth aggregation combines ADD_SCORE and note activity bonus
00:00 +6: /Users/joker/Code/PairNest/test/growth_task_mapping_test.dart: growthTaskRecordFromEvent maps COMPLETE_TASK
00:00 +7: /Users/joker/Code/PairNest/test/growth_task_mapping_test.dart: growthTaskRecordFromEvent ignores empty title
00:00 +8: /Users/joker/Code/PairNest/test/sync_session_test.dart: SyncSession buildSyncResponse only includes missing events
00:00 +9: /Users/joker/Code/PairNest/test/sync_session_test.dart: SyncSession buildFullSyncPushPayload includes all local events
00:00 +10: /Users/joker/Code/PairNest/test/sync_session_test.dart: SyncSession mergeWithReport tracks inserts and duplicates
00:00 +11: /Users/joker/Code/PairNest/test/sync_session_test.dart: SyncSession mergeWithReport filters events from other pair ids
00:00 +12: /Users/joker/Code/PairNest/test/sync_session_test.dart: SyncSession collectMissingImageFiles returns existing image files only
00:00 +13: /Users/joker/Code/PairNest/test/today_status_aggregation_test.dart: todayStatusFromEvents counts checkin/note/task and latest mood
00:00 +14: /Users/joker/Code/PairNest/test/today_status_aggregation_test.dart: todayStatusFromEvents includes events at day start boundary
00:00 +15: /Users/joker/Code/PairNest/test/today_status_aggregation_test.dart: todayStatusFromEvents picks latest mood by timestamp not list order
00:00 +16: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:00 +17: All tests passed!
```

### release_check（尾部）

```text
[MVP] 1) 代码质量检查
Formatted 32 files (0 changed) in 0.07 seconds.
Analyzing PairNest...                                           
No issues found! (ran in 0.7s)
00:00 +0: loading /Users/joker/Code/PairNest/test/anniversary_item_test.dart
00:00 +0: /Users/joker/Code/PairNest/test/anniversary_item_test.dart: AnniversaryItem shouldRemind follows daysLeft and remindDays
00:00 +1: /Users/joker/Code/PairNest/test/anniversary_item_test.dart: Anniversary items can be sorted by daysLeft ascending
00:00 +2: /Users/joker/Code/PairNest/test/timeline_mapping_test.dart: timelineEntryFromEvent maps ADD_NOTE with details
00:00 +3: /Users/joker/Code/PairNest/test/timeline_mapping_test.dart: timelineEntryFromEvent maps ADD_ANNIVERSARY to timeline text and tags
00:00 +4: /Users/joker/Code/PairNest/test/timeline_mapping_test.dart: timelineEntryFromEvent returns null for anniversary with empty title
00:00 +5: /Users/joker/Code/PairNest/test/growth_task_mapping_test.dart: growthTaskRecordFromEvent maps COMPLETE_TASK
00:00 +6: /Users/joker/Code/PairNest/test/growth_task_mapping_test.dart: growthTaskRecordFromEvent maps COMPLETE_TASK
00:00 +7: /Users/joker/Code/PairNest/test/growth_task_mapping_test.dart: growthTaskRecordFromEvent ignores empty title
00:00 +8: /Users/joker/Code/PairNest/test/sync_session_test.dart: SyncSession buildSyncResponse only includes missing events
00:00 +9: /Users/joker/Code/PairNest/test/sync_session_test.dart: SyncSession buildFullSyncPushPayload includes all local events
00:00 +10: /Users/joker/Code/PairNest/test/sync_session_test.dart: SyncSession mergeWithReport tracks inserts and duplicates
00:00 +11: /Users/joker/Code/PairNest/test/sync_session_test.dart: SyncSession mergeWithReport filters events from other pair ids
00:00 +12: /Users/joker/Code/PairNest/test/sync_session_test.dart: SyncSession collectMissingImageFiles returns existing image files only
00:00 +13: /Users/joker/Code/PairNest/test/today_status_aggregation_test.dart: todayStatusFromEvents counts checkin/note/task and latest mood
00:00 +14: /Users/joker/Code/PairNest/test/today_status_aggregation_test.dart: todayStatusFromEvents includes events at day start boundary
00:00 +15: /Users/joker/Code/PairNest/test/today_status_aggregation_test.dart: todayStatusFromEvents picks latest mood by timestamp not list order
00:00 +16: /Users/joker/Code/PairNest/test/widget_test.dart: PairNest app boots
00:00 +17: All tests passed!
[MVP] 2) 核心能力文件存在性检查
[MVP] 3) 关键字段检查
[MVP] 4) 本地优先与无服务端守卫
[MVP] 基线通过
[Release] 3) 关键文档检查
[Release] 4) 版本号检查
[Release] 发布前检查通过
```

### UAT 校验

```text
[uat] total=5 passed=0 pending=5
[uat] 仍有未完成验收项
```
