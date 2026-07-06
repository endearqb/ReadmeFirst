# 目录说明：.ai/architecture
> 更新于:2026-07-06 · commit 332f388

## 1. 目录职责

本目录保存 README First 当前稳定架构的入口文档。

本目录负责：

- 描述 README First 上下文系统的模块地图、文档契约和依赖边界。
- 说明 `AGENTS.md`、根 `README.md`、目录 README、`.ai/changes/`、`.ai/decisions/`、标准扩展(`.ai/glossary.md`、`.ai/handoff.md`、`.ai/plans/`)与本目录之间的分工。
- 沉淀 readme-first-builder 与 readme-first-maintainer 两个 skill 的长期职责和同步规则。
- 记录当前仓库状态，降低后续维护者翻阅历史变更记录的成本。

本目录不负责：

- 记录单次任务流水账。
- 替代 `AGENTS.md` 中的可执行行为规则。
- 替代 `.ai/decisions/` 中的历史决策记录。
- 替代目标项目自己的 README、代码、测试或配置。

## 2. 核心文件

| 文件 | 作用 |
|---|---|
| `context-map.md` | README First 上下文系统的模块职责地图 |
| `dependency-boundaries.md` | 文档读取顺序、优先级和依赖边界 |
| `documentation-contracts.md` | README、changes、decisions、architecture 的更新契约 |
| `skills.md` | readme-first-builder 与 readme-first-maintainer 的职责边界和同步规则 |
| `local-workflow.md` | 维护本仓库时的本地探索、编辑、验证和发布流程 |
| `current-state.md` | 当前仓库结构、已接受缺口和下一步演进方向 |

## 3. 维护约定

1. 本目录只记录当前稳定事实，不记录普通 bugfix、临时想法或可从 git diff 看出的细节。
2. 当 `AGENTS.md`、根 `README.md`、skill 初始化流程或 `.ai/` 分工发生变化时，必须同步检查本目录。
3. 当本目录记录新的长期架构选择时，若该选择需要保留历史原因，应同时新增或更新 `.ai/decisions/`。
4. `current-state.md` 应明确区分已落地能力、当前接受的缺口和计划中的后续方向。

## 4. 对外接口

本目录对开发者和 Agent 暴露 README First 的稳定架构入口。跨目录、协议、目录职责、长期维护约定类任务，应先读本 README，再读相关架构文件。

## 5. 依赖边界

可以引用：

- `AGENTS.md`
- 根 `README.md`
- `VERSION`
- `migrations/`
- `.ai/changes/`
- `.ai/decisions/`
- `skills/readme-first-builder/`
- `skills/readme-first-maintainer/`

不应该替代：

- `AGENTS.md` 的执行规则。
- 根 `README.md` 的项目介绍和落地路线。
- `.ai/changes/` 的单次变更记录。
- `.ai/decisions/` 的历史决策记录。

## 6. 测试与验证

修改本目录后建议运行：

```powershell
git diff --check
./skills/readme-first-maintainer/scripts/check-paths.sh .
./skills/readme-first-maintainer/scripts/check-freshness.sh .
grep -rn "AGENTS.md\|README.md\|.ai/architecture\|.ai/changes\|.ai/decisions\|skills/readme-first-builder\|skills/readme-first-maintainer" .
```

## 7. AI 操作提示

1. 先读根 `AGENTS.md`、根 `README.md` 和本 README。
2. 只沉淀长期架构知识；单次任务细节写入 `.ai/changes/`。
3. 如果修改会改变 README First 的推荐最小系统，同步检查 `documentation-contracts.md`、根 `README.md`、readme-first-builder skill 和 readme-first-maintainer skill。
