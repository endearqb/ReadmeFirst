---
name: fullstack-foundations-guard
description: Review, design, implement, and teach production-grade Node.js/TypeScript full-stack work with evidence-based guardrails for PostgreSQL, transactions, concurrency, HTTP/CORS/cache/timeouts/retries, runtime resources, authentication/authorization, sensitive data, observability, testing, and migrations. Use for Node services, APIs, SQL/ORM/schema/migrations, caching, concurrent writes, sessions/tokens, external side effects, or reviews of these risks.
compatibility: Agent Skills-compatible coding agent with repository read/search, shell, test, and optional edit capabilities.
metadata:
  version: "1.0.0"
  language: zh-CN
  category: software-engineering
  readme_first_profile: fullstack-foundations
---

# Full-stack Foundations Guard

## 目标与边界

把浏览器、HTTP、Node.js、数据库、缓存和外部依赖视为一条完整请求链路。不要把“能编译、能返回 200、扫描无命中”当作生产完成。

本 Skill 不覆盖项目 `AGENTS.md`、最近目录 README、项目本地 Profile、代码、schema、配置和测试事实；也不替代 DBA、安全、SRE 或业务所有者。

## 模式

- **Review**：默认只读。基于真实 diff、代码、配置、SQL、查询计划和测试报告 finding；未知项写成待验证假设。
- **Implementation**：编码前建立请求链路、业务不变量、信任边界、资源预算、并发/重复/超时路径和恢复方案；做最小可验证改动。
- **Design**：方案覆盖正常、并发、重复、超时、部分失败、迁移、回滚和可观测性路径，并给出验收门禁。
- **Mentor**：先读 `references/training-handbook.md`，再按导航加载对应专题；使用“概念 → 故障复现 → 修复 → 测试 → 证据”。

## 核心不变量

1. 客户端不可信，服务端维护最终真相。
2. 认证不等于授权；授权覆盖主体、租户、资源、动作和字段。
3. 列表、批量、上传、扇出、并发、重试、队列和响应体都有上限。
4. 并发、重复、超时和部分失败属于正常路径。
5. 关键唯一性和状态约束由数据库约束或原子写入兜底。
6. 事务短且边界清晰，不跨慢速外部调用。
7. 缓存键和失效语义包含租户、权限、版本与可见性上下文。
8. 会话标识、密钥和高敏数据不随意进入浏览器持久存储或日志。
9. Node.js 热路径不包含无界 CPU、同步 I/O 或无界并发。
10. 正确性、性能与安全结论必须有对应证据。

## 执行流程

### 1. 建立证据范围

按需读取：manifest/lockfile、运行时和 TypeScript 配置、API 路由与中间件、runtime validation、service/repository、schema/migrations、连接池、auth/tenant/CORS/Cookie、安全头、缓存/队列/外部客户端、日志/指标/Trace、单元/集成/并发/负载/迁移测试、CI 与部署流程。

信息不足时说明缺口并继续可确认部分；“未看到”不等于“不存在”。

### 2. 建立请求链路与信任边界

```text
client → HTTP/proxy → route/middleware → validation → authentication
→ object/action/field authorization → service → transaction/repository
→ PostgreSQL/cache/queue/external API → response/cache headers
→ logs/metrics/traces
```

至少明确：业务不变量、外部输入、身份/租户/权限、最大输入与资源预算、并发和重复场景、超时未知结果、恢复与回滚。

### 3. 数据库、查询与迁移

检查：

- PK/FK/UNIQUE/CHECK/NOT NULL 是否表达真实不变量；
- 多租户键是否进入约束和查询边界；
- SQL 参数化，动态标识符使用固定白名单；
- 分页、稳定排序、最大 limit、N+1、`SELECT *`、深 offset、无界导出；
- 租户和权限过滤是否在服务端/数据库边界执行；
- ORM 生成的真实 SQL 与查询次数；
- 迁移的锁、表重写、兼容窗口、回填、停止、验证和恢复。

不要仅凭列名建议索引。索引建议必须给出真实查询形状、数据量/分布或证据缺口、当前计划/强证据、候选索引匹配方式、写入和迁移成本、验证方法。可控环境优先使用：

```sql
EXPLAIN (ANALYZE, BUFFERS) ...
```

不要在未知生产写语句上直接执行 `ANALYZE`。

### 4. 事务、并发与幂等

明确事务保护的不变量、读写集合、隔离级别、锁对象与顺序、冲突行为、死锁/序列化失败重试和外部副作用。

