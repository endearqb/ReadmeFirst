# ReadmeFirst Local Workflow
> 更新于:2026-07-06 · commit 332f388

> Status: local maintenance workflow, 2026-07-06.

本文档描述维护 `endearqb/ReadmeFirst` 仓库时的本地流程。

## Root Entry

本仓库当前是文档和 Codex skill 仓库，没有 package manifest、测试框架或构建脚本。默认验证入口是文档一致性检查和 git diff 检查。

推荐第一轮检查：

```powershell
git status --short --branch
Get-ChildItem -Force
rg -n ".ai/architecture|.ai/changes|.ai/decisions|skills/readme-first-builder|skills/readme-first-maintainer" .
```

## Main Recipes

| Recipe | Purpose |
|---|---|
| `git status --short --branch` | 确认分支、远端跟踪和工作区是否干净 |
| `rg -n "<path-or-term>" .` | 检查文档引用和同步点 |
| `git diff --check` | 检查 Markdown diff 中的空白错误 |
| `git diff --stat` | 快速审阅变更范围 |
| `git diff -- <path>` | 审阅目标文件变更 |
| 运行 `readme-first-maintainer` | 每 2–4 周或 `.ai/changes/` 约 15 个日文件后巡检、压缩、沉淀、校准 |

## Editing Rules

1. 修改前先读 `AGENTS.md` 第 0 节最小闭环、根 `README.md` 和相关 `.ai/architecture` 文件。
2. 新增长期架构知识时，优先写 `.ai/architecture/`；若需要保留决策原因，同步写 `.ai/decisions/`。
3. 每次修改后按 L0/L1/L2 分级写入 `.ai/changes/YYYY-MM-DD.md`。
4. 当 `.ai/changes/` 累积约 15 个日文件或超过 30 天记录时，运行 `readme-first-maintainer` 压缩归档并沉淀知识。
4. 不为构建产物、缓存、日志或临时目录建立 README。
5. 不把目标项目的业务内容写进 ReadmeFirst canonical 文档。

## Publish Flow

直接推送 `main` 前：

```powershell
git diff --check
git status --short
git diff --stat
```

若本地分支落后远端，先获取并检查远端变化，不要静默覆盖。提交信息应短而能表达文档架构变更，例如：

```txt
docs: add readmefirst architecture context layer
```
