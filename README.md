# 同频（PairNest）

中文主页 | [English](README.en.md)

同频（PairNest）是一款面向情侣关系场景的本地优先 Flutter 应用，强调私密记录、双人协作与设备直连同步，不依赖中心化后端服务。

[![Flutter Quality Gate](https://github.com/Wh1teJ0ker/PairNest/actions/workflows/flutter_quality.yml/badge.svg)](https://github.com/Wh1teJ0ker/PairNest/actions/workflows/flutter_quality.yml)
[![Android Release](https://github.com/Wh1teJ0ker/PairNest/actions/workflows/android_release.yml/badge.svg)](https://github.com/Wh1teJ0ker/PairNest/actions/workflows/android_release.yml)

## 项目概览

同频（PairNest）当前聚焦以下产品方向：

- 本地优先：默认数据只保留在设备本地
- 双人空间：围绕情侣共同记录与共同成长设计
- 事件模型：通过事件日志驱动数据同步与状态投影
- 离线可用：先记录，后同步
- Android 优先：当前 MVP 以 Android 双机直连同步为主

当前仓库已包含：

- MVP 基线功能
- 本地审计与发布门禁
- GitHub Actions 质量检查流程
- Android Release 自动发布流程

## 核心能力

- 二维码配对与加入
- 首页关系总览
  - 恋爱天数
  - 今日状态
  - 最近记录
  - 成长值
  - 纪念日提醒
- 时间轴记录
  - 文字
  - 心情
  - 标签
  - 图片
- 成长系统
  - 签到
  - 任务
  - 活跃度累积
- 纪念日创建与倒计时
- Nearby 近场直连同步
- SQLCipher 本地加密存储
- `flutter_secure_storage` 本地密钥托管

## 技术栈

- Flutter
- Riverpod
- SQLCipher / SQLite
- Nearby Connections
- GitHub Actions

## 架构原则

- 数据采用 append-only 事件日志
- 业务页面依赖本地投影视图
- 同步过程交换缺失事件，而不是直接覆盖业务表
- 隐私边界保持在设备本地与显式 Nearby 传输链路

代表性事件类型：

- `BIND_PAIR`
- `ADD_NOTE`
- `ADD_IMAGE`
- `ADD_MOOD`
- `ADD_SCORE`
- `ADD_ANNIVERSARY`
- `DAILY_CHECKIN`

## 模块范围

当前 MVP 覆盖模块：

- `Bonding`
  配对二维码展示与扫码加入
- `Home`
  关系总览与提醒摘要
- `Timeline`
  文字、心情、标签、图片记录
- `Growth`
  成长积分与任务反馈
- `Anniversary`
  纪念日与倒计时
- `Sync`
  基于 Nearby 的事件日志同步

## 仓库结构

```text
lib/                      Flutter 业务代码
test/                     单元测试与组件测试
docs/                     产品、验收、版本与规范文档
scripts/                  审计、发布与校验脚本
.github/workflows/        CI 与 Release 自动化
third_party/              固定构建依赖的 vendored 组件
android/                  Android 宿主工程
```

目录与命名规范见 [`docs/engineering/PROJECT_STRUCTURE.md`](docs/engineering/PROJECT_STRUCTURE.md)。

## 快速开始

### 环境要求

- Flutter `3.44.0`
- Dart `3.12.0`
- Android SDK
- Android NDK `28.2.13676358`
- Java `17`

### 安装依赖

```bash
flutter pub get
```

### 运行

```bash
flutter run -d android
```

### 构建调试包

```bash
flutter build apk --debug
```

### 构建发布包

```bash
flutter build apk --release
```

## Android 权限说明

应用只会在对应流程触发时请求权限：

- 相机权限：扫码绑定
- 相册或存储权限：图片记录
- 蓝牙 / Nearby / 定位权限：双机直连同步

## 质量门禁

本地基础门禁：

```bash
flutter analyze
flutter test
./scripts/release/release_check.sh
```

补充验收工具：

```bash
./scripts/qa/mvp_self_check.sh
./scripts/qa/final_acceptance_check.sh --skip-uat
```

## 发布流程

当前仓库包含两个 GitHub Actions 工作流：

- `Flutter Quality Gate`
  格式检查、静态分析、测试、UAT 脚本自测
- `Android Release`
  基于 `v*` tag 的 Android ABI 拆包构建与 GitHub Release 上传

### 版本规则

版本单一来源是 `pubspec.yaml`：

- 语义版本：`MAJOR.MINOR.PATCH`
- 构建号：`+BUILD`
- Git tag 规则：`vMAJOR.MINOR.PATCH`

当前基线版本：

- 应用版本：`0.1.3+4`
- 当前发布 tag：`v0.1.3`

详细规则见 [`docs/release/VERSIONING.md`](docs/release/VERSIONING.md)。

### 标准发布步骤

1. 更新 `pubspec.yaml`
2. 更新 `CHANGELOG.md`
3. 运行 `./scripts/release/release_check.sh`
4. 推送到 `main`
5. 创建并推送形如 `v0.1.3` 的 tag
6. GitHub Actions 自动构建并上传 Android Release 资产

## 日志与变更规范

仓库要求每次代码更新都补充清晰的变更日志，不允许只写“fix”或“优化”这类不可审计描述。

规范入口：

- [`CHANGELOG.md`](CHANGELOG.md)
- [`docs/policies/CHANGELOG_POLICY.md`](docs/policies/CHANGELOG_POLICY.md)
- [`CONTRIBUTING.md`](CONTRIBUTING.md)

最低要求：

- 每次准备发布时，必须补充 `CHANGELOG.md`
- 每个条目必须说明：
  - 改了什么
  - 为什么改
  - 影响范围
  - 是否有兼容性或风险变化
- Pull Request 描述必须同步填写变更摘要、风险和验证项

## 当前发布状态

当前已验证：

- `flutter analyze`
- `flutter test`
- `./scripts/release/release_check.sh`
- 本地 ABI 拆包发布构建

## 文档索引

- [`docs/release/VERSIONING.md`](docs/release/VERSIONING.md)
- [`docs/policies/CHANGELOG_POLICY.md`](docs/policies/CHANGELOG_POLICY.md)
- [`docs/qa/NEARBY_DUAL_DEVICE_UAT.md`](docs/qa/NEARBY_DUAL_DEVICE_UAT.md)
- [`docs/qa/REQUIREMENT_TRACEABILITY_MATRIX.md`](docs/qa/REQUIREMENT_TRACEABILITY_MATRIX.md)
- [`docs/qa/MVP_ACCEPTANCE_CHECKLIST.md`](docs/qa/MVP_ACCEPTANCE_CHECKLIST.md)

## 路线图

- 补充产品截图与演示 GIF
- 补全双机真机验收证据
- 提升同步冲突可见性与重试体验
- 扩展 Release Notes 自动生成能力
- 增加变更日志与发布说明的自动校验

## 已知约束

- `nearby_connections` 当前以 `third_party/` vendored 形式固定，避免上游 Android 构建不稳定
- 本机构建链路曾受 Maven TLS 抖动影响，当前已通过固定依赖与本地验证缓解

## 贡献说明

请先阅读：

- [`CONTRIBUTING.md`](CONTRIBUTING.md)

重点要求：

- 保持变更范围明确
- 通过本地质量门禁
- 遵守更新日志规范
- 将事件日志兼容性视为发布约束

## 许可证

当前仓库未在根目录声明公开许可证，默认按仓库所有者策略处理。
