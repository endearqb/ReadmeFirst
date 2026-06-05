# 0001 - 将 .ai/architecture 作为当前架构知识层

## 背景

README First 已经定义了 `AGENTS.md`、根 `README.md`、目录 README、`.ai/changes/` 和 `.ai/decisions/` 的分工，但缺少一个稳定位置来描述“当前系统架构是什么样”。当跨目录协议、文档边界或 skill 职责发生变化时，只依赖 README 和历史 decisions 会让后续 Agent 难以快速定位当前状态。

## 决策

将 `.ai/architecture/` 纳入 README First 推荐最小系统，作为当前稳定架构知识层。

该目录记录：

- 上下文系统模块地图。
- 文档读取和依赖边界。
- 文档契约和更新触发条件。
- readme-first-builder skill 的职责边界。
- 本仓库本地维护流程。
- 当前状态摘要。

## 影响

- `AGENTS.md` 需要要求跨目录、协议、目录职责和长期约定类任务读取 `.ai/architecture`。
- 根 `README.md` 需要把 `.ai/architecture` 与 `.ai/changes`、`.ai/decisions` 并列说明。
- readme-first-builder skill 需要在初始化/升级流程中创建或合并 `.ai/architecture`。
- `.ai/decisions/` 继续记录历史决策原因；`.ai/architecture/` 只记录当前稳定状态。

## 非目标

- 不把 `.ai/architecture` 变成所有项目的详细设计百科。
- 不把 AutoWaterSimu 的业务架构内容搬进 ReadmeFirst。
- 不在本次引入文档测试工具链或机器可解析 schema。
