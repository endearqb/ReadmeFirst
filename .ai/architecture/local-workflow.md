# ReadmeFirst Local Workflow

> 更新于:2026-08-02

## Root Entry

本仓库是协议、文档、Agent Skills、脚本和测试仓库，不需要应用构建。默认质量入口是：

```bash
git status --short --branch
./skills/readme-first-maintainer/scripts/check-paths.sh .
./skills/readme-first-maintainer/scripts/check-freshness.sh .
bash tests/test-maintainer-scripts.sh
python3 tests/validate_repository.py
```

## Main Recipes

| 命令 | 用途 |
|---|---|
| `git diff --check` | Markdown 和代码空白检查 |
| `bash -n <script>` | Shell 语法 |
| `check-paths.sh .` / `check-freshness.sh .` | 当前仓库路径引用与文档时效检查 |
| `bash tests/test-maintainer-scripts.sh` | 路径、新鲜度、热点、Profile、Scanner fixture 回归 |
| `python3 tests/validate_repository.py` | 版本、模板、Skill、Profile、迁移一致性 |
| `python3 -m py_compile <file>` | Python 脚本语法 |
| `git diff --stat` | 审阅范围 |
| `git diff -- <path>` | 审阅单文件 |

## Editing Rules

1. 修改前读 `AGENTS.md` 第 0 节、根 README 和相关 architecture。
2. 协议、Profile Schema、Skill 边界和脚本语义变化按 L2。
3. 根 AGENTS 变化同步 Builder 离线模板。
4. Builder 与 Maintainer 热点脚本保持一致。
5. 新能力包必须使用 extension 契约并通过 validator。
6. Scanner 结果只作为候选；测试必须验证真实脚本行为。
7. 时效戳写日期，不伪造尚未生成的最终 commit SHA。
8. 变更写入 `.ai/changes/YYYY-MM-DD.md`；长期原因写 decisions。

## Publish Flow

推荐从独立分支发布并创建 draft PR：

```bash
git diff --check
bash tests/test-maintainer-scripts.sh
python3 tests/validate_repository.py
git status --short
git diff --stat
```

若远端已变化，先比较并解决，不强制覆盖。PR 说明应包含：修改内容、原因、兼容性、验证证据和剩余风险。
