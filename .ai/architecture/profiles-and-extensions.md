# Risk Profiles and Capability Extensions

> 更新于:2026-08-02

## 1. 设计目标

README First v2.2 将“流程重量”和“专业风险”拆成两个正交维度：

```text
L0 / L1 / L2 → 决定读多少、记多少、报告多深
risk_domains → 决定加载什么 Profile、Skill 和证据
```

这样既不让所有任务默认加载专业百科，也不让小 diff 绕过事务、权限、迁移等高风险机制。

## 2. 三层模型

### Core

`AGENTS.md` 只定义：

- 标准风险领域；
- 路由步骤和优先级；
- changes 证据契约；
- scanner 候选边界。

Core 不包含具体数据库或安全教程。

### Project Profile

目标项目 `.ai/profiles/<id>.md` 定义：

- 触发和不触发条件；
- 项目需要读取的上下文类型；
- 业务不变量和信任边界；
- 最低证据和阻断条件；
- 安装 Skill 路径；
- 项目真实验证命令。

Profile 必须本地化；canonical PROFILE 只是参考模板。

### Reusable Skill

项目 `skills/<name>/` 或宿主 Skill 目录提供：

- Review / Implementation / Design / Mentor 工作流；
- references、scripts、examples；
- 输出契约和完成条件。

Skill 不应假定目标项目使用某个框架，也不能覆盖 Profile。

## 3. Canonical 能力包

`extensions/<pack>/` 把 PROFILE 和 Skill 一起发布：

```text
extensions/<pack>/
├── PROFILE.md
├── README.md
└── skill/<skill-name>/
```

能力包版本独立于 ReadmeFirst 协议版本。安装是显式动作，不属于最小系统。

## 4. 标准风险领域

| 领域 | 关注机制 |
|---|---|
| `database` | 查询、索引、约束、数据模型 |
| `transaction` | 原子性、隔离、锁和死锁 |
| `concurrency` | 竞态、重复、幂等和状态冲突 |
| `http-network` | HTTP、CORS、Cookie、超时、取消、重试 |
| `cache-overload` | 缓存隔离、连接池、限流、背压 |
| `runtime-resources` | CPU、内存、事件循环、同步 I/O、无界资源 |
| `authentication-authorization` | 身份、租户、对象、动作和字段权限 |
| `security-privacy` | 注入、SSRF、敏感数据、日志和保留 |
| `migration-release` | 兼容、锁、回填、停止、恢复和发布 |
| `external-side-effects` | 支付、消息、Webhook 和超时未知结果 |

新增标准领域属于协议变化；项目专属细分优先写入 Profile 内容，不随意扩大全局枚举。

## 5. 安装和升级

安装：

1. 用项目事实确认候选；
2. 复制 PROFILE 到 `.ai/profiles/`；
3. 复制 Skill 到项目 Skill 目录；
4. 本地化路径、命令和触发；
5. 运行 `check-profiles.py`；
6. 用真实任务校准一次。

升级：

- 比较 canonical 和本地 Profile；
- 保留本地更严格规则；
- Skill 可更新通用工作流，但不能覆盖项目命令；
- 记录兼容性、验证和剩余风险。

退役：

- 删除 Profile/Skill 前检查引用；
- 不删除已经沉淀成项目事实的长期知识；
- changes 记录退役原因和替代路径。

## 6. 渐进披露

默认加载顺序：

```text
Profile（短）
  → Skill 主文件
  → 当前任务需要的 checklist / patterns / source map
  → Mentor 或培训任务才加载完整手册
```

不得把所有能力包、references 和培训材料注入每次 Agent 上下文。

## 7. 证据与发现

- Profile 定义最低证据，不直接宣判 finding。
- Skill 负责搜集、解释和验证证据。
- Scanner 只输出候选。
- changes 记录本次风险对应证据。
- Maintainer 统计重复风险并决定是否沉淀到 README、Profile 或 decisions。

## 8. 当前参考实现

`extensions/fullstack-foundations/` 是首个参考能力包，验证该模型能承载数据库、网络、安全和并发等深度知识，同时不增加所有任务的默认上下文成本。
