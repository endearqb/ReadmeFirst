# README First Documentation Contracts

> Status: documentation contract summary, 2026-06-05.

本文档定义 README First 各类文档的更新触发条件和写作边界。

## Contract Table

| 文档 | 记录什么 | 不记录什么 | 更新触发 |
|---|---|---|---|
| `AGENTS.md` | Agent 必须遵守的执行协议 | 项目介绍、长篇架构说明、单次任务细节 | 改变读取顺序、风险规则、记录规则或最终输出要求 |
| 根 `README.md` | 项目目的、系统组成、核心原则、落地路线 | 每个目录的详细职责、单次变更流水 | 推荐最小系统、顶层目录职责或 rollout 方式变化 |
| 目录级 `README.md` | 当前目录职责、核心文件、依赖边界、验证方式 | 跨目录百科、普通 bugfix、临时调试 | 目录职责、核心文件、公共接口或维护约定变化 |
| `.ai/architecture/` | 当前稳定架构状态和跨目录知识 | 历史决策全文、单次任务日志、目标项目业务内容 | 文档系统结构、跨目录边界、skill 职责或当前状态变化 |
| `.ai/changes/` | 单次变更的原因、范围、假设、验证 | 完整 diff、长期规范全文 | 每次完成修改后 |
| `.ai/decisions/` | 长期架构决策的背景、选择和影响 | 临时任务计划、已废弃流水细节 | 产生或改变长期维护规则时 |
| `skills/readme-first-builder/` | 初始化或升级 README First 的可复用工作流 | 日常任务协议、目标项目具体事实 | canonical README First 架构变化时 |

## Update Rules

- 改变 README First 推荐最小系统时，同步更新根 `README.md`、`AGENTS.md`、`.ai/architecture/` 和 readme-first-builder skill。
- 新增 `.ai/architecture` 文件时，更新 `.ai/architecture/README.md` 的核心文件表。
- 新增长期决策时，优先写 `.ai/decisions/`；如果该决策代表当前稳定状态，再把结果摘要写入 `.ai/architecture/`。
- 单次文档优化必须写入 `.ai/changes/YYYY-MM-DD.md`，即使没有代码测试可运行。

## Style Rules

README First 文档应短而准：

- 用当前仓库事实写作，不凭空补项目愿景。
- 优先写职责、边界、入口和验证方式。
- 避免把普通操作步骤写成长期架构。
- 避免把历史原因塞进当前状态文档；历史原因进入 `.ai/decisions/`。
