# 10. 团队落地、能力模型、门禁与资料

## 30 / 60 / 90 天

### 0–30 天：共同语言和基线

选择真实事故作为案例；安装 README First v2.2 与 Profile；统一 lint/typecheck/unit/integration/migration/build；建立 PostgreSQL 测试环境；盘点 Token、CORS、慢查询、N+1、无界任务和连接池；完成慢查询与丢失更新实验。

### 31–60 天：自动门禁

CI 运行真实数据库集成、权限负面、并发/幂等和迁移测试；建立查询计划证据模板、timeout/retry/cancel 基线、日志脱敏、连接池与 event-loop 指标；使用 CodeAgent Skill 做结构化 Review。

### 61–90 天：生产反馈

为核心业务定义 SLI/SLO；建立 route/query/pool/cache/queue/downstream dashboard；执行负载和故障演练；定期用 Maintainer 检查 Profile/Skill/changes；把事故和高频 finding 沉淀到 README、Profile、Skill 和 CI。

## 能力等级

| 等级 | 定义 |
|---|---|
| L0 复制可用 | 能拼出功能，不能解释机制，只适合严格模板下低风险任务 |
| L1 理解基础 | 能解释常见机制并在模板下完成任务 |
| L2 独立交付 | 能设计、实现和验证常规生产功能 |
| L3 诊断与规范 | 能复现复杂生产问题并建立团队规范 |
| L4 平台与治理 | 能把经验沉淀为自动化、SLO 和组织能力 |

所有写服务端、SQL 或迁移的人应达到相关领域 L2；每个高风险领域至少一名 L3。

## PR 最低门禁

- 写出目标、非目标、请求链路、业务不变量、信任边界和失败路径；
- SQL 参数化、有界、稳定排序，索引建议有真实查询形状与计划；
- 事务、锁顺序、重试、幂等和外部副作用明确；
- timeout、cancel、retry、CORS、Cookie、cache 和资源上限匹配；
- 服务端完成对象/动作/字段与多租户授权；
- 日志不含秘密和不必要 PII；
- 单元、集成、并发、权限、迁移和负载测试按风险覆盖；
- L2 changes 记录风险领域、Profile/Skill 和风险对应证据。

## 推荐资料

具体一手资料入口见 [`../source-map.md`](../source-map.md)：PostgreSQL、Node.js、TypeScript、RFC 9110、MDN、OWASP 和 Agent Skills 规范。项目代码、schema、配置、测试和真实运行结果始终是项目事实来源。

## 最终原则

```text
理解请求 → 定义不变量 → 建立信任边界
→ 控制事务、并发和资源 → 用数据库和协议表达约束
→ 用测试复现失败 → 用日志、指标和 Trace 证明行为
→ 用迁移与恢复计划安全发布 → 沉淀为 README、Profile、Skill 和 CI
```
