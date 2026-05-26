## Summary

- 变更内容：
- 影响范围：
- 更新日志：

## Checklist

- [ ] `dart format --output=none --set-exit-if-changed lib test`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `./scripts/check_changelog.sh`
- [ ] 涉及同步逻辑时已验证事件幂等与去重（event_id）
- [ ] 涉及数据结构变更时已补充兼容性说明
- [ ] 已更新 `CHANGELOG.md`

## Risk

- 风险点：
- 回滚方案：
