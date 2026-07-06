# README First Dependency Boundaries
> 更新于:2026-07-06 · commit 332f388

> Status: stable boundary set, 2026-07-06.

本文档定义 README First 文档之间的读取顺序、优先级和不可替代关系。

## Intended Reading Direction

```mermaid
flowchart TD
  Agents["AGENTS.md"]
  Root["README.md"]
  Architecture[".ai/architecture"]
  ParentReadme["Parent directory README.md"]
  LocalReadme["Nearest directory README.md"]
  Target["Target files, tests, config"]
  Changes[".ai/changes"]
  Decisions[".ai/decisions"]
  Glossary[".ai/glossary.md"]
  Handoff[".ai/handoff.md"]
  Plans[".ai/plans"]
  Maintainer["skills/readme-first-maintainer"]

  Agents --> Root
  Root --> Architecture
  Root --> ParentReadme
  Root --> Glossary
  Handoff --> Agents
  ParentReadme --> LocalReadme
  LocalReadme --> Target
  Architecture --> Target
  Changes --> Architecture
  Decisions --> Architecture
  Glossary --> Target
  Plans --> Target
  Maintainer --> Changes
  Maintainer --> Architecture
  Maintainer --> Decisions
  Maintainer --> Glossary
  Maintainer --> Handoff
  Maintainer --> Plans
```

## Priority Rules

| 规则 | 原因 |
|---|---|
| `AGENTS.md` 的全局行为规则优先级最高 | 保证所有 Agent 先遵守同一执行协议 |
| 最近的目录 README 优先于上级目录 README | 局部目录契约更接近目标文件 |
| `.ai/architecture/` 解释跨目录长期架构 | 避免把跨目录规则散落到多个局部 README |
| `.ai/decisions/` 解释历史原因，不直接覆盖当前文件事实 | 决策可能过时，当前事实应以 README、代码和测试为准 |
| `.ai/changes/` 解释单次变更，不作为稳定 API 文档;积累后由 maintainer 压缩归档 | 变更记录是历史线索，不是当前契约 |
| `.ai/glossary.md` 解释共享术语;会话内首次接触项目时与根 README 一并读 | 避免同一概念在不同文档中被重复解释 |
| `.ai/handoff.md` 解释跨会话的未完成状态;存在时必读 | 保证任务连续性，不丢失上下文 |
| `.ai/plans/` 解释 L2 多阶段计划;执行前必读 | 复杂任务需要零上下文可执行的计划 |
| `skills/readme-first-maintainer/` 解释文档系统的定期维护 | 系统性巡检、压缩、沉淀不应由日常任务承担 |

## Non-Substitution Rules

- 不用根 `README.md` 替代目录 README；根 README 只提供项目地图。
- 不用目录 README 替代 `.ai/architecture`；目录 README 不应承载跨项目架构百科。
- 不用 `.ai/architecture` 替代 `.ai/decisions`；当前状态和历史决策原因要分开。
- 不用 `.ai/changes` 替代 git diff 或 commit；它记录原因、假设和验证，不记录完整补丁。
- 不用 readme-first-builder skill 替代目标项目上下文；初始化完成后，目标项目自己的 `AGENTS.md` 和 README 是本地权威。
- 不用 readme-first-maintainer skill 替代日常任务执行；它只负责文档与记录系统的定期批量维护。

## Conflict Handling

当文档与实际文件冲突时：

1. 指出冲突位置。
2. 判断是文档过时、实现偏离，还是任务需要更新长期约定。
3. 修正当前任务范围内的最小必要文件。
4. 在 `.ai/changes/` 记录修正原因。
5. 若冲突暴露长期架构选择，新增或更新 `.ai/decisions/`。
