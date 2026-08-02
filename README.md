# README First

**面向所有 AI Agent 的项目上下文与风险能力路由协议（v2.2 · 风险 Profile 版）**

本文件回答“为什么”和“从哪里读起”；`AGENTS.md` 规定“怎么做”。任何 Agent 开始任务时，只需先读 `AGENTS.md` 第 0 节最小闭环，其余内容按任务级别和风险领域渐进加载。

---

## 一句话定义

> 先读上下文，再执行操作；先收敛不确定性，再修改文件；流程重量随任务影响缩放，专业能力随风险领域加载。

README First 适用于 Claude Code、Cursor、Codex、Copilot、Devin 以及任何能读写仓库的自动化工具，不绑定特定厂商。

v2.2 在 v2.1 的 L0/L1/L2 分级执行之上增加第二个独立维度：

- **任务级别**决定读取范围、任务契约、记录深度和最终报告；
- **风险领域**决定需要加载哪个项目 Profile、专业 Skill、检查清单和验证证据。

它避免两个常见极端：低风险任务被繁重协议拖慢，以及“只改一个文件”的高风险修改绕过数据库、并发、网络或安全门禁。

---

## 为什么需要它

当 AI Agent 进入真实工程流程，瓶颈已经从“能不能生成代码”转向三件事：

1. **是否理解项目**：目录为什么存在，边界在哪里，哪些规则只存在于历史记录和维护者经验中；
2. **是否识别失败机制**：事务、并发、缓存、权限、迁移和外部副作用不会因为代码能编译就自动正确；
3. **是否留下可复核证据**：测试、查询计划、并发复现、迁移演练和安全负面用例必须与风险一一对应。

README First 把这些问题转化为工程制度：让每次工作沿稳定路径获取上下文，让高风险任务加载匹配的专业能力，并把新的长期知识沉淀回项目。

---

## 系统组成

### 目标项目的最小系统

```text
project/
├── AGENTS.md                 # 分级执行 + 风险领域路由
├── README.md                 # 项目地图：是什么、怎么跑、从哪读起
├── VERSION                   # README First 协议版本（按需同步）
├── .ai/
│   ├── architecture/         # 当前稳定架构知识层
│   ├── changes/              # L1/L2 变更原因、风险和验证证据
│   │   └── YYYY-MM-DD.md
│   ├── decisions/            # 长期架构决策
│   ├── glossary.md           # 术语表（按需启用）
│   ├── handoff.md            # 会话交接（按需启用）
│   ├── plans/                # 复杂任务计划（按需启用）
│   │   └── done/
│   └── profiles/             # 项目本地风险 Profile（按需启用）
├── skills/                   # Profile 指向的专业 Skill（按需启用）
└── src/
    └── README.md             # 只为关键目录建立，P0 优先
```

### Canonical ReadmeFirst 仓库的能力包

```text
ReadmeFirst/
├── extensions/
│   ├── README.md             # 能力包契约和安装规则
│   ├── profile-template.md   # Profile 模板
│   └── <capability-pack>/
│       ├── PROFILE.md
│       ├── README.md
│       └── skill/<skill-name>/
└── skills/
    ├── readme-first-builder/
    └── readme-first-maintainer/
```

各层职责：

| 层 | 职责 |
|---|---|
| `AGENTS.md` | 行为协议：任务分级、风险路由、读取规则、不确定性协议、记录规则 |
| 根 `README.md` | 项目地图：项目是什么、技术栈、安装/测试/构建、顶层目录职责 |
| 目录 README | 局部契约：目录职责、核心文件、依赖边界、验证方式 |
| `.ai/architecture/` | 当前稳定架构、跨目录边界、Profile 与 Skill 架构 |
| `.ai/profiles/` | 项目本地风险路由、触发条件、业务不变量、阻断条件、最低证据 |
| 项目 `skills/` | 可复用专业工作流、references、scripts 和示例 |
| `.ai/changes/` | 为什么改、风险是什么、基于什么假设、如何验证 |
| `.ai/decisions/` | 为什么长期这样选 |
| canonical `extensions/` | 可选能力包的发布与分发，不自动进入下游最小系统 |

---

## 两个独立维度

### 任务级别：流程重量

```text
L0 轻量 → 几乎无感
L1 标准 → 局部上下文 + 短记录
L2 高影响 → 完整契约 + 风险证据 + 长期文档核对
```

### 风险领域：专业能力

标准领域包括：

```text
database
transaction
concurrency
http-network
cache-overload
runtime-resources
authentication-authorization
security-privacy
migration-release
external-side-effects
```

一项任务可以是“L1 + database”，也可以是“L2 + transaction + concurrency + external-side-effects”。风险领域不是严重级别，而是失败机制和能力路由标签。

---

## 核心设计原则

### 1. 先读后改，够用即停

读取有明确停止条件：影响本次任务的偶然不确定性已经消除，并取得风险领域要求的最低证据后停止。README First 要求“读到够用”，不是“读完全部”。

### 2. 协议重量与任务影响成正比

错别字和公共 API 不应支付相同流程成本。L0/L1/L2 只管理上下文、记录和报告重量，不负责替代专业判断。

### 3. 任务级别与风险领域分离

