# Patterns and Antipatterns

> 示例用于解释失败机制和最小修复，不是可直接复制到所有框架的完整实现。先适配项目已有的事务、错误、认证、日志和测试抽象。

## 1. 类型不是运行时校验

**反模式**

```ts
const input = request.body as CreateIssueInput;
```

TypeScript 不会阻止缺失字段、超长数组、错误类型或额外敏感字段。

**模式**

```ts
const input = createIssueSchema.parse(request.body);
await issueService.create(actor, input);
```

验证错误类型、未知字段、字符串/数组上限和枚举。

## 2. SQL 值参数化，标识符白名单

```ts
await db.query(
  'SELECT id, email FROM users WHERE email = $1',
  [email],
);
```

排序列不能直接参数化，必须映射固定允许值；禁止拼接客户端 SQL 片段。

## 3. 稳定分页与匹配查询形状的索引

**反模式**

```sql
SELECT * FROM issues
WHERE workspace_id = $1
ORDER BY updated_at DESC;
```

**模式**

```sql
SELECT id, title, state, updated_at
FROM issues
WHERE workspace_id = $1
  AND project_id = $2
  AND deleted_at IS NULL
  AND (updated_at, id) < ($3::timestamptz, $4::uuid)
ORDER BY updated_at DESC, id DESC
LIMIT $5;
```

候选索引必须结合数据分布和计划验证：

```sql
CREATE INDEX CONCURRENTLY idx_issues_active_project_updated
ON issues (workspace_id, project_id, updated_at DESC, id DESC)
WHERE deleted_at IS NULL;
```

记录前后 `EXPLAIN (ANALYZE, BUFFERS)`、索引大小和写入成本。

## 4. 业务唯一性进入数据库

“先查是否存在再插入”存在并发窗口。用 `UNIQUE (tenant_id, business_key)` 兜底；捕获唯一冲突并按业务语义返回幂等成功或 409。

## 5. 乐观并发控制

```sql
UPDATE issues
SET title = $3,
    version = version + 1,
    updated_at = now()
WHERE tenant_id = $1
  AND id = $2
  AND version = $4
RETURNING id, title, version;
```

0 行表示版本冲突或不可见资源。并发测试要求相同旧版本最多一个成功，另一个得到稳定冲突结果。

## 6. 原子库存/配额扣减

```sql
UPDATE inventory
SET available = available - $2
WHERE sku = $1
  AND available >= $2
RETURNING available;
```

不要“先读库存再写回”。用并发测试证明最终 `available >= 0`。

## 7. 统一锁顺序并重试整个事务

多对象写入按稳定 ID 排序后加锁，避免 A→B 与 B→A。遇到 SQLSTATE `40001` / `40P01`，创建新事务重试整个事务函数；重试有限、有退避，事务体可重放，外部副作用不可隐式重复。

## 8. 外部副作用使用 Outbox

不要在数据库事务中发送邮件、Webhook 或调用支付 API。事务内写业务状态和 outbox 事件，独立发布器发送，消费者按 event ID 幂等。

## 9. 幂等 POST

稳定幂等键的记录至少包含 tenant、key、请求哈希、状态、响应和过期时间，并以 `(tenant_id, idempotency_key)` 唯一：

- 同键同哈希：返回原结果；
- 同键不同哈希：409；
- 执行中：等待、202 或稳定冲突策略；
- 业务表仍保留真实唯一约束。

## 10. CORS 不是鉴权

禁止 `origin: '*'` 与 credentials 混用。动态 Origin 使用精确白名单并返回 `Vary: Origin`。Cookie 会话还要配置 `HttpOnly`、`Secure`、合适 `SameSite` 和 CSRF 防护。

## 11. 缓存按数据语义分区

- 高敏响应：优先 `Cache-Control: no-store`；
- 个性化响应：`private`，必要时配 ETag 重新验证；
- 哈希静态资源：`public, max-age=31536000, immutable`。

服务端缓存键包含 tenant/user/permission/locale/version；明确 TTL、失效、允许陈旧度、回源失败和击穿防护。

## 12. 超时、取消与重试

```ts
async function fetchWithTimeout(
  url: string,
  init: RequestInit,
  timeoutMs: number,
): Promise<Response> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    return await fetch(url, { ...init, signal: controller.signal });
  } finally {
    clearTimeout(timer);
  }
}
```

完整实现还要合并调用者 signal、限制响应大小、分类错误、尊重 `Retry-After`，并处理“下游可能已成功”的未知结果。只有临时错误且方法安全/有幂等保护时才有限重试。

## 13. 限制并发而非无界 `Promise.all`

```ts
if (ids.length > 100) throw new InvalidInputError('too many ids');
await mapLimit(ids, 8, load);
```

并发上限来自下游预算、连接池和负载证据，不是随意常量。

## 14. Node.js 热路径避免同步和大对象

禁止请求热路径中的同步文件/压缩/加密/child process、大 JSON、无界循环和 ReDoS。使用异步/流式 I/O，处理背压；CPU 密集任务进入 worker 或队列；监控 event-loop lag。

## 15. 对象级与字段级授权

不要只检查“已登录”后按全局 ID 取对象。将 tenant、actor、resource、action 和 field 放入 repository/service 授权边界，并覆盖详情、列表、更新、删除、导出、附件和活动流。

## 16. 防止 Mass Assignment

```ts
const input = updateProfileSchema.parse(request.body);
await repo.updateProfile(userId, {
  displayName: input.displayName,
  avatarUrl: input.avatarUrl,
});
```

管理员字段使用独立命令、独立权限和审计，不能展开 `request.body` 直接更新 ORM。

## 17. 会话与浏览器存储

典型 Web 会话优先评估服务端设置的 `HttpOnly`、`Secure` Cookie，并实施 CSRF、过期、轮换和撤销。不要把 access token、完整用户对象或敏感权限信息长期写入 localStorage。

## 18. 结构化且脱敏的日志

记录 requestId、tenantId/actorId 的内部标识、route、method、status、duration、errorCode、query ID 和下游耗时。集中 redaction Authorization、Cookie、密码、Token、密钥和非必要 PII；不要记录完整 headers/body。

## 19. SSRF

对用户 URL：限制协议和域名；DNS 解析后阻断 loopback、link-local、私网和云元数据；限制并重新验证重定向；设置 timeout、响应大小和内容类型；必要时使用隔离出口。字符串前缀判断不足。

## 20. 文件上传

限制数量/大小；服务端识别内容；随机对象名；隔离存储；受控下载；恶意内容扫描；清理失败/过期上传；转换任务放隔离 worker。不要信任扩展名/MIME 或把原文件名直接放 Web 目录。

## 21. 安全迁移：expand → migrate → switch → contract

先增加兼容结构，再双读/双写或适配，分批回填，切换读取，观察，停止旧写，最后清理。每一步有停止、验证和恢复方式；不要在滚动发布中一次性重命名关键列。

## 22. Finding 写法

低质量：

> 建议优化数据库索引，否则可能慢。

高质量 finding 必须说明：真实查询形状、文件/行或计划证据、触发数据规模、影响、根因、候选修复、写入/迁移代价、验证命令和残余风险。无法取得生产分布时，将结论标为 High/Medium/Hypothesis，而不是伪装 Confirmed。
