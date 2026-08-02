# 目录说明：`.ai/architecture`

> 更新于:2026-08-02

## 1. 目录职责

本目录保存 README First 当前稳定架构的入口文档。

负责：

- 描述上下文系统、风险领域路由、Profile、Skill、能力包和证据层的职责；
- 说明 `AGENTS.md`、根 README、目录 README、`.ai/*`、`skills/`、`extensions/` 的边界；
- 沉淀 Builder、Maintainer、验证脚本和版本迁移的长期同步规则；
- 记录当前已落地能力、接受缺口和下一步方向。

不负责：

- 单次任务流水；
- 替代 `AGENTS.md` 的可执行规则；
- 替代 `.ai/decisions/` 的历史原因；
- 替代目标项目自己的代码、测试、schema、配置或 Profile。

## 2. 核心文件

| 文件 | 作用 |
|---|---|
| `context-map.md` | README First 模块、上下文与能力路由地图 |
| `dependency-boundaries.md` | 读取顺序、优先级和不可替代关系 |
| `documentation-contracts.md` | README、changes、Profile、Skill 等更新契约 |
| `profiles-and-extensions.md` | 风险领域、项目 Profile、专业 Skill 和能力包架构 |
| `skills.md` | Builder、Maintainer 与能力包 Skill 的职责边界 |
| `local-workflow.md` | 维护 canonical 仓库的编辑、验证和发布流程 |
| `current-state.md` | 已落地能力、当前缺口和质量方向 |

## 3. 维护约定

1. 只记录当前稳定事实，不记录普通 bugfix 和过程性调试。
2. 改变推荐最小系统、风险领域、Profile Schema、Skill 边界或证据模板时，同步检查本目录。
3. 需要保留长期选择原因时，同步写 `.ai/decisions/`。
4. `current-state.md` 明确区分 Landed、Accepted Gaps 和 Immediate Direction。
5. 时效戳使用 `> 更新于:YYYY-MM-DD`；可选 commit 只能明确表示“核验基线”。

## 4. 对外接口

跨目录、协议、长期维护、Profile/Skill、能力包和证据治理任务，应先读本 README，再读相关专题文档。

## 5. 依赖边界

可以引用：

- `AGENTS.md`、根 `README.md`、`VERSION`、`migrations/`；
- `.ai/changes/`、`.ai/decisions/`、`.ai/glossary.md`；
- `skills/readme-first-builder/`、`skills/readme-first-maintainer/`；
- `extensions/`、`tests/` 和 `.github/workflows/`。

不替代：

- 项目执行规则；
- 单次 changes；
- 历史决策；
- 专业 Skill 的具体工作流；
- 目标项目的本地 Profile。

## 6. 测试与验证

```bash
./skills/readme-first-maintainer/scripts/check-paths.sh .
./skills/readme-first-maintainer/scripts/check-freshness.sh .
bash tests/test-maintainer-scripts.sh
python3 tests/validate_repository.py
python3 -m py_compile \
  skills/readme-first-maintainer/scripts/check-profiles.py \
  extensions/fullstack-foundations/skill/fullstack-foundations-guard/scripts/risk_scan.py
```

## 7. AI 操作提示

1. 先读根 `AGENTS.md`、根 README 和本 README。
2. 单次任务细节写 changes，当前事实写 architecture，长期原因写 decisions。
3. Core、Profile 和 Skill 要分层；不要把专业培训材料塞回根协议。
4. 改变 Profile/Skill 架构时同步 Builder、Maintainer、migration 和验证脚本。
