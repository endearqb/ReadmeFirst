# ReadmeFirst Current State

> Status: repository state summary, 2026-06-05.

本文档总结 ReadmeFirst 仓库当前稳定状态，帮助后续维护者快速进入上下文。

## Landed

- 根 `AGENTS.md` 定义 AI 协作执行协议：读取顺序、不确定性压缩、增删改查规则、记录规则、README 模板和最终输出要求。
- 根 `README.md` 解释 README First 的目的、系统组成、核心原则、标准执行流程和落地路线。
- `.ai/architecture/` 保存当前稳定架构入口，覆盖上下文地图、依赖边界、文档契约、builder skill、维护流程和当前状态。
- `.ai/changes/` 记录单次变更原因、范围、假设和验证结果。
- `.ai/decisions/` 记录长期架构决策及其影响。
- `skills/readme-first-builder/` 提供可复用的初始化/升级 skill。
- `skills/readme-first-builder/agents/openai.yaml` 提供 OpenAI/Codex agent metadata。

## Accepted Current Gaps

- 仓库当前没有自动化文档测试、链接检查或 package-level test command。
- `.ai/architecture` 是当前架构摘要，不覆盖所有可能的目标项目目录模板。
- readme-first-builder skill 仍是轻量初始化器，不负责完整项目审计、自动生成全部目录 README 或验证目标项目代码行为。
- `.ai/changes` 和 `.ai/decisions` 以 Markdown 记录为主，尚未定义机器可解析 schema。

## Immediate Quality Direction

- 保持 canonical 文档短而准，避免把目标项目业务细节写入 README First。
- 当推荐最小系统变化时，同步更新根 README、AGENTS、architecture 和 skill。
- 后续可增加轻量链接/路径检查脚本，但在出现真实重复需求前不引入新的工具链。
- 优先沉淀目录职责、边界、验证入口和 handoff 规则，而不是扩大模板数量。
