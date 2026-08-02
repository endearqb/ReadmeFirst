# 09. 七个必做实验与综合结业项目

## 实验共同格式

```text
目标 → 错误实现 → 可重复故障 → 根因 → 最小修复
→ 自动测试 → 运行证据 → 团队门禁
```

## 七个实验

1. **慢查询与查询计划**：生成 10 万至 100 万条倾斜数据，比较单列、复合和部分索引，记录计划、buffer、p95、索引大小和写入成本。
2. **丢失更新**：两个连接同时读取旧 version，复现静默覆盖；使用条件 UPDATE 修复并重复 100 次。
3. **死锁与锁顺序**：A→B 与 B→A 反向加锁，观察 `40P01`；统一顺序并有界重试整个事务。
4. **幂等 POST**：模拟服务端提交成功但响应丢失；使用 idempotency record、请求哈希和 Outbox 保证一次副作用。
5. **无界并发与连接池**：输入 1000 个 ID，观察 pool wait、timeout、p99；改为输入上限、批量 SQL 和有界并发。
6. **CORS、缓存和浏览器存储**：故意配置通配符凭证、共享个性化缓存和 localStorage Token，再通过负面测试修复。
7. **完整故障链路**：数据增长导致计划退化，pool wait 上升，客户端重试放大；从 SLO、Trace 和 SQL 证据完成止血与根因修复。

## 综合结业项目

构建多租户 Node.js/TypeScript + PostgreSQL 工作项服务，包含 workspace、project、issue、comment、attachment、activity、export job 和 webhook/outbox。

必须实现：对象/动作/字段授权；游标分页；version 并发控制；幂等创建；缓存隔离；timeout/cancel/retry；队列与过载保护；结构化日志、指标和 Trace；真实 PostgreSQL 集成/并发/迁移测试；expand-migrate-switch-contract 演练。

结业报告包含请求链路、业务不变量、信任边界、查询计划、并发与幂等证据、权限矩阵、负载结果、迁移演练、故障复盘和残余风险。任何跨租户泄露、认证绕过、不可恢复数据破坏或关键重复副作用直接判定不通过。
