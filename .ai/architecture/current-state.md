# ReadmeFirst Current State

> 更新于:2026-08-02

## Landed

- `AGENTS.md` 升级为 v2.2：L0/L1/L2 与风险领域二维路由。
- 根 README 解释 Profile、Skill、能力包和渐进披露模型。
- `.ai/profiles/` 成为按需项目扩展，不进入无 Profile 项目的最小系统。
- `extensions/` 定义 canonical 能力包契约和 Profile 模板。
- `extensions/fullstack-foundations/` 提供首个参考能力包、全栈 Guard Skill、培训手册、检查清单、模式库和候选扫描器。
- Builder v2.2 支持风险候选发现和可选能力包安装；热点脚本自包含，不再隐式依赖 Maintainer。
- Maintainer v2.2 增加 Profile/Skill/证据治理。
- `check-freshness.sh` 修复管道子 shell 状态丢失，并兼容 GNU/BSD date。
- `dir-hotspots.sh` 按唯一 commit 统计热度，并正确计算目录内部深度。
- `check-profiles.py` 验证 Profile frontmatter、风险领域和 Skill 绑定。
- `tests/` 与 GitHub Actions 提供无第三方依赖的回归和仓库一致性验证。
- `VERSION` 与 `migrations/v2.1-to-v2.2.md` 提供无损升级路径。

## Accepted Current Gaps

- Profile frontmatter 使用受控的轻量 YAML 子集，暂未发布独立 JSON Schema。
- Builder 能发现和安装能力包，但不会自动从网络下载或合并本地派生 Skill。
- Full-stack Foundations 是首个参考实现，尚未经过多个不同技术栈项目的长期校准。
- changes 和 decisions 仍以 Markdown 为主，机器可解析字段只在 Profile 和仓库 validator 中落地。
- `check-paths.sh` 是候选抽取器，对复杂 Markdown 示例仍可能产生需人工判断的误报。
- Windows 原生 PowerShell 没有独立脚本版本，当前依赖 Git Bash / WSL 或 CI。

## Immediate Quality Direction

- 在 2–3 个真实项目中验证 Profile 触发精度、上下文成本和 L2 证据字段。
- 收集 Full-stack Foundations 的误触发、遗漏和噪声，必要时拆分为数据库、安全或网络子 Profile。
- 评估 Profile JSON Schema 和 `readmefirst validate` CLI，但在真实重复需求前不引入重工具链。
- 为能力包升级建立兼容矩阵和本地派生合并策略。
- 继续保持 Core 短、能力包可选、证据优先和下游本地规则优先。
