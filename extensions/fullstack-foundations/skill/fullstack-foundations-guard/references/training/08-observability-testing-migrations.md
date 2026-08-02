# 08. 可观测性、测试、迁移与生产诊断

## 学习目标

- 区分日志、指标和 Trace；
- 定义包含正确性的 SLI/SLO；
- 根据风险选择单元、集成、契约、并发、故障、负载、安全和迁移测试；
- 设计 expand → migrate → switch → contract；
- 从告警到 route、query、pool、cache、queue 和 downstream 还原故障链路。

## 可观测性

结构化日志建议包含 service/version、requestId/traceId、tenant/actor 内部标识、method/route/status/duration、稳定 errorCode、query ID、pool wait、retry/idempotency、cache/downstream/queue 信息，并集中脱敏。

指标同时覆盖 RED（Rate、Errors、Duration）和 USE（Utilization、Saturation、Errors）。避免将 user ID、request ID 和完整 URL 作为高基数标签。Trace 用于跨 route、数据库、缓存、下游和异步任务建立时序关联，但不能记录完整 SQL、Token 或敏感请求体。

## 测试与迁移

关键数据库和并发逻辑使用真实 PostgreSQL，而不是完全依赖 mock。并发测试使用多个独立连接和 barrier 控制竞争点，并断言最终数据库状态。故障注入覆盖 timeout、连接重置、池耗尽、deadlock、缓存不可用、重复消息和“提交后响应前崩溃”。

迁移采用兼容分阶段流程；大表回填可重入、分批、有 checkpoint、速率、锁/语句 timeout、停止条件、验证查询和恢复/前滚方案。回滚不总是 down migration。

## 练习

从“列表 API p95 从 200ms 上升到 4s”的告警开始：按 route/tenant/version 分解，使用 Trace、pool 指标、`pg_stat_statements` 和查询计划定位根因；先限流或关闭重试放大止血，再修复查询/索引，运行前后负载测试并定义发布观察和回滚条件。
