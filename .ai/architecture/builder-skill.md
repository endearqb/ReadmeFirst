# README First Builder Skill Architecture

> Status: builder skill boundary, 2026-06-05.

`skills/readme-first-builder/` 是 README First 的可复用初始化和升级入口。它帮助其他项目建立或合并 README First 文档结构，但不负责替代目标项目日常开发协议。

## Skill Ownership

`skills/readme-first-builder/` 负责：

- 说明何时使用该 skill。
- 指向 canonical source：`endearqb/ReadmeFirst`。
- 定义初始化/升级流程：检查根文档、合并 `AGENTS.md`、建立 README、建立 `.ai/` 记录和架构目录。
- 保护已有项目文档，要求合并而不是覆盖。
- 初始化结束后，把后续日常任务交回目标项目自己的 `AGENTS.md`。

它不负责：

- 为目标项目编造业务规则。
- 覆盖目标项目已有的 stricter local rules。
- 在初始化后继续接管普通代码、文档、测试或 review 任务。
- 把 ReadmeFirst 仓库当前状态硬编码到目标项目。

## Canonical Source Sync

当以下文件变化时，应检查 skill 是否需要同步：

- `AGENTS.md`
- 根 `README.md`
- `.ai/architecture/README.md`
- `.ai/architecture/documentation-contracts.md`
- `skills/readme-first-builder/references/readmefirst-source.md`

同步重点：

| Source change | Skill update |
|---|---|
| 推荐最小系统新增目录 | 更新 skill description 和 Initialization Workflow |
| 记录机制变化 | 更新 `.ai/changes` / `.ai/decisions` / `.ai/architecture` 创建步骤 |
| canonical source 增加入口文件 | 更新 `references/readmefirst-source.md` |
| handoff 规则变化 | 更新 Handoff After Initialization |

## Validation

修改 skill 后建议运行：

```powershell
git diff --check -- skills\readme-first-builder
rg -n "AGENTS.md|README.md|.ai/architecture|.ai/changes|.ai/decisions" skills\readme-first-builder
```
