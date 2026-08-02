---
name: readme-first-maintainer
description: Periodic maintenance for projects using README First v2.2. Audits documentation drift and dead paths, compacts .ai/changes, distills long-term knowledge, tunes L0/L1/L2 thresholds, and validates risk Profiles, Skill bindings, and evidence coverage. Use after major refactors, every 2–4 weeks, when changes accumulate, or when agents repeatedly report doc-code/profile-skill conflicts. Do not use for initialization/upgrades or ordinary coding tasks.
compatibility: Agent Skills-compatible coding agent with repository read/search, shell, and optional documentation edit capabilities.
metadata:
  version: "2.2.0"
  language: zh-CN
  category: software-engineering
---

# README First Maintainer（v2.2）

## 目的

README First 的日常协议保持轻量：L0 不记录，L1 短记录，专业能力按风险领域加载。被卸下的系统性负担集中到本 Skill 定期处理：

1. 文档与路径健康巡检；
2. changes 记忆压缩；
3. 长期知识沉淀；
4. L0/L1/L2 协议校准；
5. Profile、Skill 和风险证据治理。

本 Skill 只维护文档、记录和能力路由系统，不修改业务代码。发现业务问题时列入报告，由用户决定后续工作。

## 总流程

```text
读取项目 AGENTS / architecture / profiles
  → 只读巡检并生成发现
  → 直接修复低风险文档事实
  → 归档、删除、协议或 Profile 结构调整先列待确认
  → 写入 changes
  → 输出维护报告
```

默认执行全部五个工作流；用户点名时只执行相应部分。

## 开始前

1. 读取目标项目 `AGENTS.md` 第 0 节、根 README 和 `.ai/architecture/`。
2. 若 `.ai/profiles/` 存在，读取 Profile frontmatter、触发条件和 Skill 路径。
3. 确认维护任务级别；普通巡检为 L1，协议、Profile Schema 或长期架构调整为 L2。
4. 先运行只读脚本，再由 Agent 结合项目事实判断；脚本输出不是最终结论。

---

## 工作流 1：健康巡检（Audit）

### 1a. 失效引用

```bash
./skills/readme-first-maintainer/scripts/check-paths.sh .
```

- `DEAD` 进入发现清单；
- 区分真实失效路径、模板占位和代码示例误报；
- 抽查文档声明的命令是否仍存在。

### 1b. 新鲜度与时效戳

```bash
./skills/readme-first-maintainer/scripts/check-freshness.sh .
```

检查：

- `NO-STAMP`；
- `INVALID-STAMP`；
- `STALE(<days>d)`；
- 文档职责、核心文件和验证命令是否与当前实现一致。

v2.2 标准时效戳：

```md
> 更新于:YYYY-MM-DD
```

旧 v2.1 格式兼容，但不得把修改前 commit 冒充文档所属提交。

### 1c. 覆盖缺口

```bash
./skills/readme-first-maintainer/scripts/dir-hotspots.sh .
```

脚本语义：

- 热度 = 近 90 天触达目录的唯一 commit 数；
- 复杂度 = 递归相关文件数 + 行数/200 + 内部最大深度 + 大文件权重。

双高建议 P0 README；高热低复杂建议短 README；高复杂低热观察；双低跳过。

### 1d. 其他健康检查

- `AGENTS.md` 版本印记与上游 `VERSION`；
- Builder 离线模板与根 `AGENTS.md` 同步；
- migration 链连续；
- glossary 术语与代码命名；
- handoff 超过 14 天；
- plans 超过 30 天未归档；
- 文档中仍引用已移除的 Profile、Skill 或能力包。

---

## 工作流 2：记忆压缩（Compact）

触发条件：

- `.ai/changes/` 日文件约 15 个以上；
- 存在 30 天以前的日文件；
- 大重构后历史记录已经明显重复或互相覆盖。

保留最近 30 天原始记录。更早记录按月生成：

```md
# YYYY-MM 变更摘要

- MM-DD <标题> [级别] [风险领域]：结果；长期影响；证据或剩余风险。
```

规则：

1. 保留最终结果、长期有效假设、风险领域和剩余注意事项；
2. 丢弃过程性调试和已被后续变更推翻的内容，注明取代关系；
3. 原文件移入 `.ai/changes/archive/`，未经确认不删除；
4. Profile / Skill 安装、升级和停用必须保留；
5. 候选长期知识交给工作流 3。

---

## 工作流 3：知识沉淀（Distill）

从 changes、事故记录和反复出现的 finding 中寻找：

