# PairNest

PairNest 是一款面向情侣的本地优先（Local First）双人记录应用 MVP。

## 当前实现（MVP骨架）

- 双人绑定：生成本地 `pair_id` 与 `device_id`
- 首页：恋爱天数、最近记录、成长值、纪念日、同步面板
- 时间轴：文字记录、心情、标签
- 成长系统：`intimacy / activity / chemistry` 累积分值
- 纪念日：添加与倒计时
- 纪念日与时间轴关联：新增纪念日会在时间轴中生成一条关联记录
- 同步机制：事件日志（Event Log）+ Nearby 同步服务接口

## 技术栈

- Flutter
- SQLite (sqflite_sqlcipher)
- Riverpod
- Nearby Connections（接口已接入，设备发现与同步流程已预留）

## 运行

```bash
flutter pub get
flutter run -d android
```

## Android 权限

首次使用以下能力时，App 会请求运行时权限：

- 扫码绑定：相机权限
- 图片记录：相册/存储读取权限
- Nearby 同步：定位、蓝牙、Nearby WiFi 设备权限（按系统版本）

## 双机联调建议（自动模式优先）

1. 双机都完成绑定（发起方展示二维码、加入方扫码加入）。
2. 双机都打开同步面板，点击“一键自动同步”。
3. 保持两机靠近，等待自动发现与自动同步触发。
4. 若包含图片记录，等待“图片同步完成”提示后再查看时间轴。
5. 可执行一键自检，并按真机手册做最终验收：

```bash
./scripts/mvp_self_check.sh
```

参考文档：

- `docs/NEARBY_DUAL_DEVICE_UAT.md`
- `docs/REQUIREMENT_TRACEABILITY_MATRIX.md`

## 数据设计

所有行为都落为事件，不直接改业务表：

- `BIND_PAIR`
- `ADD_NOTE`
- `ADD_IMAGE`
- `ADD_MOOD`
- `ADD_SCORE`
- `ADD_ANNIVERSARY`
- `DAILY_CHECKIN`

同步策略：

- 每端维护本地事件日志
- 同步时交换缺失事件
- 合并时按 `event_id` 去重

## 后续建议

- 完成 Nearby 双向传输与冲突处理（基于 event_id 幂等）
- 完善真机权限提示与失败重试交互
- 增加数据库密钥轮换与跨设备密钥恢复策略
- 增加绑定二维码扫描与邀请流程
