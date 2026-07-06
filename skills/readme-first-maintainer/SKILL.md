---
name: readme-first-maintainer
description: Periodic maintenance for projects using the README First v2.1 architecture (AGENTS.md + .ai/ + directory READMEs + optional plans/glossary/handoff). Runs four workflows — health audit (drift, dead paths, coverage gaps, staleness), memory compaction, knowledge distillation, and protocol tuning — using read-only scripts. Use whenever the user says 维护 readmefirst / 巡检文档 / 整理 .ai 目录 / 压缩变更记录 / 文档漂移检查 / README 过时了 / 沉淀知识 / audit docs / compact changes, or after a large refactor, or when .ai/changes has accumulated roughly 15+ daily files, or when an agent reports repeated doc-code conflicts. Do NOT use for initializing/upgrading README First (use readme-first-builder) or for ordinary coding tasks (follow the project's AGENTS.md).
---

# README First Maintainer(v2.1)

## 目的

README First v2 的日常协议是轻的:L0 不记录、L1 短记录、日常任务不做系统性一致性核对。这些被卸下的负担没有消失,而是集中到本技能定期批量完成——**平时轻记录,定期重整理**。

本技能只维护"文档与记录系统",不修改业务代码。发现代码问题时列入报告,交由用户决定。

## 总流程

```txt
1. 只读巡检,生成发现清单
2. 直接执行低风险修复(改文档不改代码,可一次 revert 恢复)
3. 归档/删除/重写类操作 → 列清单征求用户确认后执行
4. 本次维护记入 .ai/changes/(L1;若调整了协议或架构则 L2)
5. 输出维护报告
```

默认执行全部四个工作流;用户点名时可只执行其中一个。开始前先读目标项目的 `AGENTS.md` 与 `.ai/architecture/`,以项目自己的约定为准。

---

## 工作流 1:健康巡检(Audit)

脚本位于 `skills/readme-first-maintainer/scripts/`。Windows 环境经 Git Bash 运行;若脚本无法运行,降级为手工按相同逻辑巡检。

### 1a. 失效引用检查

```bash
./skills/readme-first-maintainer/scripts/check-paths.sh .
```

输出中的 `DEAD` 进入发现清单;同时抽查文档声明的命令是否仍有效。

### 1b. 漂移检查(文档 vs 代码)

```bash
./skills/readme-first-maintainer/scripts/check-freshness.sh .
```

对 `NO-STAMP` 文档补戳;对 `STALE` 文档对比核心文件表、职责描述与当前目录现状,判断是文档过时还是代码偏离。核心文件明显缺失/新增的,列入发现清单。

### 1c. 覆盖缺口检查

```bash
./skills/readme-first-maintainer/scripts/dir-hotspots.sh .
```

按"热度 × 复杂度"双因子表判断:双高 → 建议 P0 建 README;高热低复杂 → 短 README;高复杂低热 → 待观察;双低 → 跳过。补建使用 builder 技能 `skills/readme-first-builder/references/templates.md` 中的最小三节模板。

### 1d. 额外检查

- **版本差距**:读取目标项目 `AGENTS.md` 首行印记,与上游 `VERSION` 比较(有网络时拉 GitHub raw,无网络时跳过并注明)。
- **术语漂移**:若 `.ai/glossary.md` 存在,检查词条命名是否与代码实际命名冲突、是否有重复/长期未用词条。
- **陈旧交接**:`.ai/handoff.md` 超过 14 天未清空 → 列入待确认。
- **未归档计划**:`.ai/plans/` 下非 `.ai/plans/done/` 的计划文件超过 30 天 → 提醒归档或废弃。

---

## 工作流 2:记忆压缩(Compact)

触发条件(满足其一):`.ai/changes/` 日文件超过约 15 个;或存在 30 天以前的日文件。保留最近 30 天的原始记录不动。

对更早的记录,按月生成摘要 `.ai/changes/YYYY-MM-digest.md`,每条压成 1–3 行:

```md
# YYYY-MM 变更摘要(由 maintainer 压缩,原文见 archive/)

- MM-DD <标题> [级别]:一句话结果;长期影响(无则省略)。
```

压缩规则:

1. 保留:做了什么、最终结论、仍然有效的假设与注意事项。
2. 丢弃:过程性细节、已被后续变更推翻的内容(注明"已被 MM-DD 变更取代")。
3. 原始日文件移入 `.ai/changes/archive/`,**未经用户明确同意不得删除**。
4. 压缩过程中发现的候选长期知识,交给工作流 3。

---

## 工作流 3:知识沉淀(Distill)

通读本轮压缩范围内(及最近 30 天)的 changes 记录,寻找以下模式并晋升为长期知识:

| 模式 | 晋升到 |
|---|---|
| 同一假设/约定在多条记录中重复出现 | 对应目录 README 的「约定与依赖边界」或「维护提示」 |
| 跨目录的边界、当前状态类结论 | `.ai/architecture/` |
| 记录中出现"为什么选 A 不选 B"且影响长期 | `.ai/decisions/`(新增编号决策) |
| 反复踩的同一个坑 | 对应目录 README 的「维护提示」 |

沉淀规则:每条晋升的知识注明来源(哪天的 change 条目);不得晋升未经验证的猜测;晋升后在 digest 中标注"已沉淀至 <路径>"。`.ai/architecture/README.md` 超过约 150 行时,按主题拆分为多文件并保留入口。

---

## 工作流 4:协议校准(Tune)

检查分级协议与项目实际用法是否匹配:

1. 统计 changes 中 `[L1]`、`[L2]` 标签分布。大量 L1 记录实际符合 L0 特征(一两个文件、无接口影响、字段多为"无")→ 建议在 AGENTS.md 中放宽 L0 边界;反之,出现高影响修改只按 L1 记录 → 建议收紧并在报告中点名。
2. 检查记录模板字段的实际使用率:某字段长期为"无"→ 建议从短模板删除。
3. 若在 ReadmeFirst 仓库本身运行:检查根 `AGENTS.md` 与 `skills/readme-first-builder/references/agents-md-template.md` 是否同步,不同步则以根文件为准更新副本;同步后刷新副本时效戳。
4. 协议调整属 L2:给出建议与理由,经用户确认后修改 AGENTS.md,并写入 `.ai/decisions/`;同步更新 `VERSION`、迁移文件与下游迁移指南。

---

## 维护报告模板

```md
# README First 维护报告 YYYY-MM-DD

## 概览
巡检范围 / 总体健康结论(良好 · 轻微漂移 · 需要关注)

## 发现
- 失效引用:
- 文档漂移:
- 覆盖缺口(热度/复杂度):
- 过期标记:
- 版本差距:
- 术语漂移:
- 陈旧交接:
- 未归档计划:

## 已修复(低风险,已直接执行)
## 待确认(需要你决定)
(归档、补建、协议调整等,逐条给出建议做法与理由)

## 压缩与沉淀
归档 N 条 → digests;沉淀 M 条 → (列出目标文件)

## 协议校准建议
```

## 边界与禁止行为

- 不修改业务代码;不发明项目事实;沉淀的每条知识必须可追溯到记录或代码事实。
- 不重写用户手写的文档内容,只补充、修正明确过时的事实性描述。
- 未经确认不做任何删除;归档是移动,不是删除。
- 单次维护改动过大时(如需重写多个 README),拆分为多轮,先做用户确认过的高优先级项。

## 建议频率

每 2–4 周一次;或 `.ai/changes/` 累积约 15 个日文件后;或任何大重构合并后。在报告结尾根据本次发现量,给出下次维护的建议时间。
