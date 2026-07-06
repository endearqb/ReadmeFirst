# README First Skills Architecture
> 更新于:2026-07-06 · commit 332f388

> Status: skills boundary, 2026-07-06.

`skills/` 目录包含两个互补的可复用技能：一次性初始化/升级入口 `readme-first-builder`，以及定期维护入口 `readme-first-maintainer`。

## Skill Ownership

### `skills/readme-first-builder/`

负责：

- 说明何时使用该 skill（初始化、升级 README First v2.1）。
- 指向 canonical source：`endearqb/ReadmeFirst`。支持检测目标项目版本印记并按序应用 `migrations/`。
- 定义初始化流程：扫描、合并 `AGENTS.md`、补全根 README、建立 `.ai/` 最小结构与标准扩展占位、按热度×复杂度双因子建 P0 目录 README。
- **离线优先**：自带完整模板 `skills/readme-first-builder/references/agents-md-template.md` 与 `skills/readme-first-builder/references/templates.md`，不再依赖网络拉取上游。
- 保护已有项目文档，要求合并而不是覆盖。
- 初始化/升级结束后，把后续日常任务交回目标项目自己的 `AGENTS.md`，把定期维护交给 readme-first-maintainer。

不负责：

- 为目标项目编造业务规则。
- 覆盖目标项目已有的 stricter local rules。
- 在初始化后继续接管普通代码、文档、测试或 review 任务。
- 把 ReadmeFirst 仓库当前状态硬编码到目标项目。
- 执行系统性文档巡检、变更记录压缩或知识沉淀。

### `skills/readme-first-maintainer/`

负责：

- 定期批量完成日常任务卸下的系统性负担：健康巡检、记忆压缩、知识沉淀、协议校准。
- 使用 `skills/readme-first-maintainer/scripts/` 中的只读脚本取数,再由 Agent 判断。
- 巡检范围包括：失效路径、文档漂移、覆盖缺口、版本差距、术语漂移、陈旧交接、未归档计划。
- 只读先行出报告；低风险文档修正直接执行；归档/删除类操作先征求确认。
- 在 `.ai/changes/` 中记录维护过程。

不负责：

- 修改业务代码。
- 替代目标项目日常任务执行。
- 在初始化阶段建立架构。

## Canonical Source Sync

当以下文件变化时，应检查两个 skill 是否需要同步：

- `AGENTS.md`
- 根 `README.md`
- `VERSION`
- `migrations/`
- `.ai/architecture/README.md`
- `.ai/architecture/documentation-contracts.md`
- `.ai/architecture/skills.md`
- `skills/readme-first-builder/references/agents-md-template.md`
- `skills/readme-first-builder/references/templates.md`
- `skills/readme-first-maintainer/scripts/`

同步重点：

| Source change | Skill update |
|---|---|
| 推荐最小系统新增目录 | 更新 builder skill description 和 Initialization Workflow |
| 记录机制变化(分级、压缩) | 更新 builder/maintainer 的 `.ai/changes` / `.ai/decisions` / `.ai/architecture` 相关步骤 |
| canonical source 增加入口文件 | 更新 builder references 和 maintainer 巡检清单 |
| handoff 规则变化 | 更新 builder 与 maintainer 的交接说明 |
| L0/L1/L2 分级阈值变化 | 更新 maintainer 协议校准工作流 |

## Validation

修改 skill 后建议运行：

```powershell
git diff --check -- skills\readme-first-builder skills\readme-first-maintainer
rg -n "AGENTS.md|README.md|.ai/architecture|.ai/changes|.ai/decisions|skills/readme-first-builder|skills/readme-first-maintainer" .
```