| 模式 | 沉淀位置 |
|---|---|
| 同一目录约定、维护提示、反复踩坑 | 最近目录 README |
| 跨目录边界、当前稳定状态 | `.ai/architecture/` |
| “为什么选 A 不选 B”且长期有效 | `.ai/decisions/` |
| 稳定领域术语与别名 | `.ai/glossary.md` |
| 某风险反复触发且项目需要本地门禁 | `.ai/profiles/` |
| 可跨项目复用的专业工作流 | 先形成能力包候选，不直接塞入 Core |

每条沉淀知识必须可追溯到代码、配置、测试或 changes 证据。未经验证的猜测不能晋升。

---

## 工作流 4：协议校准（Tune）

检查：

1. `[L1]` / `[L2]` 实际分布是否符合定义；
2. 高影响任务是否被低报；
3. changes 字段是否长期为空；
4. 风险领域是否被机械滥用或长期遗漏；
5. L0 是否因 Profile 路由被不必要地拖重；
6. 访谈、计划和 handoff 触发是否符合实际成本。

若在 canonical ReadmeFirst 仓库运行：

- 根 `AGENTS.md` 与 Builder `references/agents-md-template.md` 必须同步；
- 协议变化同步 `VERSION`、migration、README、architecture、Builder、Maintainer；
- Profile Schema 变化同步 `extensions/profile-template.md` 和验证脚本。

协议调整属于 L2，需要决策记录和迁移说明。

---

## 工作流 5：Profile 与风险证据治理

仅当项目存在 `.ai/profiles/`、已安装专业 Skill，或 canonical 仓库存在 `extensions/` 时执行。

### 5a. 结构与引用

先运行结构校验：

```bash
python3 skills/readme-first-maintainer/scripts/check-profiles.py .
```

再结合项目事实检查：

- Profile frontmatter 必填字段；
- `profile_id` 与文件名/能力包标识是否一致；
- `risk_domains` 是否只使用项目标准领域；
- `install_skill_path/SKILL.md` 是否存在；
- Profile 与 Skill 版本是否在声明的兼容范围；
- Profile 是否引用已删除的命令、目录、框架或数据源。

Canonical 仓库运行：

```bash
python3 tests/validate_repository.py
```

### 5b. 触发质量

- 触发条件是否能从任务、路径、依赖或配置事实判断；
- 是否因为一个弱信号就加载大型能力包；
- 不触发条件是否防止文案、静态样式等低风险任务被拖重；
- 更具体本地 Profile 是否正确优先于通用 Skill。

### 5c. changes 证据覆盖

抽查 L2 changes：

- 是否记录风险领域；
- 是否记录使用的 Profile / Skill；
- 是否写出业务不变量和信任边界；
- 正确性、性能/资源、并发/重复、安全/隐私、迁移/恢复是否按适用性给出证据；
- “不适用”是否真实，而非规避验证。

### 5d. 漂移和退役

- 技术栈已移除但 Profile 仍激活 → 建议停用；
- 同一 Profile 被大量本地修改 → 建议形成本地派生版本；
- 能力包多年未触发或长期制造噪声 → 建议降级、拆分或卸载；
- 卸载只删除路由与 Skill，不删除已经沉淀为项目事实的 README/decisions 知识。

---

## 直接修复与待确认边界

可直接执行：

- 明确失效路径；
- 错误日期或事实性描述；
- 与根协议同步的模板副本；
- 已有证据支持的 README 核心文件表修正；
- Profile 中明显失效且有唯一正确替代的路径。

必须先列待确认：

- 删除、归档、重写大量文档；
- 改变 L0/L1/L2 阈值；
- 新增、停用或拆分 Profile；
- 替换 Skill 或改变阻断条件；
- 修改能力包版本和兼容策略；
- 任何可能影响业务代码或发布流程的动作。

## 维护报告模板

```md
# README First 维护报告 YYYY-MM-DD

## 概览
巡检范围 / 总体结论 / 使用的协议版本

## 健康发现
- 失效引用：
- 文档漂移：
- 覆盖缺口：
- 版本与迁移：
- 术语 / handoff / plans：

## Profile 与证据治理
- Profile / Skill 引用：
- 触发质量：
- L2 证据覆盖：
- 待停用或升级能力包：

## 已直接修复
## 待确认
## 压缩与沉淀
## 协议校准建议
## 验证证据
```

## 边界与禁止行为

- 不修改业务代码；
- 不发明项目事实；
- 不把 scanner 候选升级为确认 finding；
- 不因存在 Profile 就默认加载所有 references；
- 未经确认不删除、停用能力包或改写大量手写文档；
- 单次维护过大时分轮，优先处理可信性和高风险漂移。

## 建议频率

每 2–4 周一次；或 changes 约 15 个日文件后；或大重构、迁移、权限调整、能力包升级后。报告末尾根据发现量给出下次维护触发条件。
