## Summary

- 变更内容：
- 影响范围：

## Checklist

- [ ] `dart format --output=none --set-exit-if-changed lib test`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] 涉及同步逻辑时已验证事件幂等与去重（event_id）
- [ ] 涉及数据结构变更时已补充兼容性说明

## Risk

- 风险点：
- 回滚方案：
