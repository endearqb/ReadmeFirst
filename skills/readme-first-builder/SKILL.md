---
name: readme-first-builder
description: Initialize or upgrade a project to the README First v2.1 architecture from endearqb/ReadmeFirst. Use when the user asks to 初始化 README First / 安装 README First 框架 / 升级 README First / 升级框架版本 / 建立 AGENTS.md 与 .ai 目录结构 / initialize README First / retrofit a repository with AGENTS.md + README.md + .ai/architecture + .ai/changes + .ai/decisions, or to upgrade an existing README First v1/v2.0 project to the tiered v2.1 protocol. One-time initializer/upgrader only — after that, normal work follows the target project's own AGENTS.md, and periodic upkeep uses readme-first-maintainer instead of this skill.
---

# README First Builder(v2.1)

## 目的

一次性地为目标项目建立或升级 README First v2 分级架构。初始化的产出必须是**轻的**:协议核心短、目录 README 只建 P0、`.ai/` 从最小结构起步。覆盖面的增长交给后续的 `readme-first-maintainer`,不在初始化时追求完整。

不要在项目已有 `AGENTS.md` 之后,把本技能当作日常写 README 的方式。

## 权威来源

- 本技能自带完整模板,**离线优先**:`references/agents-md-template.md`(完整 v2.1 协议)与 `references/templates.md`(根 README 骨架、目录 README、changes、decisions、architecture、plans/glossary/handoff 模板)。
- Canonical 仓库:`https://github.com/endearqb/ReadmeFirst`。有网络时,可对比 `https://raw.githubusercontent.com/endearqb/ReadmeFirst/main/VERSION` 与 `https://raw.githubusercontent.com/endearqb/ReadmeFirst/main/AGENTS.md` 确认是否需要升级;没有网络时直接使用本地模板并在报告中注明。

## 升级模式

若目标项目已有 `AGENTS.md`:

1. 读取首行版本印记(如 `<!-- README First protocol v2.1.0 -->`);无印记则视为 v1 或未初始化。
2. 与 canonical `VERSION` 比较;相同 → 报告"已最新"并结束。
3. 落后则按序应用 `migrations/` 中每个迁移文件(如 v2.0→v2.1),遵循合并规则,不覆盖本地内容。
4. 每完成一个迁移,更新目标 `AGENTS.md` 首行印记;全部完成后报告升级路径与变更摘要。

## 初始化流程

### 第 1 步:扫描目标项目(只读)

1. 确认根目录是否已有 `AGENTS.md`、`README.md`、`.ai/`、如 CLAUDE.md 等 agent 规则文件。
2. 列出顶层目录,排除构建产物、依赖、缓存、日志目录。
3. 用双因子算法选 P0 候选:先运行 maintainer 脚本 `skills/readme-first-maintainer/scripts/dir-hotspots.sh` 输出热度(近 90 天提交触达)与复杂度(文件数/行数/深度/大文件)双因子表。判断:双高 → P0 必建;高热低复杂 → 短 README;高复杂低热 → 待观察列入报告;双低 → 不建。无 git 历史时只用复杂度因子。

### 第 2 步:建立或合并 `AGENTS.md`

- 不存在 → 直接使用 `references/agents-md-template.md` 全文创建,按需替换项目占位内容(验证命令等)。
- 已存在 → **合并,绝不覆盖**:保留项目本地更严格或更具体的规则;把 v2 的分级表(第 0 节)、读取路由(第 2 节)与分级记录(第 5 节)合入;冲突时报告冲突并选择破坏最小的合并方式。
- 从 v1 升级 → 用 v2 模板替换执行协议部分(读取顺序、增删改查、记录规则、输出要求),完整保留项目自定义规则与不确定性协议中项目特化的内容。

### 第 3 步:补全根 `README.md`(项目地图)

确保包含:项目是什么、技术栈、安装/启动/测试/构建命令、顶层目录职责表、指向关键目录 README 与 `.ai/` 的入口说明。保留用户已写的一切内容,只补缺失部分。

### 第 4 步:建立 `.ai/` 最小结构

```txt
.ai/
├── architecture/README.md    # 单文件起步:当前状态摘要 + 跨目录边界,只写现有事实
├── changes/YYYY-MM-DD.md     # 用完整模板记录本次初始化(初始化属 L2)
├── decisions/                # 空目录 + 模板;仅当初始化涉及真实架构取舍时写 0001
├── glossary.md               # 术语表占位(按需启用)
├── handoff.md                # 会话交接占位(按需启用)
└── plans/                    # 计划目录(按需启用)
    └── done/
```

`.ai/architecture/` 起步只放一个 README.md;超过约 150 行或出现独立主题时由 maintainer 拆分。所有生成文档的标题下写入时效戳 `> 更新于:YYYY-MM-DD · commit <short-sha>`。

### 第 5 步:建立 P0 目录 README(上限 3–7 个)

- 只覆盖:第 1 步识别出的高频核心目录 + 公共能力目录(api/types/store/hooks 等,如确实存在且被广泛依赖)。
- 使用 `references/templates.md` 中的目录模板;信息不足的节直接删除,**不写空泛占位句**。所有内容必须来自对当前代码的实际观察,不得凭空编造职责或约定。
- 其余目录留给日常任务顺手补建(AGENTS.md 第 2 节)和 maintainer 渐进覆盖。

### 第 6 步:创建术语表(可选)

扫描中若发现 ≥3 个明显领域术语,用 `references/templates.md` 中的 glossary 模板创建 `.ai/glossary.md` 并预填词条;否则保留带表头的空文件。

### 第 7 步:记录、验证、报告

1. 在 `.ai/changes/` 记录本次初始化(L2 完整模板)。
2. 验证:生成文档中引用的所有路径和命令真实存在;确认没有覆盖任何已有文件内容。
3. 输出报告:建立了什么、合并了什么、P0 覆盖了哪些目录、遗留了哪些待 maintainer 处理的缺口。

## 已有文件规则

- 绝不盲目覆盖已有 `AGENTS.md` 或 `README.md`;用户手写的内容一律保留。
- 已有项目规则视为本地权威,除非它与安全或用户明确要求冲突。
- 上游协议与本地规则冲突时,报告冲突,选择破坏最小的合并。

## 交接

结束时明确告知:此后日常任务遵循目标项目自己的 `AGENTS.md`(按 L0/L1/L2 分级执行);建议每 2–4 周或变更记录累积约 15 条后,运行 `readme-first-maintainer` 做巡检、压缩与沉淀。不要为后续普通任务再次触发本技能。
