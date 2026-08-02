# Review Example：并发更新与列表慢查询

> 这是格式示例，不对应真实项目。路径、SQL 和数据均为虚构。

## 1. 结论

- **Verdict**：CHANGES REQUIRED
- **Scope**：`src/routes/tasks.ts`、`src/repositories/task-repository.ts`、`db/migrations/014_tasks.sql`
- **Highest risk**：任务状态更新采用“先读后写”且没有版本条件，两个并发请求可相互覆盖。
- **Evidence quality**：High
- **Not covered**：生产数据分布、真实连接池配置、API 网关超时。

## 2. 请求链路与不变量

`browser -> PATCH /tasks/:id -> validate -> authorize workspace -> taskService.update -> PostgreSQL -> response`

关键不变量：

1. 只有工作区成员可更新其可见任务；
2. 两个用户基于不同旧版本提交时，不得静默覆盖；
3. 列表接口最多返回 100 条，并保持稳定排序；
4. 任务标题不得进入未脱敏的审计日志。

## 3. Findings

### [P1][Confirmed][Concurrency] 更新存在丢失更新

- **Evidence**：`src/repositories/task-repository.ts:42-61` 先读取 `status/version`，随后仅按 `id` 执行 `UPDATE`；迁移中没有版本约束；现有测试只串行执行。
- **Trigger**：请求 A、B 同时读取 `version=7`，A 写入 `done` 后，B 仍可按旧版本写入 `blocked`。
- **Impact**：A 的成功修改被静默覆盖，审计记录与最终状态不一致。
- **Root cause**：并发控制只存在于应用内读取，没有进入原子写入条件。
- **Minimal fix**：增加 `version` 列；更新使用 `WHERE workspace_id=$1 AND id=$2 AND version=$3`，同时 `version=version+1`；受影响行数为 0 时返回 `409 conflict` 并提供当前版本。
- **Verification**：用两个独立数据库连接和 barrier 同步发起更新；断言只有一个成功、另一个为 409，最终版本只递增一次。
- **Residual risk**：需要确认离线客户端的冲突合并体验。

### [P2][High][Database] 列表查询可能扫描并排序大量租户数据

- **Evidence**：查询形状为：

```sql
SELECT id, title, status, updated_at
FROM tasks
WHERE workspace_id = $1 AND status = $2
ORDER BY updated_at DESC, id DESC
LIMIT $3;
```

迁移仅有单列 `workspace_id` 索引。没有生产计划，因此性能结论不是 Confirmed。

- **Trigger**：单工作区任务量显著增长，且 `status` 选择性较低。
- **Impact**：数据库需要过滤并排序较多行，列表 p95 可能上升。
- **Root cause**：现有索引无法同时服务等值过滤和稳定倒序取前 N 条。
- **Minimal fix candidate**：评估 `(workspace_id, status, updated_at DESC, id DESC)`；不要在没有计划和写入成本评估时直接合并。
- **Verification**：准备接近生产分布的数据，比较变更前后的 `EXPLAIN (ANALYZE, BUFFERS)`、索引大小和写入吞吐。
- **Residual risk**：低频状态或软删除条件可能更适合部分索引，需要真实分布决定。

## 4. 必需测试

| Test | Setup | Assertion |
|---|---|---|
| 并发版本冲突 | 两连接读取同一 version 后同时更新 | 一个 200，一个 409；无静默覆盖 |
| 跨租户访问 | tenant A 用户更新 tenant B task | 404/403；数据库无变化 |
| 列表上限 | `limit=10000` | 服务端钳制或拒绝 |
| 稳定分页 | 多条记录相同 `updated_at` | 无重复、无遗漏 |
| 日志脱敏 | 标题包含模拟敏感值 | 日志不出现原值 |

## 5. 建议修复顺序

1. 先修复版本条件更新与并发测试；
2. 再获取查询计划和数据分布，决定复合或部分索引；
3. 补充请求上限和日志字段白名单；
4. 用指标观察 conflict rate、列表 p95 和数据库扫描行数。
