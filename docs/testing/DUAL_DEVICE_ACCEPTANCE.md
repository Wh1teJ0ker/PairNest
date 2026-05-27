# 双机运行态验收清单

本文档用于补足当前版本在“真实双机环境”下的最终验收证据。

目标：

- 验证扫码加入、Nearby 同步、图片回填、双端匹配状态切换是否真实跑通
- 验证首页、成长、时间轴、纪念日、同步页在关键写操作后是否同步刷新

## 一、测试前准备

设备要求：

- 两台 Android 设备，均安装同一构建版本
- 两台设备都已授予：
  - 相机权限
  - Nearby / 蓝牙 / WLAN 相关权限
  - 相册读写权限（用于图片验证）

环境要求：

- 两台设备靠近，蓝牙与 Wi‑Fi 保持可用
- 两台设备都进入同一个物理空间，避免 Nearby 发现不稳定

## 二、验收项目

### 1. 创建空间与扫码加入

操作：

1. A 设备进入“创建同频空间”
2. 填写昵称并生成邀请码
3. B 设备进入“扫码加入同频”
4. 扫描 A 设备的邀请码并完成加入

期望：

- B 设备加入成功后返回上一页
- B 设备首页、成长页、时间轴、纪念日、同步页均不再处于未绑定状态
- 首页显示当前情侣关系基础信息
- 同步页出现配对状态卡，但此时仍可能是“等待对端确认”

对应刷新验证：

- `invalidateAllPairScopedProjections()`

### 2. 首次 Nearby 同步确认

操作：

1. A、B 两台设备都进入同步页
2. 至少一台开启发现，另一台开启可发现
3. 选择设备并执行一次同步

期望：

- 同步状态卡出现最近同步结果
- 配对状态从“单端绑定”切换为“双端配对已完成”
- 首页的配对概览同步切换为已匹配状态

对应刷新验证：

- `invalidateAllPairScopedProjections()`
- `pairingStatusProvider`
- 首页与同步页都读取到新的 `pairingStatusProvider`

### 3. 时间轴新增记录

操作：

1. 在 A 设备时间轴新增一条文字记录
2. 执行一次同步

期望：

- A 设备时间轴立即出现新记录
- A 设备首页“最近记录”立即更新
- B 设备同步后时间轴出现该记录
- B 设备首页“最近记录”同步更新
- 今日状态中的记录数同步变化

对应刷新验证：

- `invalidateAfterTimelineEntry()`
- `timelineProvider`
- `todayStatusProvider`
- `growthProvider`

### 4. 时间轴图片记录

操作：

1. 在 A 设备时间轴新增一条带图片的记录
2. 执行一次同步

期望：

- B 设备同步后可看到该条记录
- 图片文件成功落盘并可正常显示
- 首页最近记录区域可展示该条记录的文字内容

对应刷新验证：

- 事件合并后：`invalidateAllPairScopedProjections()`
- 图片落盘后：`invalidateAfterInboundSyncImage()`

### 5. 每日签到

操作：

1. 在 A 设备成长页点击签到
2. 观察本机状态
3. 执行一次同步并观察 B 设备

期望：

- A 设备按钮立即变为“今天已签到”
- A 设备首页今日状态显示“已签到”
- A 设备成长总值发生变化
- B 设备同步后首页今日状态也显示“已签到”
- 同一天内重复点击不会再次成功

对应刷新验证：

- `invalidateAfterCheckin()`
- `todayStatusProvider`
- `growthProvider`

备注：

- 当前时间轴不展示签到事件，因此时间轴不应发生变化

### 6. 共同任务完成

操作：

1. 在 A 设备成长页新增并完成一个共同任务
2. 观察本机状态
3. 执行一次同步并观察 B 设备

期望：

- A 设备最近任务列表立即出现该任务
- 首页今日状态中的任务数量增加
- 成长总值增加
- B 设备同步后任务记录与今日任务数量同步更新

对应刷新验证：

- `invalidateAfterTaskCompletion()`
- `growthTaskHistoryProvider`
- `todayStatusProvider`
- `growthProvider`

备注：

- 当前时间轴不展示 `COMPLETE_TASK` 事件，因此时间轴不应变化

### 7. 奖惩记录

操作：

1. 在 A 设备成长页新增一条奖惩记录
2. 再新增一条带图片的奖惩记录
3. 执行一次同步

期望：

- A 设备奖惩列表立即更新
- 首页成长总览同步变化
- 时间轴出现对应奖惩事件
- B 设备同步后奖惩列表、时间轴、成长值都更新
- 带图记录在 B 设备上图片可正常显示

对应刷新验证：

- `invalidateAfterPartnerScoreRecord()`
- 图片落盘后：`invalidateAfterInboundSyncImage()`

### 8. 纪念日新增

操作：

1. 在 A 设备纪念日页新增一个纪念日
2. 执行一次同步

期望：

- A 设备纪念日列表立即更新
- A 设备首页纪念日提醒立即更新
- A 设备时间轴出现纪念日事件
- B 设备同步后纪念日列表、首页提醒、时间轴都更新

对应刷新验证：

- `invalidateAfterAnniversary()`
- `anniversaryProvider`
- `timelineProvider`

## 三、最终通过标准

以下全部成立，才可视为运行态验收完成：

- 扫码加入成功
- Nearby 首次同步成功
- 首页与同步页都切换为双端已匹配
- 时间轴文字与图片同步成功
- 奖惩记录文字与图片同步成功
- 签到不可重复提交
- 共同任务不可重复误触发
- 纪念日新增后首页和时间轴联动正常
- 全程无明显状态不同步或页面未刷新问题

## 四、当前已具备的静态证据

当前版本已具备的代码与自动化证据：

- 刷新审计文档：
  - [STATE_REFRESH_AUDIT.md](/Users/joker/Code/PairNest/docs/engineering/STATE_REFRESH_AUDIT.md)
- 时间轴投影映射测试：
  - [timeline_mapping_test.dart](/Users/joker/Code/PairNest/test/timeline_mapping_test.dart)
- 今日状态聚合测试：
  - [today_status_aggregation_test.dart](/Users/joker/Code/PairNest/test/today_status_aggregation_test.dart)
- 配对状态聚合测试：
  - [pairing_status_aggregation_test.dart](/Users/joker/Code/PairNest/test/pairing_status_aggregation_test.dart)
- 同步会话测试：
  - [sync_session_test.dart](/Users/joker/Code/PairNest/test/sync_session_test.dart)
- 组件渲染测试：
  - [sync_widgets_test.dart](/Users/joker/Code/PairNest/test/sync_widgets_test.dart)
