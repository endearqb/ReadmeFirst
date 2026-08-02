# README First Documentation Contracts

> 更新于:2026-08-02

## Contract Table

| 文档 / 能力 | 记录什么 | 不记录什么 | 更新触发 |
|---|---|---|---|
| `AGENTS.md` | 执行协议、任务分级、风险路由、记录与禁止行为 | 项目介绍、专业百科、单次任务细节 | 协议和路由变化 |
| 根 README | 项目目的、系统组成、核心原则、落地入口 | 每个目录细节、单次流水 | 推荐最小系统或能力包入口变化 |
| 目录 README | 当前目录职责、核心文件、边界、验证 | 跨目录百科、普通 bugfix | 目录职责、接口或维护约定变化 |
| `.ai/architecture/` | 当前稳定架构与跨目录知识 | 历史原因全文、任务流水 | 架构、Profile/Skill 边界或当前状态变化 |
| `.ai/profiles/` | 项目本地触发、风险领域、不变量、证据、Skill 路径 | 通用培训全文、未验证项目事实 | 安装/升级能力包、技术栈或门禁变化 |
| 项目 `skills/` | 可复用专业工作流和渐进 references | 项目专属业务规则 | Skill 升级或专业工作流变化 |
| `.ai/changes/` | 原因、风险、Profile/Skill、假设和验证 | 完整 diff、长期规范全文 | 每次 L1/L2 修改 |
| `.ai/decisions/` | 长期选择的背景、决策、影响 | 临时计划和流水 | 长期维护规则变化 |
| `extensions/` | canonical 能力包发布与安装契约 | 强制下游项目安装 | 新增/升级/退役能力包 |
| Builder | 初始化、升级、候选发现、可选安装 | 日常任务和完整项目审计 | Core、Profile Schema 或安装流程变化 |
| Maintainer | 巡检、压缩、沉淀、校准、Profile 治理 | 日常业务实现 | 维护机制和证据规则变化 |
| `VERSION` / `migrations/` | 协议版本和无损升级清单 | 项目业务内容 | 协议升级 |

## Update Rules

- 改变最小系统或核心协议：同步根 README、AGENTS、architecture、Builder、Maintainer、VERSION 和 migration。
- 改变风险领域或 Profile Schema：同步 AGENTS、`profiles-and-extensions.md`、profile template、Maintainer 和 validator。
- 新增能力包：更新 `extensions/README.md` 表、添加 PROFILE/Skill、验证路径和版本。
- 修改根 AGENTS：同步 Builder 离线模板。
- changes 约 15 个日文件或超过 30 天：运行 Maintainer 压缩和沉淀。
- 长期决策先写 decisions；当前稳定结论再同步 architecture 或 Profile。

## Evidence Contract

L2 changes 至少记录：

- 风险领域；
- 使用的 Profile / Skill；
- 业务不变量与信任边界；
- 正确性证据；
- 适用的性能/资源、并发/重复、安全/隐私、迁移/恢复证据；
- 无法运行时的原因和替代核查。

“命令名称”不是证据；证据需要命令、关键输出和结论。Scanner 命中只能作为调查入口。

## Timestamp Contract

标准格式：

```md
> 更新于:YYYY-MM-DD
```

旧 `· commit <sha>` 格式兼容，但新文档不要求写未生成的最终 commit。若保留 SHA，必须明确其语义为核验基线。

## Style Rules

- 基于当前仓库事实；
- 优先职责、边界、入口和验证；
- Core 保持短，专业深度放 Profile / Skill references；
- 不把历史原因塞入当前状态；
- 不把通用能力包规则伪装成目标项目事实。
