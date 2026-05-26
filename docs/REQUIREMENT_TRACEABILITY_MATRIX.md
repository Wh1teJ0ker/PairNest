# PairNest 需求追踪矩阵（MVP）

版本：`0.1.0`  
更新时间：`2026-05-26`

本文件用于把《PairNest 需求文档》映射到当前代码与可执行验证证据。

## A. 项目概述与定位

| 需求项 | 实现证据 | 验证方式 |
|---|---|---|
| 无服务端 | 仅本地仓库与 Nearby 直连：`lib/src/data/pair_repository.dart`、`lib/src/features/sync/*` | 搜索无 HTTP 客户端依赖与服务端地址；运行 app 离线可用 |
| 本地存储 | SQLCipher 本地库：`lib/src/data/local_db.dart` | 本地运行并产生 `events` 数据 |
| 双端同步 | Nearby 事件+文件同步：`lib/src/features/sync/sync_panel.dart`、`nearby_sync_service.dart`、`sync_session.dart` | 双机联调（见 UAT 手册） |
| 双人共享空间 | `pair_id` 绑定 + 同步 `pairId` 强校验 | 单测 `test/sync_session_test.dart` + 真机联调 |
| 轻游戏化 | 成长分值、签到、任务奖励：`lib/src/features/growth/growth_page.dart` | 操作 UI 验证分值变化 |
| 强私密性 | SQLCipher + secure storage 密钥 + rekey 迁移 + pair 隔离 | 代码审计 + 本地门禁 + 双机隔离验证 |

## B. 核心功能

| 模块 | 需求项 | 实现证据 | 自动化证据 |
|---|---|---|---|
| 双人绑定 | 二维码绑定、建立关系、生成 pair_id | `lib/src/features/bonding/bonding_page.dart`、`scan_bind_page.dart`、`lib/src/data/pair_repository.dart` | `./scripts/mvp_self_check.sh` 文件与关键字检查 |
| 首页 | 恋爱天数、今日状态、最近记录、成长值、纪念日提醒 | `lib/src/features/home/home_page.dart`、`lib/src/app/providers.dart` | `flutter analyze` + `flutter test` |
| 时间轴 | 文字/图片/心情/标签 | `lib/src/features/timeline/timeline_page.dart`、`lib/src/data/pair_repository.dart` | `test/timeline_mapping_test.dart` |
| Nearby 同步 | 发现、连接、缺失同步、自动同步 | `lib/src/features/sync/sync_panel.dart`、`nearby_sync_service.dart`、`sync_session.dart` | `test/sync_session_test.dart` |
| 成长系统 | 签到、任务奖励、记录加分 | `lib/src/features/growth/growth_page.dart`、`lib/src/data/pair_repository.dart` | `test/growth_task_mapping_test.dart` |
| 纪念日 | 新增、倒计时、提醒、时间轴关联 | `lib/src/features/anniversary/anniversary_page.dart`、`home_page.dart`、`pair_repository.dart` | `test/timeline_mapping_test.dart` |

## C. 技术架构

| 需求项 | 证据 |
|---|---|
| Flutter 客户端 | `pubspec.yaml`（`flutter`）+ `lib/src/*` |
| SQLite + SQLCipher | `pubspec.yaml`（`sqflite_sqlcipher`）+ `local_db.dart` |
| Nearby Connections（BLE/WiFi Direct） | `pubspec.yaml`（`nearby_connections`）+ `nearby_sync_service.dart` |

## D. 同步机制（Event Log）

| 需求项 | 实现证据 | 验证方式 |
|---|---|---|
| 行为记录为事件 | `PairEvent` 模型 + `events` 表 | 代码审计 |
| 同步缺失事件 | `SyncSession.buildSyncRequest/buildSyncResponse` | `test/sync_session_test.dart` |
| 去重与合并 | `SyncSession.mergeWithReport` | `test/sync_session_test.dart` |
| 文件回填 | `file_meta` + `updateEventImagePath` | 双机图片同步验收 |
| 同步状态语义 | `sync_panel.dart` 仅在请求阶段展示“已发起同步”，同步正确性由事件缺失交换与去重保证 | 代码审计 + UAT 状态文案核对 |

## E. UI 设计方向

| 方向 | 实现证据 |
|---|---|
| 极简、低饱和、卡片化 | `SectionCard`、各页面配色与卡片布局 |
| 氛围感 | `AtmosphereBackground` |
| 轻动画 | `StaggeredColumn`、`PressableScale`、页面切换动画 |

## F. 安全与私密性

| 项目 | 实现证据 |
|---|---|
| SQLCipher 加密 | `local_db.dart`（`openDatabase(..., password: ...)`） |
| 密钥安全存储 | `flutter_secure_storage` + `pairnest_db_key_v1` |
| 旧库迁移 | `PRAGMA rekey` |
| 空间隔离 | 同步消息 `pairId` 校验（事件与文件元数据） |

## G. 质量门禁与发布前检查

执行命令：

```bash
flutter analyze
flutter test
./scripts/audit.sh
./scripts/mvp_self_check.sh
./scripts/release_check.sh
```

脚本证据：

- `scripts/audit.sh`
- `scripts/mvp_self_check.sh`
- `scripts/release_check.sh`
- `.github/workflows/flutter_quality.yml`
- `scripts/mvp_self_check.sh` 中“本地优先与无服务端守卫”检查：
  - 阻止常见网络客户端依赖（`http` / `dio` / `retrofit` 等）
  - 阻止 `lib/src` 中出现 `http://` / `https://` 远程地址字面量
