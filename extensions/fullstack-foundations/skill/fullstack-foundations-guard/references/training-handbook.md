# 从前端到可靠全栈：培训手册导航

> 更新于:2026-08-02

本文件是 `fullstack-foundations-guard` Mentor 模式的渐进入口。除非用户明确要求系统培训、能力评估或课程设计，不要一次加载全部章节；先根据当前问题读取一个专题，再用故障复现、修复和证据推进。

## 推荐阅读顺序

| 阶段 | 章节 | 目标 |
|---|---|---|
| 请求基础 | [01 JavaScript、TypeScript 与浏览器](training/01-javascript-typescript-browser.md) | 运行时、异步、边界校验和 DevTools |
| 协议基础 | [02 HTTP、CORS、缓存与重试](training/02-http-cors-cache-retries.md) | 跨域、Cookie、缓存、超时、取消和重试 |
| 服务端基础 | [03 Node.js 运行时](training/03-nodejs-runtime.md) | 事件循环、分层、错误处理和优雅停机 |
| 数据基础 | [04 PostgreSQL 建模与索引](training/04-postgresql-modeling-indexes.md) | 用约束表达不变量，用计划验证查询 |
| 一致性 | [05 事务、并发与幂等](training/05-transactions-concurrency-idempotency.md) | 锁、竞态、重复请求和外部副作用 |
| 容量 | [06 缓存、过载与背压](training/06-cache-overload-backpressure.md) | 缓存隔离、资源预算、限流和降级 |
| 防护 | [07 安全、授权与隐私](training/07-security-privacy.md) | 信任边界、负面权限测试和数据最小化 |
| 交付 | [08 可观测性、测试与迁移](training/08-observability-testing-migrations.md) | 用证据定位故障并安全发布 |
| 实践 | [09 七个实验与结业项目](training/09-labs-and-capstone.md) | 把机制变成可重复实验和综合交付 |
| 组织化 | [10 团队落地、能力模型与资料](training/10-team-rollout-checklists-sources.md) | 30/60/90 天计划、门禁和晋级标准 |

## Mentor 教学顺序

```text
概念与请求链路
  → 错误实现
  → 最小故障复现
  → 机制解释
  → 最小修复
  → 自动化测试
  → 风险对应证据
  → 团队门禁
```

## 十条工程不变量

1. 客户端只能改善体验，不能维护最终业务真相。
2. 所有外部输入都不可信。
3. 并发不是边缘情况，而是默认情况。
4. 网络调用会超时、失败、重复、乱序，并返回未知结果。
5. 查询、批量、并发、上传、队列和响应必须有界。
6. 关键业务不变量尽量由数据库约束或原子写入兜底。
7. 缓存会过期、失效并返回旧数据，且必须按租户与权限隔离。
8. 每一种资源都有预算，连接池和队列不能创造容量。
9. 日志、指标和 Trace 也是生产数据，不得泄露秘密与不必要的个人信息。
10. 无证据的性能、安全与正确性结论只是猜测。

## 配套资料

- [审查清单](review-checklist.md)
- [正反模式](patterns-and-antipatterns.md)
- [输出契约](output-contract.md)
- [权威资料映射](source-map.md)
- [审查示例](../examples/review-example.md)