必查：丢失更新、先查后写竞争、重复创建/扣款、超卖/配额透支、反向加锁、超时后下游已成功、多实例下进程内锁失效、数据库提交与事件/缓存顺序不一致。

优先使用最小机制：条件 UPDATE、UNIQUE、version/ETag、短事务 `FOR UPDATE`、必要时 Serializable、Idempotency-Key、Outbox。不要默认上分布式锁。

数据库 `40001` / `40P01` 重试整个事务函数；重试有界、有退避，事务体可重放，外部副作用不可隐式重复。非幂等 POST 不得盲目自动重试。

### 5. HTTP、缓存与过载

检查方法、状态码、错误模型、request ID、CORS Origin 白名单与 `Vary: Origin`、凭证与通配符、Cookie `HttpOnly/Secure/SameSite`、CSRF，以及是否把 CORS 错当鉴权。

每个缓存回答：缓存对象、键、tenant/user/permission/locale/version、TTL、失效、允许陈旧度、回源失败、击穿/惊群、命中率与加载指标。敏感响应优先评估 `no-store`；个性化响应不能误入共享缓存。

明确客户端/服务端/数据库/外部 API timeout、取消传播、有限退避和抖动、`Retry-After`、多层重试放大、429/503、限流、并发上限、队列长度、连接池和过载降级。

### 6. Node.js 资源边界

检查同步文件/压缩/加密/child process、大 JSON、ReDoS、无界循环/递归、未限制 `Promise.all`、巨大结果集、流背压、listener/timer/stream/连接泄漏、连接未在 `finally` 释放、CPU 工作未隔离、优雅停机遗漏。“async/await”不是非阻塞证据。

### 7. 安全与隐私

检查运行时输入校验、认证、对象/动作/字段授权、多租户、mass assignment、SQL/命令/路径/模板/URL 注入、SSRF、上传下载、XSS/CSRF、安全头、会话生命周期、浏览器存储、前端构建变量、日志/Trace/分析事件中的秘密与 PII、请求/响应/文件上限、依赖安全配置。

指出缺失的主体、资源、动作和作用域；不要只说“加鉴权”。不要把 grep 或 scanner 命中直接定为漏洞，不要复制真实秘密。

### 8. 测试与观测

按风险选择：业务单测、真实 PostgreSQL 集成测试、API 契约、权限矩阵、并发/幂等、故障注入、负载、迁移和安全负面测试。优先验证最终业务不变量和恢复路径。

最低观测包括 requestId/traceId、route/method/status/duration、稳定 errorCode、查询耗时/行数/连接池等待、重试/冲突/死锁/幂等命中、缓存、下游依赖、event-loop lag/CPU/内存、队列长度。日志不得包含秘密和非必要 PII。

## Scanner 边界

可运行：

```bash
python3 scripts/risk_scan.py <repo-root> --format markdown
```

输出只是候选线索。必须读取调用链、配置、数据流和测试后才能形成 finding；无命中也不是安全证明。

## 合并门禁

已确认下列问题时默认不建议合并，除非用户明确接受且有隔离方案：

- **P0**：跨租户/未授权敏感数据泄露、认证绕过/RCE/公开生产秘密、不可恢复数据破坏或重复高价值副作用、无控制破坏性迁移。
- **P1**：并发稳定破坏关键不变量；无界查询/扇出/事件循环阻塞可拖垮服务；会话标识或秘密进入不安全存储/日志；高风险注入/SSRF/mass assignment；长锁迁移无停止/恢复；POST 重试重复关键副作用。

不接受无证据的“加 Redis/索引/连接池/Serializable/分布式锁/多重试/CORS `*`/Token 放 localStorage/ORM 会自动处理/扫描没报就安全”。

## Finding 质量

每个 finding 包含：严重级别 P0–P3、置信度 Confirmed/High/Medium/Hypothesis、领域、文件/行/SQL/配置/测试证据、触发条件、影响、根因、最小修复、验证方法和残余风险。不要让低价值风格建议淹没高风险问题。

报告按 `references/output-contract.md`；详细审查读 `review-checklist.md`；正反模式读 `patterns-and-antipatterns.md`；来源读 `source-map.md`；示例读 `examples/review-example.md`。

## 完成条件

- 基于真实仓库或明确输入；
- 写出关键不变量和至少一个并发/失败场景；
- 每个高风险结论有证据；
- 数据库建议有查询形状和验证方法；
- 权限建议有主体、资源、动作和作用域；
- 网络建议说明 timeout、retry 与幂等关系；
- 测试覆盖最终状态与恢复路径；
- 未泄露秘密或敏感数据；
- 最终区分确认问题、假设和残余风险。
