---
name: readme-first-builder
description: Initialize or upgrade a project to the README First v2.2 architecture from endearqb/ReadmeFirst. Use when the user asks to initialize, install, retrofit, or upgrade README First; establish AGENTS.md, README.md, .ai architecture/changes/decisions; add risk-domain routing and optional .ai/profiles; or migrate a v1/v2.0/v2.1 project without overwriting local rules. One-time initializer/upgrader only—normal work follows the target project's AGENTS.md and periodic upkeep uses readme-first-maintainer.
compatibility: Agent Skills-compatible coding agent with repository read/search, shell, and edit capabilities.
metadata:
  version: "2.2.0"
  language: zh-CN
  category: software-engineering
---

# README First Builder（v2.2）

## 目的

一次性为目标项目建立或升级 README First v2.2：

- 轻量的 L0/L1/L2 执行协议；
- 项目上下文层与证据记录；
- 任务级别和风险领域的二维路由；
- 可选 `.ai/profiles/` 与专业 Skill 安装通道；
- P0 关键目录 README 的渐进覆盖。

初始化产出必须保持轻量。不要把培训手册、完整 checklist 或所有能力包静默复制到每个项目。

已有 `AGENTS.md` 后，普通开发任务遵循目标项目自己的规则；不要再次触发本 Builder。

## 权威来源与离线能力

- 本 Skill 自带核心模板：
  - `references/agents-md-template.md`
  - `references/templates.md`
  - `references/profile-catalog.md`
- 目录热点脚本自包含于 `scripts/dir-hotspots.sh`，不依赖 maintainer 已安装。
- Canonical 仓库：`endearqb/ReadmeFirst`。
- 有网络时可比较 canonical `VERSION`；无网络时使用本地模板并在报告中注明基线版本。
- 能力包本体不嵌入 Builder。只有目标环境能访问 canonical `extensions/` 或用户提供能力包文件时，才执行复制安装。

## 升级模式

若目标项目已有 `AGENTS.md`：

1. 读取首行版本印记；无印记视为 v1 或未初始化。
2. 与 Builder 自带版本和可用 canonical 版本比较。
3. 按序应用 `migrations/`：
   - v1 → v2.0
   - v2.0 → v2.1
   - v2.1 → v2.2
4. 保留项目本地更严格、更具体的规则；冲突时报告，不覆盖。
5. 每完成一个迁移更新版本印记；最终运行路径、模板和 Profile 引用验证。

## 初始化流程

### 第 1 步：扫描目标项目（只读）

确认：

- 根 `AGENTS.md`、`README.md`、`.ai/`、CLAUDE.md 等 Agent 规则；
- 顶层目录、技术栈 manifest、数据库 schema、服务端入口、测试和 CI；
- 构建产物、依赖、缓存、日志目录并排除；
- 当前 branch、工作区状态和可用验证命令。

不得只凭目录名推断业务职责、风险领域或技术栈。

### 第 2 步：选择 P0 目录

运行 Builder 自带脚本：

```bash
./skills/readme-first-builder/scripts/dir-hotspots.sh .
```

脚本输出热度 × 复杂度：

- 热度：近 90 天触达该目录的**唯一 commit 数**；
- 复杂度：递归文件数、代码/文档行数、目录内部最大深度和大文件综合评分。

选择原则：

- 双高 → P0 必建；
- 高热低复杂 → 短 README；
- 高复杂低热 → 待观察；
- 双低 → 跳过。

无 git 历史时只使用复杂度，并明确证据缺口。P0 初始上限通常为 3–7 个。

### 第 3 步：建立或合并 `AGENTS.md`

- 不存在 → 使用 `references/agents-md-template.md`，删除同步注释后创建。
- 已存在 → 合并，绝不覆盖：
  - L0/L1/L2 分级；
  - 按需读取和不确定性协议；
  - 风险领域与 Profile/Skill 路由；
  - changes 证据模板；
  - 禁止把 scanner 命中当作确认 finding。
- 保留目标项目的安全、发布、代码所有权、验证命令等本地规则。
- 不因为安装一个能力包就把其完整 Skill 内容复制进 `AGENTS.md`。

