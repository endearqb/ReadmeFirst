---
profile_id: fullstack-foundations
profile_version: "1.0.0"
status: reference
skill_name: fullstack-foundations-guard
canonical_skill_path: extensions/fullstack-foundations/skill/fullstack-foundations-guard
install_skill_path: skills/fullstack-foundations-guard
risk_domains:
  - database
  - transaction
  - concurrency
  - http-network
  - cache-overload
  - runtime-resources
  - authentication-authorization
  - security-privacy
  - migration-release
  - external-side-effects
---

# Full-stack Foundations Profile

## 目的

为浏览器、HTTP、Node.js、数据库、缓存和外部依赖组成的完整请求链路提供项目级风险路由。它防止“接口能返回 200”被误当作生产完成，也防止前端或全栈开发只处理语法和 CRUD，却遗漏索引、事务、并发、资源预算、权限与敏感数据边界。

本 Profile 不替代 DBA、安全审计、SRE 或具体业务专家，也不证明项目天然安全或高性能。

## 触发条件

命中任一时加载：

- Node.js / TypeScript 服务端代码、API 路由、中间件或后台任务；
- SQL、ORM、schema、约束、索引、查询计划或数据库迁移；
- 事务、锁、并发写入、重复请求、幂等、重试或消息发布；
- CORS、Cookie、session、token、HTTP 缓存、超时或取消；
- 缓存、连接池、限流、队列、背压、事件循环或无界批量；
- 认证、对象/动作/字段授权、多租户隔离或敏感数据；
- 外部 API、Webhook、邮件、支付等不可简单回滚的副作用；
- 对上述范围的 PR、commit、架构、事故或培训任务。

## 不触发条件

- 纯文案、静态样式或与服务端和数据无关的 UI 调整；
- 不读取、不修改且不影响服务行为的文档修正；
- 已由更具体项目 Profile 完整覆盖，且该 Profile 明确声明替代本 Profile 的任务。

## 必读上下文

根据任务按需读取：

- `package.json`、锁文件、workspace、Node.js / TypeScript 配置；
- API 路由、中间件、runtime validation、service、repository；
- 数据库 schema、迁移、seed、连接池和 ORM 配置；
- 认证、权限、租户、CORS、Cookie、安全头和日志脱敏；
- 缓存、队列、外部 API 客户端和重试策略；
- 单元、集成、契约、并发、负载和迁移测试；
- CI、Docker、部署、监控和故障恢复入口；
- 用户指定的 branch、commit、PR 或 diff。

未看到某项不等于它不存在；先搜索和追踪调用链，再报告证据缺口。

## 业务不变量与信任边界

1. 客户端不可信，服务端维护最终业务真相。
2. 认证不等于授权；授权覆盖主体、租户、资源、动作和字段。
3. 列表、上传、批量、并发、重试、扇出、队列和响应体都有上限。
4. 并发、重复、超时和部分失败属于正常路径。
5. 关键唯一性和状态约束由数据库约束或原子写入兜底。
6. 事务短且边界清晰，不跨慢速外部调用。
7. 缓存键和失效语义包含租户、权限、版本与可见性上下文。
8. 会话标识、密钥和高敏数据不随意进入浏览器持久存储或日志。
9. Node.js 热路径不包含无界 CPU、同步 I/O 或无界并发。
10. 性能、安全和正确性结论必须有对应证据。

## 执行路由

对应 Skill：`skills/fullstack-foundations-guard/SKILL.md`。

- **Review**：以真实 diff、代码、配置、查询计划、测试和运行结果为证据；只报告可定位 finding，未知项标为待验证假设。
- **Implementation**：编码前写出请求链路、业务不变量、信任边界、资源预算、并发/重复/超时路径和恢复方式。
- **Design**：方案覆盖正常、并发、重复、超时、部分失败、迁移、回滚和可观测性路径。
- **Mentor**：加载 Skill 的 `references/training-handbook.md`，按“概念 → 故障复现 → 修复 → 自动测试 → 证据”教学。

## 最低验证证据

| 风险领域 | 最低证据 | 不接受的替代物 |
|---|---|---|
| `database` | 真实 SQL/ORM 查询、数据规模假设、约束或查询计划；性能变更优先提供 `EXPLAIN (ANALYZE, BUFFERS)` 或指标 | 仅凭列名建议索引 |
| `transaction` | 事务保护的不变量、读写集合、隔离级别、锁对象与锁顺序、冲突处理 | “用了 transaction” |
| `concurrency` | 并发/重复请求测试、原子条件更新、唯一约束或幂等结果复用 | 单线程 happy-path 测试 |
| `http-network` | 请求/响应头、状态码、超时/取消/重试边界及负面用例 | 复制 CORS 或重试代码片段 |
| `cache-overload` | 缓存分区与失效测试、并发上限、连接池/限流/负载指标 | 仅有平均响应时间 |
| `runtime-resources` | 资源上限、事件循环/内存/CPU 证据或最小负载复现 | 类型检查通过 |
| `authentication-authorization` | 未认证、无权、跨租户、对象级和字段级负面测试 | 只验证登录成功 |
| `security-privacy` | 数据流、日志/存储检查、输入边界和安全负面用例 | Scanner 无命中 |
| `migration-release` | 兼容窗口、锁/回填分析、停止条件、验证与恢复方案 | 只有 up migration |
| `external-side-effects` | 幂等键、outbox/状态机或可证明的重复保护；超时未知结果处理 | 对非幂等请求盲目重试 |

## 阻断条件

- 已确认 P0/P1 正确性或安全问题未修复；
- 关键写操作可能重复执行且没有幂等或原子约束；
- 多租户或授权依赖客户端传入的 `userId`、`tenantId`、`role` 等最终信任参数；
- 破坏性迁移没有兼容、停止、恢复和验证方案；
- 无界查询、无界并发或同步热路径可能拖垮服务；
- 敏感数据可能进入日志、URL、浏览器持久存储或不必要响应；
- 性能或安全结论只有关键词扫描，没有调用链和运行证据。

## 项目本地化

安装到目标项目后填写真实命令：

- Install：`<project install command>`
- Format：`<format command>`
- Lint：`<lint command>`
- Typecheck：`<typecheck command>`
- Unit tests：`<unit test command>`
- Integration / concurrency tests：`<integration command>`
- Build：`<build command>`
- Database migration check：`<migration command>`
- Local dependencies：`<docker compose or dev command>`

并删除不适用的触发条件，不得保留空泛占位作为“已经配置”。

## 非目标

- 不规定目标项目必须使用某个 Node 框架、ORM、认证方案或部署平台；
- 不要求所有工程师成为 DBA、安全专家或 SRE；
- 不替代代码所有者对业务规则的确认；
- 不把培训手册和全部 references 默认载入每次任务；
- 不把静态扫描当作漏洞证明或合并判决。
