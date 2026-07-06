# ReadmeFirst Current State
> 更新于:2026-07-06 · commit 332f388

> Status: repository state summary, 2026-07-06.

本文档总结 ReadmeFirst 仓库当前稳定状态，帮助后续维护者快速进入上下文。

## Landed

- 根 `AGENTS.md` 定义 AI 协作执行协议(v2.1)：L0/L1/L2 分级、读取规则、访谈模式、术语命名约束、验证证据、计划协议、会话交接、禁止行为和最终输出要求。
- 根 `README.md` 解释 README First v2.1 的目的、系统组成(含标准扩展)、核心原则、标准执行流程、生命周期与版本升级机制。
- `VERSION` 与 `migrations/` 提供协议版本化和下游升级通道。
- `.ai/architecture/` 保存当前稳定架构入口，覆盖上下文地图、依赖边界、文档契约、skills 边界、维护流程和当前状态。
- `.ai/changes/` 按 L0/L1/L2 分级记录单次变更原因、范围、假设和验证证据；积累到一定阈值后由 maintainer 压缩归档。
- `.ai/decisions/` 记录长期架构决策及其影响。
- `.ai/glossary.md`、`.ai/handoff.md`、`.ai/plans/` 作为触发式标准扩展，按需启用。
- `skills/readme-first-builder/` 提供可复用的初始化/升级 skill(v2.1 离线优先、P0 渐进覆盖、双因子选点、版本升级模式)。
- `skills/readme-first-maintainer/` 提供可复用的定期维护 skill，基于只读脚本巡检、压缩、沉淀、校准。
- `skills/readme-first-maintainer/scripts/` 提供 check-paths、check-freshness、dir-hotspots 三个脚本。
- `skills/readme-first-builder/agents/openai.yaml` 提供 OpenAI/Codex agent metadata。

## Accepted Current Gaps

- `.ai/architecture` 是当前架构摘要，不覆盖所有可能的目标项目目录模板。
- readme-first-builder skill 仍是轻量初始化器，不负责完整项目审计、自动生成全部目录 README 或验证目标项目代码行为。
- readme-first-maintainer skill 及其脚本尚未经过多个真实维护周期验证，阈值、复杂度算法和 Windows 兼容性可能需要根据实际使用调整。
- `.ai/changes` 和 `.ai/decisions` 以 Markdown 记录为主，尚未定义机器可解析 schema。
- 访谈模式、计划协议、术语表等 v2.1 新增机制需要 1–2 个真实 L2 任务周期来校准触发条件和模板字段。

## Immediate Quality Direction

- 保持 canonical 文档短而准，避免把目标项目业务细节写入 README First。
- 当推荐最小系统变化时，同步更新根 README、AGENTS、architecture、builder skill 和 maintainer skill。
- 后续可增加轻量链接/路径检查脚本，但在出现真实重复需求前不引入新的工具链。
- 优先沉淀目录职责、边界、验证入口和 handoff 规则，而不是扩大模板数量。
- 运行 1–2 个维护周期后，根据 maintainer 的协议校准建议调整 L0/L1/L2 阈值。