### 第 4 步：补全根 `README.md`

只补缺失项：

- 项目是什么；
- 技术栈；
- 安装、启动、测试、构建；
- 顶层目录职责；
- README First 入口；
- 已安装 Profile / Skill 的短索引（如有）。

保留用户已有内容，不把根 README 改成目录百科。

### 第 5 步：建立 `.ai/` 最小结构

```text
.ai/
├── architecture/README.md
├── changes/YYYY-MM-DD.md
├── decisions/
├── glossary.md          # 按需启用
├── handoff.md           # 按需启用
└── plans/done/          # 按需启用
```

`.ai/profiles/` 只有在实际安装至少一个 Profile 时才创建。

文档时效戳使用：

```md
> 更新于:YYYY-MM-DD
```

不要写尚未存在的“本次 commit SHA”。

### 第 6 步：建立 P0 目录 README

使用 `references/templates.md`：

- 内容来自当前代码和配置事实；
- 信息不足的节直接删除；
- 至少包含职责、核心文件、测试与验证；
- 不为 build、dist、coverage、cache、logs、tmp 等目录建 README。

### 第 7 步：风险领域发现（只读）

从真实文件建立证据表，例如：

| 证据 | 可能领域 | 说明 |
|---|---|---|
| Node 服务入口、API 路由 | `http-network`、`runtime-resources` | 仅有前端 `package.json` 不足以证明存在服务端 |
| PostgreSQL schema / migrations | `database`、`migration-release` | 需确认真实数据库和执行路径 |
| auth / tenant middleware | `authentication-authorization` | 需追踪服务端信任边界 |
| cache / queue / external client | `cache-overload`、`external-side-effects` | 需确认是否在生产路径使用 |

输出能力包候选和证据文件。默认只建议，不静默安装。

### 第 8 步：可选安装 Profile 与 Skill

只有用户明确选择、项目策略要求，或初始化请求已明确包含能力包安装时执行。

1. 读取 `references/profile-catalog.md`。
2. 确认能力包文件真实可用。
3. 复制：

```text
<pack>/PROFILE.md                         → .ai/profiles/<profile-id>.md
<pack>/skill/<skill-name>/               → skills/<skill-name>/
```

4. 本地化 Profile：真实路径、命令、触发条件、风险领域。
5. 验证 `install_skill_path/SKILL.md` 存在。
6. 不覆盖已安装 Skill 的本地修改；升级时先比较并报告差异。

### 第 9 步：术语表、计划和交接（按需）

- 发现 3 个以上稳定领域术语时预填 glossary；
- L2 多阶段初始化可写 plan；
- 会话结束且未完成时写 handoff；
- 不为了目录完整而制造空泛文件。

### 第 10 步：记录、验证、报告

初始化/协议升级属于 L2。记录：

- 用户目标和涉及目录；
- 风险领域；
- 安装的 Profile / Skill；
- 关键假设和剩余缺口；
- 运行命令、关键输出和结论；
- README、architecture、decisions 更新。

至少验证：

- 文档引用路径存在；
- `AGENTS.md` 版本印记正确；
- 未覆盖用户已有内容；
- Profile 指向真实 Skill；
- 目标项目已有 lint/test/build 命令可运行，或明确说明无法运行；
- scanner 候选未被包装为确认 finding。

## 已有文件规则

- 绝不盲目覆盖 `AGENTS.md`、README、Profile 或 Skill；
- 本地更严格规则优先；
- 不为目标项目编造业务规则；
- 不把 canonical ReadmeFirst 仓库状态硬编码进下游；
- 不自动安装与技术栈证据不匹配的能力包；
- 删除、替换或破坏性迁移必须按目标项目 L2 规则处理。

## 交接

结束时明确：

- 后续日常任务遵循目标项目 `AGENTS.md` 和 `.ai/profiles/`；
- 每 2–4 周、changes 约 15 个日文件后或大重构后运行 `readme-first-maintainer`；
- 能力包升级独立于 ReadmeFirst 协议升级，不覆盖项目本地化 Profile。
