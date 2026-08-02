# Full-stack Foundations Review Checklist

> 按风险选择；只报告有代码、配置、SQL、测试或运行证据的问题。

## 1. 建模

- [ ] 定位 branch/PR/diff、允许范围、项目规则和验证命令。
- [ ] 画出 client → HTTP → validation → authn/authz → service → transaction → DB/cache/downstream → response/observability。
- [ ] 写出 actor、tenant、resource、action、field、敏感数据、业务不变量，以及并发、重复、超时、恢复路径。

## 2. 输入与 HTTP

- [ ] 外部输入有运行时校验；请求体、数组、嵌套、批量、上传和响应有上限。
- [ ] 方法、幂等性、状态码、错误模型、稳定分页和兼容性明确。
- [ ] 客户端/API/DB/下游有 timeout；取消传播；仅安全或有幂等保护的临时错误有限重试。
- [ ] Origin 精确白名单；credentials 不与 `*` 组合；Cookie 配置 `HttpOnly/Secure/SameSite` 和 CSRF。
- [ ] CORS 未被当作鉴权；会话标识未长期写 localStorage。

## 3. Node.js 与资源

- [ ] 热路径无同步 I/O、CPU 密集任务、大 JSON、高复杂度正则或无界循环。
- [ ] 无用户输入驱动的无界 `Promise.all`、扇出、队列或响应。
- [ ] Stream/backpressure/error/abort 正确；timer/socket/连接在所有路径释放。
- [ ] 连接池、worker、队列、并发、优雅停机与实例/数据库容量协调。

## 4. 数据库与查询

- [ ] PK/FK/NOT NULL/CHECK/UNIQUE 表达不变量，多租户维度进入约束和查询。
- [ ] SQL 值参数化；动态表/列/排序使用固定白名单。
- [ ] 无无界 `SELECT *`、深 offset、N+1、逐行批量写或加载后权限过滤。
- [ ] 列表有稳定排序/LIMIT；检查 ORM 真实 SQL、查询次数、timeout 和连接释放。
- [ ] 索引建议绑定真实 WHERE/JOIN/ORDER BY/LIMIT、数据量/倾斜和查询计划。
- [ ] 评估写放大、存储、VACUUM、并发创建、失败恢复；不因 Seq Scan 自动判错。

## 5. 事务、并发、幂等

- [ ] 事务不变量、读写集合、隔离级别、锁对象/顺序和外部副作用明确。
- [ ] 事务短且同连接；`40001/40P01` 重试整个可重放事务。
- [ ] 丢失更新用 version/ETag/条件 UPDATE/锁；先查后插由 UNIQUE 兜底。
- [ ] 库存/配额用原子条件写；多对象锁顺序稳定。
- [ ] 命令型 POST 有幂等键；同键不同请求冲突；超时未知结果可查询/恢复。
- [ ] DB 与消息/通知使用 Outbox 或清晰一致性边界；并发测试验证最终不变量。

## 6. 缓存与过载

- [ ] 缓存 key 含 tenant/user/permission/version；TTL、失效、陈旧度和回源失败明确。
- [ ] 个性化/敏感响应不进共享缓存；`private/no-cache/no-store` 使用正确。
- [ ] rate limit、429/503、`Retry-After`、内部并发、队列长度、任务 TTL 和拒绝策略有界。
- [ ] 熔断、bulkhead、早拒绝和饱和度可观测。

## 7. 权限、安全、隐私

- [ ] 服务端检查 actor 对 tenant/resource/action/field 的权限，不信客户端 userId/tenantId/role。
- [ ] 详情、列表、更新、删除、搜索、导出、附件、活动流、后台任务和事件都授权。
- [ ] SQL/shell/path/template/URL 输入受控，用户 URL 防 SSRF。
- [ ] 上传限制大小/数量，服务端识别内容，随机名、隔离存储和受控下载。
- [ ] secrets 不进 Git、前端 bundle、日志、Trace、分析事件或错误响应；敏感字段集中脱敏。
- [ ] Scanner 命中经调用链、配置和复现确认；无命中不作为安全证明。

## 8. 测试、观测、迁移

- [ ] 单元、真实 PostgreSQL 集成、API、权限、并发/幂等、故障注入、负载、安全和迁移测试按风险覆盖。
- [ ] requestId/traceId、route/status/duration/errorCode、query/pool、retry/conflict/deadlock/idempotency、cache/downstream、资源饱和可统计且脱敏。
- [ ] schema 采用 expand → migrate → switch → contract；有兼容窗口、分批回填、lock/statement timeout、停止、验证和恢复。
- [ ] 发布后观察业务不变量、p95、错误、锁、连接池、队列和查询计划。

## 9. 报告

- [ ] Findings 按 P0–P3，标 Confirmed/High/Medium/Hypothesis。
- [ ] 每项有证据、触发条件、影响、根因、最小修复、验证和残余风险。
- [ ] 假设与确认问题分开；未发现问题时说明覆盖范围和证据缺口。
