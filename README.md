# PairNest

PairNest 是一款面向情侣的本地优先（Local First）双人记录应用 MVP。

## 当前实现（MVP骨架）

- 双人绑定：生成本地 `pair_id` 与 `device_id`
- 首页：恋爱天数、最近记录、成长值、纪念日、同步面板
- 时间轴：文字记录、心情、标签
- 成长系统：`intimacy / activity / chemistry` 累积分值
- 纪念日：添加与倒计时
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
- 为图片记录接入本地文件选取与存储
- 引入端到端密钥管理替换固定 DB 密码
- 增加绑定二维码扫描与邀请流程
