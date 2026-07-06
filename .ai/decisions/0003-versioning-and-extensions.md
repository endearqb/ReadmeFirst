# 0003 - README First 版本化与标准扩展边界

## 背景

v2.0 将 README First 从统一流程改造为分级执行,但框架本身没有版本号,下游项目无法判断自己使用的是哪一版协议,也无法安全升级。同时,v2.1 引入 plans、glossary、handoff 等组件,若全部纳入"最小系统",会让低风险任务被迫理解不必要的内容,违背"重量与风险成正比"的核心原则。

## 决策

1. **采用语义版本**:MAJOR=协议执行方式不兼容变化;MINOR=新增组件或规则且向后兼容;PATCH=文字修正。本仓库根 `VERSION` 为 canonical 版本,下游项目在其 `AGENTS.md` 首行写印记 `<!-- README First protocol vX.Y.Z -->`。
2. **建立升级通道**:canonical 仓库维护 `migrations/` 目录,每个 MINOR 升级对应一份 Markdown 操作清单;`readme-first-builder` 检测目标项目印记,按序应用落后版本的迁移文件。
3. **标准扩展而非最小系统**:`.ai/plans/`、`.ai/glossary.md`、`.ai/handoff.md` 定位为触发式标准扩展。它们在 builder 初始化时创建占位,但协议条款统一用"如存在则读/用"措辞;不命中条件时,L0/L1 任务不需要知道它们存在。

## 影响

- 新增 `VERSION`、`migrations/v2.0-to-v2.1.md`、`migrations/v1-to-v2.0.md`。
- `skills/readme-first-builder/SKILL.md` 增加升级模式与版本印记处理。
- 根 `README.md` 与 `AGENTS.md` 需要在系统组成和读取路由中标注三个扩展为"按需启用"。
- `.ai/architecture/documentation-contracts.md` 需要为扩展组件和版本文件增加契约行。

## 非目标

- 不为下游项目强制同步每一个 PATCH;PATCH 只修正文字,不影响执行。
- 不将标准扩展变为最小系统成员;它们必须保持触发式。