“改动小”不等于“风险低”。一个单文件事务修复可能是 L2；一个普通 Node 查询接口可能是 L1，但仍需数据库、权限和资源边界检查。

### 4. Profile 路由，Skill 执行

Profile 是项目本地契约，说明何时触发、读什么、守住哪些不变量、需要什么证据；Skill 是可复用专业工作流。Profile 优先于通用 Skill，二者都不能覆盖更具体的项目事实。

### 5. 渐进披露，不把知识库塞进每次上下文

Agent 先读短 Profile，再按当前任务加载 Skill 主文件和必要 references。培训手册、模式库和扫描脚本只在需要时读取或运行。

### 6. 证据与风险对应

数据库性能结论需要查询计划或指标；并发正确性需要并发测试或原子约束；安全结论需要负面权限用例和数据流证据；迁移需要兼容、停止、恢复和验证方案。

### 7. 扫描器只能发现候选

关键词和静态扫描命中不是已确认缺陷；扫描无命中也不是安全证明。Agent 必须回到调用链、配置、数据流、权限边界和运行证据。

### 8. 平时轻记录，定期重整理

日常任务追加轻量记录；Maintainer 定期做漂移巡检、changes 压缩、知识沉淀、协议校准，以及 Profile/Skill/证据治理。

---

## 标准执行流程

```text
定级 L0/L1/L2
  → 读取项目上下文
  → 识别风险领域
  → 加载已安装 Profile / Skill
  → 建立任务契约、业务不变量与证据计划
  → 实现或审查
  → 运行验证
  → 写入 changes / README / architecture / decisions
```

低风险任务不会因为 v2.2 变重；只有命中专业风险且项目安装了相应 Profile 时，才加载额外能力。

---

## 生命周期与能力包

1. **初始化或升级 — `skills/readme-first-builder/`**
   建立或合并 `AGENTS.md`、根 README、`.ai/` 最小结构和 P0 目录 README；扫描技术栈事实并给出能力包候选。默认不静默安装大型能力包。

2. **日常执行 — 目标项目的 `AGENTS.md` + `.ai/profiles/`**
   常规任务按 L0/L1/L2 执行；命中风险领域时加载本地 Profile 和对应 Skill。

3. **定期维护 — `skills/readme-first-maintainer/`**
   每 2–4 周、changes 累积到阈值或大重构后运行，负责文档健康、记忆压缩、知识沉淀、协议校准和 Profile/Skill 证据治理。

4. **可选能力包 — canonical `extensions/`**
   能力包独立版本化、按需安装。首个参考能力包是 `extensions/fullstack-foundations/`，覆盖 Node.js、PostgreSQL、事务并发、HTTP、缓存、安全和迁移。

---

## 首个参考能力包：Full-stack Foundations

`extensions/fullstack-foundations/` 包含：

- `PROFILE.md`：风险领域、触发条件、必读上下文、业务不变量、阻断条件和证据矩阵；
- `fullstack-foundations-guard` Skill：Review、Implementation、Design、Mentor 四种模式；
- 全栈培训手册：数据库、事务、并发、网络、安全、运行时和可观测性；
- 正反模式库、审查清单、输出契约和候选风险扫描器。

它不是 ReadmeFirst Core 的强制依赖，也不会默认装入所有项目。

---

## 版本与升级

本仓库协议版本见根 `VERSION`。下游项目 `AGENTS.md` 首行使用：

```text
<!-- README First protocol vX.Y.Z -->
```

Builder 按 `migrations/` 顺序升级并保留本地更严格规则。v2.1 → v2.2 的升级见 `migrations/v2.1-to-v2.2.md`。

---

## 验证

仓库提供无第三方依赖的验证入口：

```bash
bash tests/test-maintainer-scripts.sh
python3 tests/validate_repository.py
python3 -m py_compile \
  extensions/fullstack-foundations/skill/fullstack-foundations-guard/scripts/risk_scan.py
```

GitHub Actions 会运行相同的基础检查。

---

## 好 README、Profile 与 Skill 的标准

- **README**：准确、短、可操作、有边界、有入口、有验证；
- **Profile**：触发条件明确、风险领域有限、项目本地化、证据可验证；
- **Skill**：主文件精炼，详细材料渐进加载，扫描结果不冒充结论；
- **长期文档**：只记录六个月后仍有价值的职责、边界、规则和决策。

不为 `node_modules/`、`dist/`、`build/`、`coverage/`、缓存、日志或临时目录创建 README。

---

## 与现有实践的关系

- **传统 README**：扩展而非否定，同时服务人类和 Agent；
- **ADR**：`.ai/decisions/` 保留长期选择及其原因；
- **Git**：diff 记录“改了什么”，changes 记录“为什么、风险和证据”；
- **测试**：README First 管理理解和路由，测试验证行为；
- **安全/性能扫描**：作为证据来源之一，不能替代工程判断；
- **专业 Skill**：提供深度能力，但由项目 Profile 决定何时加载。

---

## 结论

README First 的本质不是“多写 README”，而是建立一套可负担、可验证、可扩展的 AI 工程协作协议：

> 让 AI 先理解项目，再改变项目；让高风险任务调用匹配的专业能力；让每一次改变都留下可复核证据，并反过来增强项目的可理解性。
