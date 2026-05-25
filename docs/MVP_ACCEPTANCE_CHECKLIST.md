# PairNest MVP 验收清单

版本：`0.1.0`  
更新时间：`2026-05-26`

## 1. 双人绑定

- [ ] 发起方可填写双方昵称、开始日期并完成绑定
- [ ] 发起方可展示邀请二维码（含 `pair_id`）
- [ ] 加入方可扫码二维码并输入自己的昵称完成加入
- [ ] 双端绑定后落在同一 `pair_id`

证据：

- `lib/src/features/bonding/bonding_page.dart`
- `lib/src/features/bonding/scan_bind_page.dart`
- `lib/src/data/pair_repository.dart`

## 2. 首页

- [ ] 展示恋爱天数
- [ ] 展示今日状态（签到状态 / 今日记录数 / 心情）
- [ ] 展示最近记录
- [ ] 展示成长值（亲密度/活跃度/默契值）
- [ ] 展示纪念日提醒

证据：

- `lib/src/features/home/home_page.dart`
- `lib/src/app/providers.dart`
- `lib/src/data/pair_repository.dart`

## 3. 时间轴

- [ ] 支持新增文字记录
- [ ] 支持新增图片记录
- [ ] 支持心情记录
- [ ] 支持标签
- [ ] 时间轴可渲染图片与标签

证据：

- `lib/src/features/timeline/timeline_page.dart`
- `lib/src/data/pair_repository.dart`

## 4. Nearby 同步

- [ ] 可发现附近设备
- [ ] 可建立连接
- [ ] 可同步缺失事件（Event Log）
- [ ] 可去重（重复事件不重复落库）
- [ ] 图片文件可跨端传输并回填到事件
- [ ] 同步状态可视化（最近同步时间、事件/文件统计）

证据：

- `lib/src/features/sync/sync_panel.dart`
- `lib/src/features/sync/nearby_sync_service.dart`
- `lib/src/features/sync/sync_session.dart`
- `lib/src/features/sync/sync_models.dart`
- `lib/src/data/pair_repository.dart`
- `test/sync_session_test.dart`

## 5. 成长系统

- [ ] 一起签到可增加成长值
- [ ] 一起完成任务可增加成长值
- [ ] 记录生活可累计活跃度
- [ ] 首页与成长页数值一致

证据：

- `lib/src/features/growth/growth_page.dart`
- `lib/src/data/pair_repository.dart`

## 6. 纪念日

- [ ] 可新增纪念日
- [ ] 可展示倒计时
- [ ] 7天内纪念日可展示“近期提醒”
- [ ] 首页可展示提醒
- [ ] 纪念日事件可关联到时间轴

证据：

- `lib/src/features/anniversary/anniversary_page.dart`
- `lib/src/features/home/home_page.dart`
- `lib/src/data/pair_repository.dart`
- `test/timeline_mapping_test.dart`

## 7. 本地优先与安全

- [ ] 数据本地 SQLite 存储
- [ ] 事件日志作为同步源
- [ ] SQLCipher 已接入
- [ ] 数据库密钥按设备随机生成并存储在系统安全存储
- [ ] 旧版固定密钥数据库可自动执行 `PRAGMA rekey` 迁移

证据：

- `lib/src/data/local_db.dart`
- `lib/src/data/pair_repository.dart`
- `pubspec.yaml`

## 8. 工程质量门禁

- [ ] `flutter analyze` 通过
- [ ] `flutter test` 通过
- [ ] 本地审计脚本通过
- [ ] CI 工作流存在并可执行

命令：

```bash
./scripts/audit.sh
./scripts/mvp_self_check.sh
```

证据：

- `.github/workflows/flutter_quality.yml`
- `scripts/audit.sh`
- `scripts/mvp_self_check.sh`
